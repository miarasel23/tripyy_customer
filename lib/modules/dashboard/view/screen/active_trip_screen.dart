import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../repository/create_trip_repository.dart';
import '../../models/create_rental_trip_model.dart';
import '../../models/trip_status.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_urls.dart';
import '../../../../main.dart';
import '../../../../widgets/cancel_trip_dialog.dart';
import '../../helpers/map_helper.dart';
import '../widget/trip_review_bottom_sheet.dart';
import '../../../../routes/app_routes.dart';

class ActiveTripScreen extends StatefulWidget {
  final String customerUuid;

  const ActiveTripScreen({super.key, required this.customerUuid});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final CreateTripRepository _repo = CreateTripRepository();
  RentalTrip? _activeTrip;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasShownNoTripToast = false;
  Timer? _pollingTimer;

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  // Cached so they are NOT rebuilt on every 5-second setState
  Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];

  bool _isInit = false;
  bool _isRouteExpanded = false;
  bool _isReviewSheetShown = false;

  @override
  void initState() {
    super.initState();
    // NOTE: _fetchActiveTrip() is called in didChangeDependencies
    // to safely access context (AppLocalizations).
    _startPolling();
  }

  Future<void> _showReviewBottomSheet() async {
    if (_activeTrip == null) return;
    
    // Find the accepted driver if any
    RentalDriverBid? driver;
    if (_activeTrip!.drivers.isNotEmpty) {
      driver = _activeTrip!.drivers.firstWhere(
        (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
        orElse: () => _activeTrip!.drivers.first,
      );
    }

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => TripReviewBottomSheet(
        trip: _activeTrip!,
        driver: driver,
        customerUuid: widget.customerUuid,
      ),
    );

    if (result == true) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.bottomNav, (route) => false);
      }
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _fetchActiveTrip();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchActiveTrip();
    });
  }

  Future<void> _fetchActiveTrip() async {
    try {
      final loc = AppLocalizations.of(context);
      final response = await _repo.fetchBids(
        customerUuid: widget.customerUuid,
        langCode: loc.locale.languageCode,
        tripStatus: TripStatus.all,
      );

      if (mounted) {
        setState(() {
          if (response.trips.isNotEmpty) {
            final oldTrip = _activeTrip;
            _activeTrip = response.trips.first;
            if (oldTrip?.uuid != _activeTrip?.uuid) {
              _fetchRoutePolylines();
            }
            
            if (_activeTrip?.tripStatus == TripStatus.completed && _activeTrip?.givenReview == false) {
              if (!_isReviewSheetShown) {
                _isReviewSheetShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showReviewBottomSheet();
                });
              }
            }

            // Stop polling once the trip is in a terminal state — no need to keep hammering the server
            final terminalStatuses = [TripStatus.completed, TripStatus.cancelled];
            if (terminalStatuses.contains(_activeTrip?.tripStatus)) {
              _pollingTimer?.cancel();
            }
            
          } else {
            // No accepted trip found, might have ended
            _errorMessage = loc.translate('no_active_trip_found') == 'no_active_trip_found' ? "No active trip found." : loc.translate('no_active_trip_found');
            if (!_hasShownNoTripToast) {
              _hasShownNoTripToast = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_errorMessage!)),
              );
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRoutePolylines() async {
    if (_activeTrip == null) return;
    final trip = _activeTrip!;
    
    // Rebuild markers and route points here (once per trip change)
    List<LatLng> newRoutePoints = [];
    Set<Marker> newMarkers = {};

    List<LocationModel> allLocations = [];
    allLocations.addAll(trip.pickupLocations);
    allLocations.addAll(trip.dropoffLocations);

    for (int i = 0; i < allLocations.length; i++) {
      final loc = allLocations[i];
      final lat = double.tryParse(loc.latitude ?? '') ?? 23.8103;
      final lng = double.tryParse(loc.longitude ?? '') ?? 90.4125;
      final point = LatLng(lat, lng);
      newRoutePoints.add(point);

      double hue;
      if (i == 0) {
        hue = BitmapDescriptor.hueGreen;
      } else if (i == allLocations.length - 1) {
        hue = BitmapDescriptor.hueRed;
      } else {
        hue = BitmapDescriptor.hueYellow;
      }
      newMarkers.add(
        Marker(
          markerId: MarkerId('loc_$i'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ),
      );
    }

    if (newRoutePoints.length > 1) {
      final polylines = await MapHelper.getRouteBetweenMultipleCoordinates(
        newRoutePoints,
        color: Colors.green,
      );
      if (!mounted) return;
      setState(() {
        _routePoints = newRoutePoints;
        _markers = newMarkers;
        _polylines = polylines;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _routePoints = newRoutePoints;
        _markers = newMarkers;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Action Unavailable"),
            content: Text("Cannot launch $url."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  IconData _getVehicleIcon(String? carType) {
    if (carType == null) return Icons.directions_car;
    final lower = carType.toLowerCase();
    if (lower.contains('bike') || lower.contains('motor')) {
      return Icons.motorcycle;
    } else if (lower.contains('cng') || lower.contains('auto')) {
      return Icons.electric_rickshaw;
    } else if (lower.contains('micro') || lower.contains('van') || lower.contains('bus')) {
      return Icons.airport_shuttle;
    }
    return Icons.directions_car;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13151B) : Colors.white,
      body: _buildBody(isDark, loc),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations loc) {
    if (_isLoading && _activeTrip == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null && _activeTrip == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_filled_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final trip = _activeTrip!;
    final driver = trip.drivers.isNotEmpty ? trip.drivers.first : null;

    // Use pre-computed, cached markers/route points (only rebuilt when trip changes)
    final LatLng initialCameraPosition = _routePoints.isNotEmpty ? _routePoints.first : const LatLng(23.8103, 90.4125);

    return Stack(
      children: [
        // Map
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition,
              zoom: 14.0,
            ),
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              final routePoints = _routePoints;
              if (routePoints.isNotEmpty) {
                if (routePoints.length == 1) {
                  _mapController!.animateCamera(CameraUpdate.newLatLngZoom(routePoints.first, 14.0));
                } else {
                  double minLat = routePoints.first.latitude;
                  double maxLat = routePoints.first.latitude;
                  double minLng = routePoints.first.longitude;
                  double maxLng = routePoints.first.longitude;

                  for (var point in routePoints) {
                    if (point.latitude < minLat) minLat = point.latitude;
                    if (point.latitude > maxLat) maxLat = point.latitude;
                    if (point.longitude < minLng) minLng = point.longitude;
                    if (point.longitude > maxLng) maxLng = point.longitude;
                  }

                  final bounds = LatLngBounds(
                    southwest: LatLng(minLat, minLng),
                    northeast: LatLng(maxLat, maxLng),
                  );

                  // Delay slightly to ensure map is fully loaded before animating bounds
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted && _mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
                    }
                  });
                }
              }
            },
            polylines: _polylines,
            markers: _markers,
          ),
        ),

        // Back Button
        Positioned(
          top: 50,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1E26) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            ),
          ),
        ),

        // Bottom Sheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomSheet(isDark, trip, driver, loc),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(bool isDark, RentalTrip trip, RentalDriverBid? driver, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1E26) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          
          // The merged Route Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRouteProgress(isDark, trip, loc),
          ),
          const SizedBox(height: 16),

          // Driver Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252833) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Driver Image
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: (driver?.profilePicture != null && AppUrls.getImageUrl(driver!.profilePicture) != null)
                            ? NetworkImage(AppUrls.getImageUrl(driver!.profilePicture)!)
                            : null,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        child: (driver?.profilePicture == null || AppUrls.getImageUrl(driver!.profilePicture) == null)
                            ? Icon(Icons.person, color: isDark ? Colors.white70 : Colors.black54)
                            : null,
                      ),
                      Positioned(
                        bottom: -8,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                driver?.averageRating?.toStringAsFixed(1) ?? "0.0",
                                style: GoogleFonts.poppins(color: isDark ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.star, color: isDark ? Colors.black : Colors.white, size: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Name & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver?.name ?? (loc.translate('n_a') == 'n_a' ? "N/A" : loc.translate('n_a')),
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.black12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            driver?.carRegNumber ?? (loc.translate('n_a') == 'n_a' ? "N/A" : loc.translate('n_a')),
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${loc.translate('trips') == 'trips' ? 'trips' : loc.translate('trips')} (${driver?.totalCompletedTrips ?? 0})",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Car Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _activeTrip?.carCategory?.carType ?? "",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          if (driver?.phone != null) {
                            _launchUrl("tel:${driver!.phone}");
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.call, color: isDark ? Colors.white : Colors.black, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              loc.translate('call') == 'call' ? "Call" : loc.translate('call'),
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (trip.tripStatus == TripStatus.rideStarted || trip.tripStatus == TripStatus.inProgress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      width: double.infinity,
                      height: 56, // Standard button height
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    ),
                    // Progress fill
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Dummy progress calculation (update with real data from backend when available)
                          double progress = 0.0;
                          if (trip.tripStatus == TripStatus.rideStarted) progress = 0.2;
                          if (trip.tripStatus == TripStatus.inProgress) progress = 0.6;
                          
                          return AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth * progress,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          );
                        },
                      ),
                    ),
                    // Text
                    Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        loc.translate('in_progress') == 'in_progress' ? "In Progress..." : loc.translate('in_progress'),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Cancel Trip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => _cancelTrip(context, isDark),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('cancel_trip') == 'cancel_trip' ? "Cancel Trip" : loc.translate('cancel_trip'),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _cancelTrip(BuildContext context, bool isDark) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => CancelTripDialog(isDark: isDark),
    );

    if (reason != null && reason.isNotEmpty && _activeTrip != null) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final Color bgColor = isDark ? Colors.white : Colors.black;
      final Color textColor = isDark ? Colors.black : Colors.white;
      try {

        globalScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Cancelling trip...", style: TextStyle(color: textColor)), 
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating
          ),
        );
        final loc = AppLocalizations.of(context);
        final response = await _repo.cancelTrip(
          tripUuid: _activeTrip!.uuid ?? "",
          comment: reason,
          langCode: loc.locale.languageCode,
        );

        globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        globalScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Trip cancelled successfully", style: TextStyle(color: textColor)),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _pollingTimer?.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        globalScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: TextStyle(color: textColor)),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildRouteProgress(bool isDark, RentalTrip trip, AppLocalizations loc) {
    List<LocationModel> allLocations = [];
    allLocations.addAll(trip.pickupLocations);
    allLocations.addAll(trip.dropoffLocations);
    
    if (allLocations.isEmpty) return const SizedBox();

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0 && _isRouteExpanded) {
          // Drag down to minimize
          setState(() {
            _isRouteExpanded = false;
          });
        } else if (details.delta.dy < 0 && !_isRouteExpanded) {
          // Drag up to open
          setState(() {
            _isRouteExpanded = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E26) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(_getVehicleIcon(trip.carCategory?.carType), color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  loc.translate('trip_route') == 'trip_route' ? "Trip Route" : loc.translate('trip_route'),
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Horizontal Progress Bar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(allLocations.length, (index) {
                    final isLast = index == allLocations.length - 1;
                    final isFirst = index == 0;
                    Color dotColor = isFirst ? Colors.green : (isLast ? Colors.red : Colors.yellow.shade700);
                    return Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1C1E26) : Colors.white, width: 2),
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: trip.tripStatus == TripStatus.accepted ? const Alignment(-1.0, 0) : const Alignment(-0.5, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getVehicleIcon(trip.carCategory?.carType), color: isDark ? Colors.black : Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isRouteExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 24),
                        // Vertical List of Locations
                        ...List.generate(allLocations.length, (index) {
                          final isLast = index == allLocations.length - 1;
                          final isFirst = index == 0;
                          Color dotColor = isFirst ? Colors.green : (isLast ? Colors.red : Colors.yellow.shade700);

                          String label;
                          if (isFirst) {
                            label = loc.translate('pickup') == 'pickup' ? "Pickup" : loc.translate('pickup');
                          } else if (isLast) {
                            label = loc.translate('dropoff') == 'dropoff' ? "Dropoff" : loc.translate('dropoff');
                          } else {
                            label = "${loc.translate('stop') == 'stop' ? 'Stop' : loc.translate('stop')} $index";
                          }

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    Icon(isLast ? Icons.location_on : Icons.my_location, color: dotColor, size: 20),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: GoogleFonts.poppins(
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        allLocations[index].address ?? "Unknown",
                                        style: GoogleFonts.poppins(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (!isLast) const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
