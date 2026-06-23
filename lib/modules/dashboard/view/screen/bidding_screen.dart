import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../models/create_rental_trip_model.dart';
import '../../repository/create_trip_repository.dart';
import '../../../../widgets/radar_animation.dart';
import '../../../../utils/app_urls.dart';
import '../../../../widgets/full_screen_image_gallery.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../../../main.dart';
import '../../../../widgets/cancel_trip_dialog.dart';
import '../widget/bidding_searching_state.dart';
import '../widget/bidding_trip_details_card.dart';
import '../widget/bidding_list_widget.dart';

class BiddingScreen extends StatefulWidget {
  final String customerUuid;

  const BiddingScreen({super.key, required this.customerUuid});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  late Timer _pollingTimer;
  final CreateTripRepository _repo = CreateTripRepository();
  bool _isLoading = true;
  RentalTrip? _currentTrip;
  String? _errorMessage;
  int _previousDriverCount = 0;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _startPolling();
    }
  }

  Future<void> _cancelTrip(BuildContext context, bool isDark) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => CancelTripDialog(isDark: isDark),
    );

    if (reason != null && reason.isNotEmpty && _currentTrip != null) {
      try {
        globalScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Cancelling trip..."), behavior: SnackBarBehavior.floating),
        );
        final loc = AppLocalizations.of(context);
        final response = await _repo.cancelTrip(
          tripUuid: _currentTrip!.uuid ?? "",
          comment: reason,
          langCode: loc.locale.languageCode,
        );

        globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        globalScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Trip cancelled successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _pollingTimer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        globalScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startPolling() {
    _fetchBids(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchBids();
    });
  }

  Future<void> _fetchBids() async {
    try {
      final loc = AppLocalizations.of(context);
      final response = await _repo.fetchBids(
        customerUuid: widget.customerUuid,
        langCode: loc.locale.languageCode,
      );

      if (mounted) {
        setState(() {
          if (response.trips.isNotEmpty) {
            _currentTrip = response.trips.first;
            
            int currentDriverCount = _currentTrip!.drivers.length;
            if (currentDriverCount > _previousDriverCount) {
              FlutterRingtonePlayer().playNotification();
              _previousDriverCount = currentDriverCount;
            }
          }
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine title text
    String titleText = "Finding your ride";
    String subtitleText = _currentTrip?.serviceName?.replaceAll('_', ' ') ?? "TRIPPY RIDE PREMIUM";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13151B) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              titleText,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              subtitleText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              child: Icon(Icons.person, size: 20, color: isDark ? Colors.white70 : Colors.black54),
            ),
          )
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _currentTrip == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    }

    if (_errorMessage != null && _currentTrip == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Error fetching trip: $_errorMessage",
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_currentTrip == null) {
      return Center(
        child: Text(
          "No trip requested yet.",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    bool hasBids = _currentTrip!.drivers.isNotEmpty;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: isDark ? const Color(0xFF13151B) : Colors.white),
        ),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: hasBids 
                  ? BiddingListWidget(
                      isDark: isDark, 
                      currentTrip: _currentTrip!, 
                      onAcceptBid: () {
                        _pollingTimer.cancel();
                        // Accept Bid Logic
                      },
                    ) 
                  : BiddingSearchingState(isDark: isDark),
              ),
              BiddingTripDetailsCard(
                isDark: isDark, 
                currentTrip: _currentTrip!,
                onCancel: () => _cancelTrip(context, isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
