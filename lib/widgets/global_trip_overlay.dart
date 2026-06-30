import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modules/dashboard/model/create_rental_trip_model.dart';
import '../modules/dashboard/model/trip_status.dart';
import '../modules/dashboard/repository/create_trip_repository.dart';
import '../store/user_data_store.dart';
import '../core/utils/localization/app_localization.dart';
import '../utils/app_colors.dart';
import '../routes/app_routes.dart';
import '../main.dart';

class GlobalTripOverlay extends StatefulWidget {
  final Widget child;

  const GlobalTripOverlay({super.key, required this.child});

  @override
  State<GlobalTripOverlay> createState() => _GlobalTripOverlayState();
}

class _GlobalTripOverlayState extends State<GlobalTripOverlay> {
  final CreateTripRepository _repo = CreateTripRepository();
  RentalTrip? _activeTrip;
  Timer? _pollingTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
    globalRouteObserver.routeNotifier.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    globalRouteObserver.routeNotifier.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  void _startPolling() {
    _fetchActiveTrip(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchActiveTrip();
    });
  }

  Future<void> _fetchActiveTrip() async {
    final token = UserDataStore.accessToken;
    if (token == null || token.isEmpty) {
      final currentRoute = globalRouteObserver.currentRoute;
      if (currentRoute != AppRoutes.splash && currentRoute != AppRoutes.numberInput && currentRoute != AppRoutes.otp) {
        UserDataStore.clearAllData();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.numberInput, (route) => false);
        }
      }
      return;
    }

    final customerUuid = UserDataStore.userData?.data?.user?.uuid;
    if (customerUuid == null || customerUuid.isEmpty) return;

    try {
      final loc = AppLocalizations.of(context);
      final langCode = loc.locale.languageCode;
      
      final response = await _repo.fetchBids(
        customerUuid: customerUuid,
        langCode: langCode,
        tripStatus: TripStatus.all,
      );

      if (mounted) {
        setState(() {
          if (response.trips.isNotEmpty) {
            // BUG FIX: Search for an active trip by status rather than blindly taking first
            final activeStatuses = [
              TripStatus.rideStarted,
              TripStatus.firstCompleted,
            ];
            final found = response.trips.where((t) => activeStatuses.contains(t.tripStatus)).toList();
            _activeTrip = found.isNotEmpty ? found.first : null;
          } else {
            _activeTrip = null;
          }
        });
      }
    } catch (e) {
      // Silently ignore polling errors
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      final dt = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final amPm = dt.hour >= 12 ? "PM" : "AM";
      final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      return "${dt.day} ${months[dt.month - 1]}, ${dt.year} - $hour12:$minute $amPm";
    } catch (e) {
      return dateStr;
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
    // Determine current route name, preferring the ModalRoute (available immediately) and falling back to the observer
    final routeName = ModalRoute.of(context)?.settings.name ?? globalRouteObserver.currentRoute;
    // Hide overlay on active trip screen (exact match or any sub‑route) to make this page fully invisible
    final hideOverlay = routeName != null && (routeName == AppRoutes.activeTrip || routeName.startsWith('${AppRoutes.activeTrip}'));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_activeTrip != null && !hideOverlay)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _buildOverlayContent(context),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    final trip = _activeTrip!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    List<LocationModel> allLocations = [];
    if (trip.tripStatus == TripStatus.firstCompleted) {
      allLocations.addAll(trip.dropoffLocations);
      allLocations.addAll(trip.pickupLocations);
    } else {
      allLocations.addAll(trip.pickupLocations);
      allLocations.addAll(trip.dropoffLocations);
    }

    if (allLocations.isEmpty) return const SizedBox.shrink();

    final activeBgColor = Colors.white;
    final activeTextColor = Colors.black;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0 && _isExpanded) {
            setState(() { _isExpanded = false; });
          } else if (details.delta.dy > 0 && !_isExpanded) {
            setState(() { _isExpanded = true; });
          }
        },
        onTap: () {
          // Navigate to active trip screen when tapped
          final customerUuid = UserDataStore.userData?.data?.user?.uuid;
          if (customerUuid != null) {
            globalNavigatorKey.currentState?.pushNamed(AppRoutes.activeTrip, arguments: customerUuid);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1E26) : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: SafeArea(
            top: true,
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip.tripStatus == TripStatus.firstCompleted ? "Leg 1 Complete" : "In Progress",
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final customerUuid = UserDataStore.userData?.data?.user?.uuid;
                        if (customerUuid != null) {
                          globalNavigatorKey.currentState?.pushNamed(AppRoutes.activeTrip, arguments: customerUuid);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        loc.translate('view') == 'view' ? "View" : loc.translate('view'),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white),
                      ),
                    ),
                  ],
                ),
                
                if (trip.serviceName != 'RIDE_SHARE' && trip.serviceName != 'RIDE_SHOW')
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup Date & Time",
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.white54 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDate(trip.tripStatus == TripStatus.firstCompleted ? trip.endDatetime : trip.startDatetime),
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
                                  _formatDate(trip.endDatetime),
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
                
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
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
                      alignment: trip.tripStatus == TripStatus.firstCompleted ? const Alignment(0, 0) : const Alignment(-0.5, 0),
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
                  child: _isExpanded
                      ? Column(
                          children: [
                            const SizedBox(height: 24),
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
                                              color: Colors.grey.withValues(alpha: 0.3),
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
        ),
      ),
    );
  }
}
