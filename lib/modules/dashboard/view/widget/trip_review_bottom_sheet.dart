import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_urls.dart';
import '../../models/create_rental_trip_model.dart';
import '../../repository/create_trip_repository.dart';

class TripReviewBottomSheet extends StatefulWidget {
  final RentalTrip trip;
  final RentalDriverBid? driver;
  final String customerUuid;

  const TripReviewBottomSheet({
    Key? key,
    required this.trip,
    required this.driver,
    required this.customerUuid,
  }) : super(key: key);

  @override
  State<TripReviewBottomSheet> createState() => _TripReviewBottomSheetState();
}

class _TripReviewBottomSheetState extends State<TripReviewBottomSheet> {
  int _selectedRating = 1;
  List<String> _selectedCompliments = [];
  bool _isSubmitting = false;
  final TextEditingController _otherCommentController = TextEditingController();

  final List<String> _availableCompliments = [
    "Clean car",
    "Great music",
    "Professional",
    "Smooth ride",
    "Others"
  ];

  @override
  void dispose() {
    _otherCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final loc = AppLocalizations.of(context);
      final repo = CreateTripRepository();
      
      List<String> finalComments = List.from(_selectedCompliments);
      if (finalComments.contains("Others") && _otherCommentController.text.trim().isNotEmpty) {
        finalComments.remove("Others");
        finalComments.add(_otherCommentController.text.trim());
      }
      final String comments = finalComments.join(', ');

      await repo.giveReview(
        tripUuid: widget.trip.uuid ?? '',
        customerUuid: widget.customerUuid,
        driverUuid: widget.driver?.driverUuid ?? '',
        rating: _selectedRating.toDouble(),
        comments: comments,
        langCode: loc.locale.languageCode,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true indicating success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting review: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;
    final trip = widget.trip;
    
    // Fallback format
    final dateDisplay = trip.startDatetime?.split(' ').first ?? 'Today';
    String timeDisplay = '--:--';
    if (trip.startDatetime != null && trip.startDatetime!.contains(' ')) {
        timeDisplay = trip.startDatetime!.split(' ').last.substring(0, 5);
        if (trip.endDatetime != null && trip.endDatetime!.contains(' ')) {
            timeDisplay += " - ${trip.endDatetime!.split(' ').last.substring(0, 5)}";
        }
    }
    
    final finalFare = driver?.totalAmount?.toStringAsFixed(2) ?? trip.offerAmount?.toStringAsFixed(2) ?? '0.00';
    final paymentMethod = trip.paymentMethod ?? 'CASH';

    return PopScope(
      canPop: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1E26),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Replaces back button to maintain spacing
                Text(
                  "Trip Details",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () {}, // Add help action if needed
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Success Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C83FD).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C83FD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    "Trip Completed",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF7C83FD),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hope you enjoyed the ride!",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Final Fare Card
                  _buildCard(
                    child: Column(
                      children: [
                        Text(
                          "FINAL FARE",
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$$finalFare",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.credit_card, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "Paid via $paymentMethod",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time and Route Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  dateDisplay,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  timeDisplay,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C83FD),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
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
                                    "Pickup",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    trip.pickupLocations.isNotEmpty ? (trip.pickupLocations.first.address ?? 'Unknown Pickup') : 'Unknown Pickup',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Destination",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    trip.dropoffLocations.isNotEmpty ? (trip.dropoffLocations.first.address ?? 'Unknown Dropoff') : 'Unknown Dropoff',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Driver and Rating Card
                  _buildCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Driver Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF7C83FD), width: 2),
                            image: DecorationImage(
                              image: (driver?.profilePicture != null
                                  ? NetworkImage(AppUrls.getImageUrl(driver!.profilePicture!) ?? '')
                                  : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          driver?.name ?? 'Unknown Driver',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${trip.carCategory?.carType ?? 'Car'} • ${driver?.averageRating?.toStringAsFixed(1) ?? '0.0'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.white70, size: 14),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Interactive Star Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  index < _selectedRating ? Icons.star : Icons.star_border,
                                  color: index < _selectedRating ? Colors.amber : Colors.white24,
                                  size: 36,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "GIVE A COMPLIMENT",
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Compliments
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _availableCompliments.map((compliment) {
                            final isSelected = _selectedCompliments.contains(compliment);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCompliments.remove(compliment);
                                  } else {
                                    _selectedCompliments.add(compliment);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7C83FD).withOpacity(0.2) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF7C83FD) : Colors.white24,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  compliment,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? const Color(0xFF7C83FD) : Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedCompliments.contains("Others")) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _otherCommentController,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Write your compliment...",
                              hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                              filled: true,
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF7C83FD)),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Submit Rating Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7CDFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                              ),
                            )
                          : Text(
                              "Submit Rating",
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
