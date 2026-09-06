import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../../store/user_data_store.dart';
import '../../../../utils/app_urls.dart';
import '../../searchLocation/repository/search_location_repository.dart';
import '../repository/create_trip_repository.dart';
import '../model/create_rental_trip_model.dart';
import '../model/trip_status.dart';
import 'active_trip_event.dart';
import 'active_trip_state.dart';

import '../helper/customer_location_tracker.dart';

class ActiveTripBloc extends Bloc<ActiveTripEvent, ActiveTripState> {
  final CreateTripRepository _repo = CreateTripRepository();
  Timer? _pollingTimer;
  String? _currentTripUuid;

  ActiveTripBloc() : super(ActiveTripInitial()) {
    on<FetchActiveTrip>((event, emit) async {
      try {
        final targetTripUuid = (event.tripUuid != null && event.tripUuid!.trim().isNotEmpty)
            ? event.tripUuid!.trim()
            : _currentTripUuid;

        RentalBidListResponse response;
        if (targetTripUuid != null && targetTripUuid.length >= 36) {
          try {
            response = await _repo.fetchSingleTrip(
              customerUuid: event.customerUuid,
              langCode: event.languageCode,
              tripUuid: targetTripUuid,
              tripStatus: 'ALL',
            );
          } catch (_) {
            response = await _repo.fetchBids(
              customerUuid: event.customerUuid,
              langCode: event.languageCode,
              tripStatus: TripStatus.all,
            );
          }
        } else {
          response = await _repo.fetchBids(
            customerUuid: event.customerUuid,
            langCode: event.languageCode,
            tripStatus: TripStatus.all,
          );
        }

        if (response.trips.isNotEmpty) {
          final mostRecentTrip = response.trips.first;
          if (mostRecentTrip.uuid != null && mostRecentTrip.uuid!.length >= 36) {
            _currentTripUuid = mostRecentTrip.uuid;
          }
          final cancelledStatuses = [
            TripStatus.cancelled,
            TripStatus.givenBidCancelled,
            TripStatus.acceptedBidCancelled,
            TripStatus.noShow,
          ];
          if (cancelledStatuses.contains(mostRecentTrip.tripStatus)) {
            _pollingTimer?.cancel();
            emit(NoActiveTrip("Trip has been cancelled"));
            return;
          }

          if (mostRecentTrip.drivers.isNotEmpty) {
            final hasActiveDriver = mostRecentTrip.drivers.any(
              (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
            );
            final hasCancelledBid = mostRecentTrip.drivers.any(
              (d) => d.bidStatus == 'ACCEPTED_BID_CANCELLED' || d.bidStatus == 'CANCELLED',
            );
            if (!hasActiveDriver && hasCancelledBid) {
              _pollingTimer?.cancel();
              emit(NoActiveTrip("Driver has cancelled the trip"));
              return;
            }
          }

          final activeStatuses = [
            TripStatus.accepted,
            TripStatus.booked,
            TripStatus.arrivedPickupLocation,
            TripStatus.rideStarted,
            TripStatus.inProgress,
            TripStatus.firstCompleted,
            TripStatus.completed,
          ];
          final found = response.trips.where((t) => activeStatuses.contains(t.tripStatus)).toList();

          if (found.isNotEmpty) {
            final activeTrip = found.first;

            double? driverLat;
            double? driverLng;

            final isRideShare = activeTrip.serviceName?.toUpperCase() == 'RIDE_SHARE';
            final trackableStatuses = [
              TripStatus.accepted,
              TripStatus.booked,
              TripStatus.arrivedPickupLocation,
              TripStatus.rideStarted,
              TripStatus.inProgress,
              TripStatus.firstCompleted,
            ];

            bool isTrackable = false;
            if (trackableStatuses.contains(activeTrip.tripStatus)) {
              if (isRideShare) {
                // Rideshare: always show driver when status is trackable
                isTrackable = true;
              } else {
                // Non-rideshare: statuses where the ride has physically commenced
                final activelyRidingStatuses = [
                  TripStatus.arrivedPickupLocation,
                  TripStatus.rideStarted,
                  TripStatus.inProgress,
                  TripStatus.firstCompleted,
                ];

                if (activelyRidingStatuses.contains(activeTrip.tripStatus)) {
                  // Trip already started: always show driver until completed
                  isTrackable = true;
                } else {
                  // Trip accepted/booked but not yet started: check 2-hour rule
                  if (activeTrip.startDatetime != null && activeTrip.startDatetime!.isNotEmpty) {
                    try {
                      String normalized = activeTrip.startDatetime!.trim();
                      if (!normalized.contains('Z') && !normalized.contains('+') && normalized.length >= 19) {
                        normalized = "${normalized.replaceAll(' ', 'T')}+06:00";
                      }
                      final startTime = DateTime.parse(normalized);
                      final now = DateTime.now();
                      final diffMinutes = startTime.difference(now).inMinutes;
                      // Show driver only if start time is within 2 hours (120 minutes) from now
                      // If start is in the future beyond 2 hours => hidden; if past or within 2h => visible
                      isTrackable = diffMinutes <= 120;
                    } catch (e) {
                      isTrackable = true;
                    }
                  } else {
                    // No start time defined: show driver by default
                    isTrackable = true;
                  }
                }
              }
            }

            if (isTrackable) {
              // 1. Save customer's current location asynchronously
              unawaited(_trackCustomerLocation(event.customerUuid, event.languageCode));

              // 2. Fetch driver's current tracking location
              RentalDriverBid? activeDriver;
              if (activeTrip.drivers.isNotEmpty) {
                try {
                  activeDriver = activeTrip.drivers.firstWhere(
                    (d) => d.bidStatus == 'ACCEPTED' || d.bidStatus == 'COMPLETED',
                  );
                } catch (e) {
                  activeDriver = activeTrip.drivers.first;
                }
              }

              if (activeDriver != null && activeDriver.driverUuid != null) {
                final driverPos = await _getDriverLocation(activeDriver.driverUuid, event.languageCode);
                if (driverPos != null) {
                  driverLat = driverPos['latitude'];
                  driverLng = driverPos['longitude'];
                }
              }
            }

            emit(ActiveTripSuccess(
              activeTrip,
              driverLatitude: driverLat,
              driverLongitude: driverLng,
            ));

            // Stop polling once terminal state is reached
            final terminalStatuses = [
              TripStatus.completed,
              TripStatus.cancelled,
              TripStatus.givenBidCancelled,
              TripStatus.acceptedBidCancelled,
              TripStatus.noShow,
            ];
            if (terminalStatuses.contains(activeTrip.tripStatus)) {
              _pollingTimer?.cancel();
            }
          } else {
            _pollingTimer?.cancel();
            emit(NoActiveTrip("No active trip found."));
          }
        } else {
          _pollingTimer?.cancel();
          emit(NoActiveTrip("No active trip found."));
        }
      } catch (e) {
        final isConnectionError = e.toString().contains('Connection closed') || 
                                   e.toString().contains('ClientException') ||
                                   e.toString().contains('SocketException') ||
                                   e.toString().contains('HttpException');
        if (!isConnectionError) {
          emit(ActiveTripFailure(e.toString().replaceAll('Exception: ', '')));
        }
      }
    });

    on<StartActiveTripPolling>((event, emit) {
      _pollingTimer?.cancel();
      add(FetchActiveTrip(
        customerUuid: event.customerUuid,
        languageCode: event.languageCode,
        tripUuid: event.tripUuid,
      ));
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        add(FetchActiveTrip(
          customerUuid: event.customerUuid,
          languageCode: event.languageCode,
          tripUuid: event.tripUuid,
        ));
      });
    });

    on<StopActiveTripPolling>((event, emit) {
      _pollingTimer?.cancel();
    });

    on<CancelActiveTrip>((event, emit) async {
      try {
        final response = await _repo.cancelTrip(
          tripUuid: event.tripUuid,
          comment: event.comment,
          langCode: event.languageCode,
        );
        _pollingTimer?.cancel();
        emit(ActiveTripCancelledSuccess(response['message'] ?? "Trip cancelled successfully."));
      } catch (e) {
        emit(ActiveTripFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateActiveTripLocalReview>((event, emit) {
      if (state is ActiveTripSuccess) {
        emit(ActiveTripSuccess(
          event.updatedTrip,
          driverLatitude: (state as ActiveTripSuccess).driverLatitude,
          driverLongitude: (state as ActiveTripSuccess).driverLongitude,
        ));
      }
    });
  }

  Future<void> _trackCustomerLocation(String customerUuid, String langCode) async {
    await CustomerLocationTracker.instance.trackCustomerLocationIfNeeded(
      customerUuid: customerUuid,
      langCode: langCode,
      minDistanceMeters: 5.0,
    );
  }

  Future<Map<String, double>?> _getDriverLocation(String? driverUuid, String langCode) async {
    if (driverUuid == null || driverUuid.isEmpty) {
      return null;
    }
    try {
      final url = Uri.parse(AppUrls.customerDriverTrackGet);
      final token = await UserDataStore.getAccessToken();
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final body = {
        "platform": "android",
        "language_code": langCode,
        "action_when": "track_location_get",
        "driver_uuid": driverUuid,
      };
      
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == true && decoded['data'] != null) {
          final List dataList = decoded['data'];
          if (dataList.isNotEmpty) {
            final latestTrack = dataList.first;
            if (latestTrack['geolocation'] != null) {
              final geo = latestTrack['geolocation'];
              final lat = double.tryParse(geo['latitude']?.toString() ?? '');
              final lng = double.tryParse(geo['longitude']?.toString() ?? '');
              if (lat != null && lng != null) {
                return {"latitude": lat, "longitude": lng};
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
