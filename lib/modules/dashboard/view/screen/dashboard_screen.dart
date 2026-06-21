import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/ui_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../modules/searchLocation/models/search_location_model.dart';
import '../../../../modules/searchLocation/repository/search_location_repository.dart';
import '../../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';
import '../../choose_car_bottom_sheet/models/choose_car_model.dart';

// Import extracted widgets
import '../widget/top_bar_widget.dart';
import '../widget/search_and_saved_card_widget.dart';
import '../widget/services_section_widget.dart';
import '../widget/date_time_selection_dialogs.dart';

import '../../helpers/map_helper.dart';
import '../../models/trip_price_details_model.dart';
import '../../repository/trip_price_details_repository.dart';
import '../../choose_car_bottom_sheet/view/choose_car_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GoogleMapController? _mapController;

  /// Current camera center (updated as user drags map)
  LatLng _cameraCenter = const LatLng(23.8103, 90.4125);
  bool _isCameraMoving = false;

  /// List of pickup locations
  List<SearchLocationData> _pickups = [];

  /// Drop location set from the search card
  LatLng? _dropLatLng;

  String? _dropoffUuid;
  String? _dropoffAddress;

  /// Reverse geocoded address for center pin
  String? _centerAddress;
  Timer? _mapIdleDebounce;

  /// Map display items
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final GlobalKey<SearchAndSavedCardWidgetState> _searchCardKey = GlobalKey<SearchAndSavedCardWidgetState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      context.read<ChooseCarBottomSheetBloc>().add(
        LoadServices(languageCode: loc.locale.languageCode),
      );
    });
  }

  @override
  void dispose() {
    _mapIdleDebounce?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _cameraCenter = latLng;
    });

    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: latLng, zoom: 15.0),
    ));

    _handleCameraIdle(latLng);
  }



  /// Debounced reverse geocoding & route redrawing
  void _handleCameraIdle(LatLng position) {
    _mapIdleDebounce?.cancel();
    _mapIdleDebounce = Timer(const Duration(milliseconds: 600), () async {
      final isDropFocused = _searchCardKey.currentState?.isDropFocused ?? false;
      
      String address = 'Unknown Location';
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          address = [p.street, p.subLocality, p.locality, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
        if (address.trim().isEmpty) throw Exception("Empty native address");
      } catch (e) {
        debugPrint('Native geocoding failed: $e, trying Google API...');
        final googleAddress = await MapHelper.getGoogleGeocode(position);
        if (googleAddress != null && googleAddress.isNotEmpty) {
          address = googleAddress;
        } else {
          // If BOTH fail, fallback to coordinates
          address = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        }
      }

      if (mounted) {
        setState(() {
          _centerAddress = address;
        });

        // Fetch UUID for this address from API
        try {
          final loc = AppLocalizations.of(context);
          final searchRepo = SearchLocationRepository();
          final response = await searchRepo.searchLocations(address, loc.locale.languageCode);
          if (mounted && response.data != null && response.data!.isNotEmpty) {
            final uuid = response.data!.first.uuid;
            final locData = SearchLocationData(
              uuid: uuid,
              address: address,
              latitude: position.latitude,
              longitude: position.longitude,
            );

            setState(() {
              if (isDropFocused) {
                _dropoffUuid = uuid;
                _dropoffAddress = address;
                _dropLatLng = position;
              } else {
                int pIndex = _searchCardKey.currentState?.getActivePickupIndex() ?? 0;
                if (pIndex >= 0 && pIndex < _pickups.length) {
                   _pickups[pIndex] = locData;
                } else if (_pickups.isEmpty) {
                   _pickups.add(locData);
                }
              }
            });
            _searchCardKey.currentState?.setLocationFromMapDrag(locData);
          } else {
            _searchCardKey.currentState?.updateActiveFieldText(address);
          }
        } catch (e) {
          debugPrint('Failed to fetch UUID for map location: $e');
          _searchCardKey.currentState?.updateActiveFieldText(address);
        }

        // Sync local _pickups properly without triggering camera
        if (!isDropFocused) {
          setState(() {
             final validPickups = _searchCardKey.currentState?.getValidPickups() ?? [];
             if (validPickups.isNotEmpty) {
               _pickups = validPickups;
             }
          });
        }

        if (_pickups.isNotEmpty && _dropLatLng != null) {
          _drawRouteMulti();
        }
      }
    });
  }

  void _onSearchFieldFocusChanged(bool isDropFocused) {
    setState(() {
      _rebuildMarkers();
    });
    
    // Pan camera to the currently focused location
    final targetLatLng = isDropFocused ? _dropLatLng : (_pickups.isNotEmpty ? LatLng(_pickups.first.latitude!, _pickups.first.longitude!) : null);
    if (targetLatLng != null) {
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: targetLatLng, zoom: 15.0),
      ));
    }
  }

  /// Called when the user updates the pickups from the search list
  void _onPickupsUpdated(List<SearchLocationData> locations) {
    setState(() {
      _pickups = List.from(locations);
      _rebuildMarkers();
    });

    _drawRouteMulti();

    if (_pickups.isNotEmpty) {
      final last = _pickups.last;
      if (last.latitude != null && last.longitude != null) {
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(last.latitude!, last.longitude!), zoom: 15.0),
        ));
      }
    }
  }

  /// Called when the user selects a destination from the search list
  void _onDestinationSelected(SearchLocationData location) {
    if (location.latitude == null || location.longitude == null) return;
    final latLng = LatLng(location.latitude!, location.longitude!);

    setState(() {
      _dropLatLng = latLng;
      _dropoffUuid = location.uuid;
      _dropoffAddress = location.address;
      _rebuildMarkers();
    });

    _drawRouteMulti();

    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _pickups.isNotEmpty ? LatLng(_pickups.first.latitude!, _pickups.first.longitude!) : _cameraCenter, zoom: 11.0),
    ));
  }

  void _rebuildMarkers() {
    final markers = <Marker>{};
    final isDropFocused = _searchCardKey.currentState?.isDropFocused ?? false;

    // If we are currently modifying the drop location, draw static markers for the pickups!
    if (isDropFocused) {
      for (int i = 0; i < _pickups.length; i++) {
        final p = _pickups[i];
        if (p.latitude != null && p.longitude != null) {
          markers.add(Marker(
            markerId: MarkerId('pickup_$i'),
            position: LatLng(p.latitude!, p.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Pickup ${i + 1}'),
          ));
        }
      }
    }

    // If we are currently modifying the pickup location, draw a static marker for the drop!
    if (!isDropFocused && _dropLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Drop Off'),
      ));
    }

    _markers = markers;
  }

  Future<void> _drawRouteMulti() async {
    if (_pickups.isEmpty || _dropLatLng == null) return;

    List<LatLng> allRoutePoints = [];
    
    // Pickups sequentially
    for (int i = 0; i < _pickups.length - 1; i++) {
      final p1 = _pickups[i];
      final p2 = _pickups[i + 1];
      if (p1.latitude != null && p1.longitude != null && p2.latitude != null && p2.longitude != null) {
        final r = await MapHelper.getRouteBetweenCoordinates(
          LatLng(p1.latitude!, p1.longitude!),
          LatLng(p2.latitude!, p2.longitude!),
        );
        if (r.isNotEmpty) {
          allRoutePoints.addAll(r.first.points);
        }
      }
    }
    
    // Last pickup to dropoff
    final lastPickup = _pickups.last;
    if (lastPickup.latitude != null && lastPickup.longitude != null) {
      final r = await MapHelper.getRouteBetweenCoordinates(
        LatLng(lastPickup.latitude!, lastPickup.longitude!),
        _dropLatLng!,
      );
      if (r.isNotEmpty) {
        allRoutePoints.addAll(r.first.points);
      }
    }

    if (mounted) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: allRoutePoints,
            color: const Color(0xFF6C63FF),
            width: 5,
          )
        };
      });
    }
  }

  Future<void> _handleServiceSelection(String serviceKey, List<dynamic> defaultCars) async {
    if (_pickups.isEmpty || _dropoffUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('select_pickup_dropoff') ?? 'select_pickup_dropoff'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime? startDateTime;
    DateTime? returnDateTime;
    String? hoursBooked;

    final loc = AppLocalizations.of(context);
    
    // 2. Determine Date/Time based on service type
    if (serviceKey == "RIDE_SHARE") {
      startDateTime = DateTime.now();
    } else if (serviceKey == "HOURLY") {
      final minStartDateTime = DateTime.now().add(const Duration(hours: 2));
      final date = await DateTimeSelectionDialogs.pickDateAndTime(
        context, 
        minDateTime: minStartDateTime,
        dateHelpText: loc.translate('select_start_date') ?? 'SELECT START DATE',
        timeHelpText: loc.translate('select_start_time') ?? 'SELECT START TIME',
      );
      if (date == null) return;
      
      final hours = await DateTimeSelectionDialogs.pickHours(context);
      if (hours == null) return;
      
      startDateTime = date;
      hoursBooked = hours.toString();
    } else if (serviceKey == "RETURN") {
      final minStartDateTime = DateTime.now().add(const Duration(hours: 2));
      final startDate = await DateTimeSelectionDialogs.pickDateAndTime(
        context, 
        minDateTime: minStartDateTime,
        dateHelpText: loc.translate('select_start_date') ?? 'SELECT START DATE',
        timeHelpText: loc.translate('select_start_time') ?? 'SELECT START TIME',
      );
      if (startDate == null) return;
      
      final minEndDateTime = startDate.add(const Duration(hours: 3));
      final returnDate = await DateTimeSelectionDialogs.pickDateAndTime(
        context, 
        initialDate: minEndDateTime, 
        minDateTime: minEndDateTime,
        dateHelpText: loc.translate('select_return_date') ?? 'SELECT RETURN DATE',
        timeHelpText: loc.translate('select_return_time') ?? 'SELECT RETURN TIME',
      );
      if (returnDate == null) return;
      
      startDateTime = startDate;
      returnDateTime = returnDate;
    } else {
      final minStartDateTime = DateTime.now().add(const Duration(hours: 2));
      startDateTime = await DateTimeSelectionDialogs.pickDateAndTime(
        context, 
        minDateTime: minStartDateTime,
        dateHelpText: loc.translate('select_start_date') ?? 'SELECT START DATE',
        timeHelpText: loc.translate('select_start_time') ?? 'SELECT START TIME',
      );
      if (startDateTime == null) return;
    }

    // Show loading
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final loc = AppLocalizations.of(context);
      final req = TripPriceDetailsRequest(
        platform: "web", // or detect using Platform
        languageCode: loc.locale.languageCode,
        serviceType: serviceKey,
        pickupLocationUuid: _pickups.map((e) => e.uuid!).toList(),
        dropoffLocationUuid: [_dropoffUuid!],
        startDatetime: "${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')} ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}:00",
        endDatetime: returnDateTime != null ? "${returnDateTime.year}-${returnDateTime.month.toString().padLeft(2, '0')}-${returnDateTime.day.toString().padLeft(2, '0')} ${returnDateTime.hour.toString().padLeft(2, '0')}:${returnDateTime.minute.toString().padLeft(2, '0')}:00" : null,
      );

      final repo = TripPriceDetailsRepository();
      final response = await repo.getTripPriceDetails(req);
      
      if (mounted) Navigator.pop(context); // Hide loading
      
      if (response.status == true) {
        // Parse the vehicles from the response data if available
        List<Car> finalCars = defaultCars.cast<Car>();
        
        try {
          if (response.data != null && response.data is Map) {
            final Map<String, dynamic> dataMap = response.data;
            if (dataMap.containsKey(serviceKey)) {
              final serviceGroup = dataMap[serviceKey];
              if (serviceGroup != null && serviceGroup['cars'] is List) {
                final parsedCars = (serviceGroup['cars'] as List).map((e) => Car.fromJson(e)).toList();
                if (parsedCars.isNotEmpty) {
                  finalCars = parsedCars;
                }
              }
            }
          }
        } catch (parseErr) {
          debugPrint("Failed to parse API vehicles: $parseErr");
        }

        // Show Vehicle Details in bottom sheet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip details loaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.845,
                child: ChooseCarBottomSheet(
                  cars: finalCars,
                  serviceName: serviceKey,
                  pickupAddresses: _pickups.map((e) => e.address ?? 'Unknown').toList(),
                  dropoffAddresses: [_dropoffAddress ?? 'Unknown Dropoff'],
                  tripReq: req,
                  hoursBooked: hoursBooked,
                ),
              );
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to get trip price details'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Hide loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('Error: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Top portion: Map and Top App Bar
          Expanded(
            child: Stack(
              children: [
                // Google Map
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: _cameraCenter, zoom: 15.0),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _markers,
                    polylines: _polylines,
                    onCameraMove: (position) {
                      _cameraCenter = position.target;
                      if (!_isCameraMoving) {
                        setState(() => _isCameraMoving = true);
                      }
                    },
                    onCameraIdle: () {
                      setState(() => _isCameraMoving = false);
                      _handleCameraIdle(_cameraCenter);
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      // Animate to initial camera center once map is ready
                      controller.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: _cameraCenter, zoom: 15.0),
                      ));
                    },
                  ),
                ),

                // Center pin cursor (Always visible as the pickup location)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        child: Text(
                          _isCameraMoving ? 'Move to pick location' : (_centerAddress ?? 'Loading...'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(0, _isCameraMoving ? -8 : 0, 0),
                        child: Icon(
                          Icons.location_pin, 
                          color: (_searchCardKey.currentState?.isDropFocused ?? false) ? Colors.red : Colors.blue, 
                          size: 40
                        ),
                      ),
                      const SizedBox(height: 20), // Offset so pin tip is at center
                    ],
                  ),
                ),

                // Top bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  child: TopBarWidget(),
                ),

                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "zoomInBtn",
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        },
                        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoomOutBtn",
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        },
                        child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom portion: Services and Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ChooseCarBottomSheetBloc, ChooseCarBottomSheetState>(
                  builder: (context, state) => ServicesSectionWidget(
                    state: state,
                    onServiceTap: _handleServiceSelection,
                  ),
                ),
                const SizedBox(height: 20),
                SearchAndSavedCardWidget(
                  key: _searchCardKey,
                  loc: loc,
                  onPickupsUpdated: _onPickupsUpdated,
                  onDestinationSelected: _onDestinationSelected,
                  onFocusChanged: _onSearchFieldFocusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
