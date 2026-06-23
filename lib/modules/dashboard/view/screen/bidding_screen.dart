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
    String subtitleText = _currentTrip?.serviceName?.replaceAll('_', ' ') ?? "RAPIDRIDE PREMIUM";

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
                child: hasBids ? _buildBidsList(isDark) : _buildSearchingState(isDark),
              ),
              _buildTripDetailsCard(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const RadarAnimation(
          size: 180,
          color: Color(0xFF6C63FF),
        ),
        const SizedBox(height: 30),
        Text(
          "Searching for drivers...",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Estimated match in 2 min",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildBidsList(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 4),
        const SizedBox(
           height: 50,
           child: RadarAnimation(size: 50, color: Color(0xFF6C63FF)),
        ),
        const SizedBox(height: 4),
        Text(
          "Searching for more drivers...",
          style: GoogleFonts.poppins(
             fontSize: 12,
             color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Drivers Found!",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _currentTrip!.drivers.length,
            itemBuilder: (context, index) {
              final bid = _currentTrip!.drivers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1E26) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: _currentTrip!.carCategory?.carAvatar != null 
                            ? NetworkImage("${AppUrls.imageBaseUrl}${_currentTrip!.carCategory!.carAvatar}") 
                            : null,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          child: _currentTrip!.carCategory?.carAvatar == null 
                            ? Icon(Icons.directions_car, color: isDark ? Colors.white : Colors.black54) 
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (bid.name ?? "Driver").toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(AppLocalizations.of(context).translate("total") ?? "Total").toUpperCase()}: ' + 
                                (AppLocalizations.of(context).locale.languageCode == 'bn' 
                                    ? '৳${bid.totalAmount ?? bid.bidAmount ?? '0.00'}' 
                                    : 'BDT ${bid.totalAmount ?? bid.bidAmount ?? '0.00'}'),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (bid.ratingList != null && bid.ratingList!.isNotEmpty) {
                                  _showReviewsBottomSheet(context, bid, isDark);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No reviews available yet.")),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${bid.averageRating?.toStringAsFixed(1) ?? "0.0"} (${bid.totalCompletedTrips ?? 0} trips)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: (bid.ratingList != null && bid.ratingList!.isNotEmpty) 
                                          ? Colors.blueAccent 
                                          : (isDark ? Colors.white54 : Colors.black54),
                                      decoration: (bid.ratingList != null && bid.ratingList!.isNotEmpty) 
                                          ? TextDecoration.underline 
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _pollingTimer.cancel();
                                // Accept Bid Logic
                                // e.g. Navigator.push(...)
                              },
                              child: Text("Accept", style: GoogleFonts.poppins(color: isDark ? Colors.black : Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (bid.carPhotos != null && bid.carPhotos!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: bid.carPhotos!.length,
                          itemBuilder: (context, photoIndex) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => FullScreenImageGallery(
                                    images: bid.carPhotos!,
                                    initialIndex: photoIndex,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage("${AppUrls.imageBaseUrl}${bid.carPhotos![photoIndex]}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReviewsBottomSheet(BuildContext context, RentalDriverBid bid, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1E26) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Driver Reviews",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bid.ratingList!.length,
                  itemBuilder: (context, index) {
                    final review = bid.ratingList![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252833) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: review.customerPhoto != null 
                                  ? NetworkImage("${AppUrls.imageBaseUrl}${review.customerPhoto}")
                                  : null,
                                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                child: review.customerPhoto == null
                                  ? Icon(Icons.person, size: 16, color: isDark ? Colors.white54 : Colors.black54)
                                  : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.customerName ?? "Customer",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      review.createdAt?.split('T').first ?? "",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  int rating = review.rating ?? 0;
                                  return Icon(
                                    starIndex < rating ? Icons.star : Icons.star_border,
                                    size: 14,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ],
                          ),
                          if (review.comments != null && review.comments!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comments!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripDetailsCard(bool isDark) {
    final carType = _currentTrip!.carCategory?.carType ?? "Standard Sedan";
    final price = _currentTrip!.offerAmount?.toStringAsFixed(2) ?? _currentTrip!.priceInfo?.minimumBookingPrice?.toStringAsFixed(2) ?? "0.00";
    final hasOffer = _currentTrip!.offerAmount != null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1E26) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252833) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carType,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "Priority Pickup • Comfort+",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (hasOffer ? '' : '${AppLocalizations.of(context).translate("up_to") ?? "Up to"} ') + 
                      (AppLocalizations.of(context).locale.languageCode == 'bn' 
                          ? '৳$price' 
                          : 'BDT $price'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      hasOffer 
                        ? (AppLocalizations.of(context).translate("offer_price") ?? "Offer Price")
                        : "Est. total",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          ..._buildDynamicLocationList(isDark),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF252833) : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text(
                "Cancel Request",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Center(
            child: Text(
              "SECURE MATCHING BY RAPIDRIDE AI",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white24 : Colors.black38,
                letterSpacing: 1.5,
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildDynamicLocationList(bool isDark) {
    List<Widget> children = [];
    
    final int pickupCount = _currentTrip!.pickupLocations.length;
    for (int i = 0; i < pickupCount; i++) {
      children.add(
        _buildLocationRow(
          icon: Icons.my_location,
          iconColor: isDark ? Colors.white : Colors.black87,
          label: pickupCount > 1 ? "PICKUP ${i + 1}" : "PICKUP",
          address: _currentTrip!.pickupLocations[i].address ?? "Unknown Pickup",
          isDark: isDark,
        ),
      );
      
      // Add a line connector after each pickup
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 11.0, top: 4, bottom: 4),
          child: Container(
            width: 2,
            height: 20,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
      );
    }
    
    final int dropoffCount = _currentTrip!.dropoffLocations.length;
    for (int i = 0; i < dropoffCount; i++) {
      children.add(
        _buildLocationRow(
          icon: Icons.location_on,
          iconColor: const Color(0xFF6C63FF),
          label: dropoffCount > 1 ? "DESTINATION ${i + 1}" : "DESTINATION",
          address: _currentTrip!.dropoffLocations[i].address ?? "Unknown Dropoff",
          isDark: isDark,
        ),
      );
      
      // Add a line connector after each dropoff EXCEPT the last one
      if (i < dropoffCount - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 11.0, top: 4, bottom: 4),
            child: Container(
              width: 2,
              height: 20,
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
        );
      }
    }
    
    return children;
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
