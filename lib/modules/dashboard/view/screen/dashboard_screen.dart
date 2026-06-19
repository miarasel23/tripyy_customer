import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../modules/searchLocation/models/search_location_model.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';

// Import extracted widgets
import '../widget/top_bar_widget.dart';
import '../widget/search_and_saved_card_widget.dart';
import '../widget/services_section_widget.dart';

/// Google Maps API Key (same key used in AndroidManifest / AppDelegate)
const String _kGoogleApiKey = 'AIzaSyAYf-MPMgwHhXT2h-kKSchXFH5GiwuURcw';

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

  /// Drop location set from the search card
  LatLng? _dropLatLng;

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
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final address = [p.street, p.subLocality, p.locality, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
          setState(() {
            _centerAddress = address;
          });

          // Always update the pickup text from the center pin
          _searchCardKey.currentState?.updatePickupText(address);
        }
      } catch (_) {}

      // If a destination is set, continuously redraw the route from the new camera center
      if (_dropLatLng != null) {
        _drawRoute(position, _dropLatLng!);
      }
    });
  }

  /// Called when the user selects a pickup from the search list
  void _onPickupSelected(SearchLocationData location) {
    if (location.latitude == null || location.longitude == null) return;
    final latLng = LatLng(location.latitude!, location.longitude!);

    // Simply pan the camera to the selected pickup location.
    // The center pin remains, and onCameraIdle will trigger update & route redraw.
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: latLng, zoom: 15.0),
    ));
  }

  /// Called when the user selects a destination from the search list
  void _onDestinationSelected(SearchLocationData location) {
    if (location.latitude == null || location.longitude == null) return;
    final latLng = LatLng(location.latitude!, location.longitude!);

    setState(() {
      _dropLatLng = latLng;
      _rebuildMarkers();
    });

    _drawRoute(_cameraCenter, latLng);

    // Zoom out to show the route, but strictly keep the camera target on the pickup location!
    // Otherwise, the map center (pickup) would change.
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _cameraCenter, zoom: 11.0),
    ));
  }

  void _rebuildMarkers() {
    final markers = <Marker>{};

    if (_dropLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Drop Off'),
      ));
    }

    _markers = markers;
  }

  Future<void> _drawRoute(LatLng from, LatLng to) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _kGoogleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty && mounted) {
      final coords = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: coords,
            color: Colors.blue,
            width: 5,
          ),
        };
      });
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
                        child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
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
                  builder: (context, state) => ServicesSectionWidget(state: state),
                ),
                const SizedBox(height: 20),
                SearchAndSavedCardWidget(
                  key: _searchCardKey,
                  loc: loc,
                  onPickupSelected: _onPickupSelected,
                  onDestinationSelected: _onDestinationSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
