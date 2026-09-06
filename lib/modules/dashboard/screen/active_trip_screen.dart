import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controller/active_trip_bloc.dart';
import '../controller/active_trip_event.dart';
import '../controller/active_trip_state.dart';
import '../helper/active_trip_helper.dart';
import '../model/create_rental_trip_model.dart';
import '../model/trip_status.dart';
import '../helper/map_helper.dart';
import '../widget/trip_review_bottom_sheet.dart';
import '../widget/active_trip_driver_card.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/cancel_trip_dialog.dart';
import '../../../widgets/global_trip_overlay.dart';
import '../../../main.dart';

class ActiveTripScreen extends StatefulWidget {
  final String customerUuid;
  final String? tripUuid;

  const ActiveTripScreen({super.key, required this.customerUuid, this.tripUuid});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  RentalTrip? _activeTrip;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];

  bool _isRouteExpanded = false;
  bool _isReviewSheetShown = false;
  Marker? _driverMarker;
  double _driverRotation = 0.0;
  bool _isNavigatingToHome = false;

  void _clearLocalTripState() {
    if (mounted) {
      setState(() {
        _activeTrip = null;
        _polylines.clear();
        _markers.clear();
        _driverMarker = null;
      });
    } else {
      _activeTrip = null;
      _polylines.clear();
      _markers.clear();
      _driverMarker = null;
    }
  }

  void _returnToHomePreservingState({String? message}) {
    if (_isNavigatingToHome) return;
    _isNavigatingToHome = true;

    try {
      context.read<ActiveTripBloc>().add(StopActiveTripPolling());
    } catch (_) {}

    final tripUuid = widget.tripUuid ?? _activeTrip?.uuid;
    if (tripUuid != null && tripUuid.isNotEmpty) {
      GlobalTripOverlay.markTripCancelled(tripUuid);
    }
    GlobalTripOverlay.clearActiveTrip();
    _clearLocalTripState();

    if (message != null && message.isNotEmpty) {
      globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      globalScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    final nav = globalNavigatorKey.currentState ?? (mounted ? Navigator.of(context) : null);
    if (nav != null) {
      if (nav.canPop()) {
        nav.popUntil((route) => route.settings.name == AppRoutes.bottomNav || route.isFirst);
      } else {
        nav.pushNamedAndRemoveUntil(
          AppRoutes.bottomNav,
          (route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      context.read<ActiveTripBloc>().add(
        StartActiveTripPolling(
          customerUuid: widget.customerUuid,
          languageCode: loc.locale.languageCode,
          tripUuid: widget.tripUuid,
        ),
      );
    });
  }

  @override
  void dispose() {
    context.read<ActiveTripBloc>().add(StopActiveTripPolling());
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutePolylinesForTrip(RentalTrip trip) async {
    List<LatLng> newRoutePoints = [];
    Set<Marker> newMarkers = {};

    final bool isReturnTrip = trip.serviceName?.toUpperCase() == 'RETURN';
    final bool isFirstCompleted = trip.tripStatus == TripStatus.firstCompleted || trip.tripStatus?.toUpperCase() == 'FIRST_COMPLETED';

    List<LocationModel> allLocations = [];
    if (isReturnTrip && isFirstCompleted) {
      allLocations.addAll(trip.dropoffLocations);
      allLocations.addAll(trip.pickupLocations);
    } else {
      allLocations.addAll(trip.pickupLocations);
      allLocations.addAll(trip.dropoffLocations);
    }

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
      _fitMapToBounds(newRoutePoints);
    } else {
      if (!mounted) return;
      setState(() {
        _routePoints = newRoutePoints;
        _markers = newMarkers;
        _polylines = {};
      });
    }
  }

  void _fitMapToBounds(List<LatLng> points) {
    ActiveTripHelper.fitMapToBounds(points, _mapController, isMounted: mounted);
  }

  Future<void> _showReviewBottomSheet(RentalTrip trip) async {
    RentalDriverBid? driver;
    if (trip.drivers.isNotEmpty) {
      driver = trip.drivers.firstWhere(
        (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
        orElse: () => trip.drivers.first,
      );
    }

    GlobalTripOverlay.isReviewModalOpen = true;
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (ctx) => TripReviewBottomSheet(
          trip: trip,
          driver: driver,
          customerUuid: widget.customerUuid,
        ),
      );
    } finally {
      GlobalTripOverlay.isReviewModalOpen = false;
    }

    GlobalTripOverlay.clearActiveTrip();
    GlobalTripOverlay.markTripReviewed(trip.uuid);

    if (mounted) {
      final updatedTrip = trip.copyWith(givenReview: true);
      context.read<ActiveTripBloc>().add(UpdateActiveTripLocalReview(updatedTrip));
      _returnToHomePreservingState();
    }
  }

  Future<void> _cancelTrip(BuildContext context, RentalTrip trip, bool isDark) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => CancelTripDialog(isDark: isDark),
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      final loc = AppLocalizations.of(context);
      context.read<ActiveTripBloc>().add(
        CancelActiveTrip(
          tripUuid: trip.uuid ?? "",
          comment: reason,
          languageCode: loc.locale.languageCode,
        ),
      );
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    return ActiveTripHelper.calculateBearing(start, end);
  }

  Future<void> _updateDriverMarker(RentalTrip trip, double? lat, double? lng) async {
    if (lat == null || lng == null) {
      if (_driverMarker != null) {
        setState(() {
          _markers.remove(_driverMarker);
          _driverMarker = null;
        });
      }
      return;
    }

    final bool isFirstLoad = _driverMarker == null;
    final position = LatLng(lat, lng);
    final carType = trip.carCategory?.carType;

    if (_driverMarker != null) {
      final prevPos = _driverMarker!.position;
      if (prevPos.latitude != position.latitude || prevPos.longitude != position.longitude) {
        _driverRotation = _calculateBearing(prevPos, position);
      }
    }

    final lower = carType?.toLowerCase() ?? '';
    final bool isBike = lower.contains('bike') || lower.contains('motor');
    final Color vehicleColor = isBike ? const Color(0xFFF44336) : const Color(0xFF4CAF50);

    final BitmapDescriptor icon = await _getMarkerIconFromIconData(
      carType,
      vehicleColor,
      80.0,
    );

    final newMarker = Marker(
      markerId: const MarkerId('driver_location'),
      position: position,
      icon: icon,
      rotation: _driverRotation,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(title: trip.drivers.isNotEmpty ? trip.drivers.first.name : "Driver"),
    );

    if (mounted) {
      setState(() {
        if (_driverMarker != null) {
          _markers.removeWhere((m) => m.markerId == const MarkerId('driver_location'));
        }
        _driverMarker = newMarker;
        _markers.add(newMarker);
      });

      if (isFirstLoad && _mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 16.5,
            tilt: 35.0,
          ),
        ));
      }
    }
  }

  Future<BitmapDescriptor> _getMarkerIconFromIconData(String? carType, Color color, double size) async {
    return ActiveTripHelper.getMarkerIconFromIconData(carType, color, size);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final bool isRideShare = _activeTrip?.serviceName?.toUpperCase() == "RIDE_SHARE";
    final String currentStatus = _activeTrip?.tripStatus?.toUpperCase() ?? "";

    final rideShareActiveStatuses = [
      "ACCEPTED",
      "BOOKED",
      "ARRIVED_PICKUP_LOCATION",
      "RIDE_STARTED",
      "IN_PROGRESS",
      "FIRST_COMPLETED",
      "ON_GOING",
      TripStatus.accepted.toUpperCase(),
      TripStatus.booked.toUpperCase(),
      TripStatus.arrivedPickupLocation.toUpperCase(),
      TripStatus.rideStarted.toUpperCase(),
      TripStatus.inProgress.toUpperCase(),
      TripStatus.firstCompleted.toUpperCase(),
    ];

    final inProgressStatuses = [
      "IN_PROGRESS",
      "RIDE_STARTED",
      "FIRST_COMPLETED",
      "ARRIVED_PICKUP_LOCATION",
      "ON_GOING",
      TripStatus.inProgress.toUpperCase(),
      TripStatus.rideStarted.toUpperCase(),
      TripStatus.firstCompleted.toUpperCase(),
      TripStatus.arrivedPickupLocation.toUpperCase(),
    ];

    bool shouldLockNavigation = false;
    final bool isFirstCompleted = currentStatus == "FIRST_COMPLETED" || currentStatus == TripStatus.firstCompleted.toUpperCase();
    if (isFirstCompleted) {
      shouldLockNavigation = false;
    } else if (isRideShare && rideShareActiveStatuses.contains(currentStatus)) {
      shouldLockNavigation = true;
    } else if (!isRideShare && inProgressStatuses.contains(currentStatus)) {
      shouldLockNavigation = true;
    }

    void showLockedNavigationNotice() {
      final isBn = loc.locale.languageCode == 'bn';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? "রাইডটি চলমান রয়েছে। সম্পন্ন না হওয়া পর্যন্ত অন্য পেজে যাওয়া যাবে না।"
                : "Ride is active. You will remain on this screen until completed.",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return PopScope(
      canPop: !shouldLockNavigation,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && shouldLockNavigation) {
          showLockedNavigationNotice();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF13151B) : Colors.white,
        body: BlocListener<ActiveTripBloc, ActiveTripState>(
        listener: (context, state) {
          if (state is ActiveTripSuccess) {
            final trip = state.activeTrip;
            final oldTrip = _activeTrip;
            _activeTrip = trip;

            if (oldTrip?.uuid != trip.uuid) {
              _fetchRoutePolylinesForTrip(trip);
            }

            _updateDriverMarker(trip, state.driverLatitude, state.driverLongitude);

            final statusUpper = trip.tripStatus?.toUpperCase() ?? "";
            final isCancelled = statusUpper == TripStatus.cancelled.toUpperCase() ||
                                statusUpper == TripStatus.givenBidCancelled.toUpperCase() ||
                                statusUpper == TripStatus.acceptedBidCancelled.toUpperCase() ||
                                statusUpper == TripStatus.noShow.toUpperCase();

            final hasActiveDriver = trip.drivers.any(
              (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
            );
            final hasCancelledBid = trip.drivers.any(
              (d) => d.bidStatus == 'ACCEPTED_BID_CANCELLED' || d.bidStatus == 'CANCELLED',
            );
            final isDriverCancelled = trip.drivers.isNotEmpty && !hasActiveDriver && hasCancelledBid;

            if (isCancelled || isDriverCancelled) {
              final isBn = loc.locale.languageCode == 'bn';
              final cancelMsg = isBn ? "ড্রাইভার ট্রিপটি বাতিল করেছেন।" : "Driver has cancelled the trip.";
              _returnToHomePreservingState(message: cancelMsg);
              return;
            }

            if (trip.tripStatus == TripStatus.completed && trip.givenReview != true) {
              if (!_isReviewSheetShown) {
                _isReviewSheetShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showReviewBottomSheet(trip);
                });
              }
            }
          } else if (state is ActiveTripCancelledSuccess) {
            final isBn = loc.locale.languageCode == 'bn';
            final cancelMsg = isBn ? "ট্রিপ সফলভাবে বাতিল করা হয়েছে।" : state.message;
            _returnToHomePreservingState(message: cancelMsg);
          } else if (state is NoActiveTrip) {
            final isBn = loc.locale.languageCode == 'bn';
            final cancelMsg = isBn ? "ড্রাইভার ট্রিপটি বাতিল করেছেন।" : state.message;
            _returnToHomePreservingState(message: cancelMsg);
          } else if (state is ActiveTripFailure) {
            UiUtils.showAppSnackBar(context, state.error, type: 'error');
          }
        },
        child: BlocBuilder<ActiveTripBloc, ActiveTripState>(
          builder: (context, state) {
            if (state is ActiveTripLoading && _activeTrip == null) {
              return Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black));
            }

            if (state is ActiveTripFailure && _activeTrip == null) {
              return _buildErrorScreen(state.error);
            }

            if (state is NoActiveTrip) {
              return Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black));
            }

            if (_activeTrip == null) {
              return Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black));
            }

            final trip = _activeTrip!;
            final driver = trip.drivers.isNotEmpty
                ? trip.drivers.firstWhere(
                    (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
                    orElse: () => trip.drivers.first)
                : null;

            final LatLng initialCameraPosition = _routePoints.isNotEmpty ? _routePoints.first : const LatLng(23.8103, 90.4125);

            return Stack(
              children: [
                // Map View
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
                      if (_routePoints.isNotEmpty) {
                        _fitMapToBounds(_routePoints);
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
                    onTap: () {
                      if (shouldLockNavigation) {
                        showLockedNavigationNotice();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
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

                // Bottom Panel Details
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomSheet(isDark, trip, driver, loc),
                ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_filled_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }

  Widget _buildBottomSheet(bool isDark, RentalTrip trip, RentalDriverBid? driver, AppLocalizations loc) {
    double? driverLat;
    double? driverLng;
    final state = context.read<ActiveTripBloc>().state;
    if (state is ActiveTripSuccess) {
      driverLat = state.driverLatitude;
      driverLng = state.driverLongitude;
    }

    int? etaMinutes;
    String? etaLabel;
    final isBn = loc.locale.languageCode == 'bn';
    final String currentStatus = trip.tripStatus?.toUpperCase() ?? "";
    final bool isStartedOrFirstCompleted = currentStatus == "RIDE_STARTED" || currentStatus == "FIRST_COMPLETED" || currentStatus == "ON_GOING";
    final bool isAcceptedOrInProgress = currentStatus == "ACCEPTED" || currentStatus == "IN_PROGRESS" || currentStatus == "BOOKED" || currentStatus == "ARRIVED_PICKUP_LOCATION";
    final bool isReturnTrip = trip.serviceName?.toUpperCase() == 'RETURN';
    final bool isFirstCompleted = trip.tripStatus == TripStatus.firstCompleted || trip.tripStatus?.toUpperCase() == 'FIRST_COMPLETED';
    final currentPickupLocs = (isReturnTrip && isFirstCompleted) ? trip.dropoffLocations : trip.pickupLocations;
    final currentDropoffLocs = (isReturnTrip && isFirstCompleted) ? trip.pickupLocations : trip.dropoffLocations;

    if (isStartedOrFirstCompleted) {
      if (driverLat != null && driverLng != null && currentDropoffLocs.isNotEmpty) {
        final destLat = double.tryParse(currentDropoffLocs.first.latitude ?? '');
        final destLng = double.tryParse(currentDropoffLocs.first.longitude ?? '');
        if (destLat != null && destLng != null) {
          final double distanceInMeters = Geolocator.distanceBetween(driverLat, driverLng, destLat, destLng);
          etaMinutes = (distanceInMeters / 300.0).ceil().clamp(1, 120);
          etaLabel = isBn
              ? "গন্তব্যে পৌঁছাচ্ছেন ($etaMinutes minute)"
              : "ARRIVING AT DESTINATION ($etaMinutes ${etaMinutes == 1 ? 'min' : 'mins'})";
        } else {
          etaLabel = isBn ? "গন্তব্যের দিকে যাওয়া হচ্ছে" : "ARRIVING AT DESTINATION";
        }
      } else {
        etaLabel = isBn ? "গন্তব্যের দিকে যাওয়া হচ্ছে" : "ARRIVING AT DESTINATION";
      }
    } else if (isAcceptedOrInProgress) {
      if (trip.tripStatus == TripStatus.arrivedPickupLocation) {
        etaLabel = isBn ? "ড্রাইভার পিকআপ লোকেশনে পৌঁছেছেন" : "DRIVER ARRIVED AT PICKUP LOCATION";
      } else if (driverLat != null && driverLng != null && currentPickupLocs.isNotEmpty) {
        final pickLat = double.tryParse(currentPickupLocs.first.latitude ?? '');
        final pickLng = double.tryParse(currentPickupLocs.first.longitude ?? '');
        if (pickLat != null && pickLng != null) {
          final double distanceInMeters = Geolocator.distanceBetween(driverLat, driverLng, pickLat, pickLng);
          etaMinutes = (distanceInMeters / 300.0).ceil().clamp(1, 120);
          etaLabel = isBn
              ? "পিকআপের দিকে আসছেন ($etaMinutes minute)"
              : "DRIVER ARRIVING AT PICKUP LOCATION ($etaMinutes ${etaMinutes == 1 ? 'min' : 'mins'})";
        } else {
          etaLabel = isBn ? "ড্রাইভার পিকআপের দিকে আসছেন" : "DRIVER ARRIVING AT PICKUP LOCATION";
        }
      } else {
        etaLabel = isBn ? "ড্রাইভার পিকআপের দিকে আসছেন" : "DRIVER ARRIVING AT PICKUP LOCATION";
      }
    }

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRouteProgress(isDark, trip, loc),
          ),
          const SizedBox(height: 12),

          if (etaLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.black12 : Colors.white10,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 10 : 15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: isDark ? Colors.black : Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    etaLabel,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Driver Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ActiveTripDriverCard(
              trip: trip,
              driver: driver,
              customerUuid: widget.customerUuid,
              isDark: isDark,
              isBn: isBn,
              loc: loc,
            ),
          ),

          const SizedBox(height: 24),

          // Action Button Area
          if (trip.tripStatus == TripStatus.rideStarted || trip.tripStatus == TripStatus.firstCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
                    ),
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double progress = 0.4;
                          if (trip.tripStatus == TripStatus.firstCompleted) progress = 0.75;
                          
                          return AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth * progress,
                              color: isDark ? Colors.white.withAlpha(60) : Colors.black.withAlpha(50),
                            ),
                          );
                        },
                      ),
                    ),
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
            ),
          if (trip.tripStatus != TripStatus.completed &&
              trip.tripStatus != TripStatus.cancelled &&
              trip.tripStatus != TripStatus.rideStarted &&
              trip.tripStatus != TripStatus.firstCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => _cancelTrip(context, trip, isDark),
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

  Widget _buildRouteProgress(bool isDark, RentalTrip trip, AppLocalizations loc) {
    final bool isReturnTrip = trip.serviceName?.toUpperCase() == 'RETURN';
    final bool isFirstCompleted = trip.tripStatus == TripStatus.firstCompleted || trip.tripStatus?.toUpperCase() == 'FIRST_COMPLETED';

    List<LocationModel> allLocations = [];
    if (isReturnTrip && isFirstCompleted) {
      allLocations.addAll(trip.dropoffLocations);
      allLocations.addAll(trip.pickupLocations);
    } else {
      allLocations.addAll(trip.pickupLocations);
      allLocations.addAll(trip.dropoffLocations);
    }

    final isBn = loc.locale.languageCode == 'bn';
    final carName = ActiveTripHelper.formatCarType(trip.carCategory?.carType);
    final serviceName = ActiveTripHelper.formatServiceName(trip.serviceName, hoursBooked: trip.hoursBooked);
    final locText = isBn
        ? "${ActiveTripHelper.toBanglaDigits(allLocations.length.toString())}টি লোকেশন"
        : "${allLocations.length} locations";

    final routeSubtitle = carName.isNotEmpty
        ? "$carName - $serviceName - $locText"
        : "$serviceName - $locText";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isRouteExpanded = !_isRouteExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('route_progress') == 'route_progress' ? "Route Progress" : loc.translate('route_progress'),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        routeSubtitle,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isRouteExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

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
                child: Icon(ActiveTripHelper.getVehicleIcon(trip.carCategory?.carType), color: isDark ? Colors.black : Colors.white, size: 16),
              ),
            ),
          ],
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isRouteExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    if (trip.startDatetime != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Time",
                                    style: GoogleFonts.poppins(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ActiveTripHelper.formatDate(trip.tripStatus == TripStatus.firstCompleted ? trip.endDatetime : trip.startDatetime),
                                    style: GoogleFonts.poppins(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (trip.serviceName == 'RETURN' && trip.tripStatus != TripStatus.firstCompleted)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Return Time",
                                      style: GoogleFonts.poppins(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      ActiveTripHelper.formatDate(trip.endDatetime),
                                      style: GoogleFonts.poppins(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
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
    );
  }
}
