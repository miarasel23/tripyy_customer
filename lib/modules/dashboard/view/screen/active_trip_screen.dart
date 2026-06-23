import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../repository/create_trip_repository.dart';
import '../../models/create_rental_trip_model.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/app_colors.dart';

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
  Timer? _pollingTimer;

  GoogleMapController? _mapController;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // NOTE: _fetchActiveTrip() is called in didChangeDependencies
    // to safely access context (AppLocalizations).
    _startPolling();
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
        tripStatus: "ACCEPTED",
      );

      if (mounted) {
        setState(() {
          if (response.trips.isNotEmpty) {
            _activeTrip = response.trips.first;
          } else {
            // No accepted trip found, might have ended
            _errorMessage = "No active trip found.";
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13151B) : Colors.white,
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _activeTrip == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null && _activeTrip == null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final trip = _activeTrip!;
    final driver = trip.drivers.isNotEmpty ? trip.drivers.first : null;
    
    // Default location (e.g. Dhaka)
    final LatLng initialCameraPosition = const LatLng(23.8103, 90.4125);

    return Stack(
      children: [
        // Map
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition,
              zoom: 14.0,
            ),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              // Map style can be added here
            },
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: initialCameraPosition,
              ),
            },
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

        // Navigation Info overlay
        Positioned(
          top: 50,
          left: 80,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.turn_right, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Heading to Destination",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Follow the route",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Sheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomSheet(isDark, driver),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(bool isDark, RentalDriverBid? driver) {
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
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "HEADING TO DESTINATION",
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
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
                        backgroundImage: driver?.profilePicture != null 
                            ? NetworkImage(driver!.profilePicture!) 
                            : null,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        child: driver?.profilePicture == null 
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
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                driver?.averageRating?.toStringAsFixed(1) ?? "0.0",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.star, color: Colors.white, size: 10),
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
                          driver?.name ?? "Unknown Driver",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Top-rated Partner",
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
                        _activeTrip?.carCategory?.carType ?? "Toyota Camry",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "White • CAL 7X42", // Hardcoded for UI showcase, would be from API
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.call, "Call", () {
                  if (driver?.phone != null) {
                    _launchUrl("tel:${driver!.phone}");
                  }
                }, isDark),
                _buildActionButton(Icons.chat_bubble_outline, "Message", () {
                  if (driver?.phone != null) {
                    _launchUrl("sms:${driver!.phone}");
                  }
                }, isDark),
                _buildActionButton(Icons.ios_share, "Share", () {}, isDark),
                _buildActionButton(Icons.warning_amber_rounded, "SOS", () {}, isDark, isSos: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trip Details Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Trip Details",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_up, color: Color(0xFF6C63FF)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, bool isDark, {bool isSos = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSos 
                  ? Colors.red.withOpacity(0.1) 
                  : (isDark ? const Color(0xFF252833) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSos 
                  ? Colors.redAccent 
                  : (isDark ? Colors.white70 : Colors.black54),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isSos 
                  ? Colors.redAccent 
                  : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
