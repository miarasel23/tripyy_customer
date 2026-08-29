import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../model/create_rental_trip_model.dart';
import '../repository/create_trip_repository.dart';
import '../../../../utils/app_urls.dart';
import '../../../../widgets/radar_animation.dart';
import '../../../../widgets/full_screen_image_gallery.dart';
import '../../../../store/app_globals.dart';

class TripTimerBadge extends StatefulWidget {
  final String? serviceName;
  final String? createdAt;
  final String? countryCode;
  final bool isDark;

  const TripTimerBadge({
    super.key,
    required this.serviceName,
    this.createdAt,
    this.countryCode,
    required this.isDark,
  });

  @override
  State<TripTimerBadge> createState() => _TripTimerBadgeState();
}

class _TripTimerBadgeState extends State<TripTimerBadge> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initSeconds();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TripTimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceName != widget.serviceName || oldWidget.createdAt != widget.createdAt) {
      _timer?.cancel();
      _initSeconds();
      _startTimer();
    }
  }

  DateTime? _parseDateTime(String? raw, {String? countryCode}) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      String clean = raw.trim();
      if (clean.contains(' ') && !clean.contains('T')) {
        clean = clean.replaceAll(' ', 'T');
      }

      final code = (countryCode != null && countryCode.isNotEmpty)
          ? countryCode.toUpperCase()
          : AppGlobals.countryCode.toUpperCase();
      final isBD = code == "BD";

      if (!clean.endsWith('Z') && !clean.contains('+') && !RegExp(r'T\d{2}:\d{2}:\d{2}-\d{2}').hasMatch(clean)) {
        if (isBD) {
          clean += "+06:00"; // Asia/Dhaka timezone offset
        }
      }

      DateTime parsed = DateTime.parse(clean);
      return parsed.toLocal();
    } catch (_) {
      try {
        int? ts = int.tryParse(raw.trim());
        if (ts != null) {
          if (ts < 10000000000) {
            return DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal();
          } else {
            return DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
          }
        }
      } catch (_) {}
      return null;
    }
  }

  void _initSeconds() {
    final service = widget.serviceName?.toLowerCase() ?? "";
    final isRideShare = service == "ride_share" || 
                        service.contains("ride_share") || 
                        service == "rideshare";
    final int maxSeconds = isRideShare ? 40 : (30 * 60);

    final createdAt = _parseDateTime(
      widget.createdAt,
      countryCode: widget.countryCode,
    );

    if (createdAt != null) {
      final elapsed = DateTime.now().difference(createdAt).inSeconds;
      final remaining = maxSeconds - (elapsed > 0 ? elapsed : 0);
      _remainingSeconds = remaining > 0 ? remaining : 0;
    } else {
      _remainingSeconds = maxSeconds;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0 && mounted) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    if (_remainingSeconds <= 0) {
      return "Expired";
    }
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    String mStr = minutes.toString().padLeft(2, '0');
    String sStr = seconds.toString().padLeft(2, '0');
    return "$mStr:$sStr";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E3A29) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 15,
            color: widget.isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 4),
          Text(
            _formattedTimer,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class BiddingListWidget extends StatefulWidget {
  final bool isDark;
  final RentalTrip currentTrip;
  final Function(RentalDriverBid bid) onAcceptBid;

  const BiddingListWidget({
    super.key,
    required this.isDark,
    required this.currentTrip,
    required this.onAcceptBid,
  });

  @override
  State<BiddingListWidget> createState() => _BiddingListWidgetState();
}

class _BiddingListWidgetState extends State<BiddingListWidget> {
  final Set<String> _hiddenBidUuids = {};
  final CreateTripRepository _repo = CreateTripRepository();

  void _hideBid(RentalDriverBid bid) {
    final uuid = bid.rentBidUuid ?? bid.driverUuid ?? bid.name ?? "";
    if (uuid.isNotEmpty && mounted) {
      setState(() {
        _hiddenBidUuids.add(uuid);
      });
    }

    final bidUuid = bid.rentBidUuid ?? bid.driverUuid;
    if (bidUuid != null && bidUuid.isNotEmpty) {
      final loc = AppLocalizations.of(context);
      _repo.cancelRentBid(
        bidUuid: bidUuid,
        langCode: loc.locale.languageCode,
      ).then((response) {
        debugPrint("Rent bid cancelled successfully: ${response['message']}");
      }).catchError((error) {
        debugPrint("Error cancelling rent bid: $error");
      });
    }
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return "18 Aug 2026 and 4:30 AM";
    try {
      DateTime dt = DateTime.parse(raw);
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      String month = months[dt.month - 1];
      int hour = dt.hour % 12;
      if (hour == 0) hour = 12;
      String minute = dt.minute.toString().padLeft(2, '0');
      String period = dt.hour >= 12 ? "PM" : "AM";
      return "${dt.day} $month ${dt.year} and $hour:$minute $period";
    } catch (_) {
      return raw;
    }
  }

  bool get _isTripExpired {
    final service = widget.currentTrip.serviceName?.toLowerCase() ?? "";
    final isRideShare = service == "ride_share" || 
                        service.contains("ride_share") || 
                        service == "rideshare";
    final int maxSeconds = isRideShare ? 40 : (30 * 60);

    final createdAtStr = widget.currentTrip.createdAt ?? widget.currentTrip.startDatetime;
    if (createdAtStr == null || createdAtStr.trim().isEmpty) return false;
    try {
      String clean = createdAtStr.trim();
      if (clean.contains(' ') && !clean.contains('T')) {
        clean = clean.replaceAll(' ', 'T');
      }
      final isBD = (widget.currentTrip.countryCode?.toUpperCase() == "BD") || (AppGlobals.countryCode.toUpperCase() == "BD");
      if (!clean.endsWith('Z') && !clean.contains('+') && !RegExp(r'T\d{2}:\d{2}:\d{2}-\d{2}').hasMatch(clean)) {
        if (isBD) clean += "+06:00";
      }
      DateTime createdAt = DateTime.parse(clean).toLocal();
      int elapsed = DateTime.now().difference(createdAt).inSeconds;
      return elapsed >= maxSeconds;
    } catch (_) {
      return false;
    }
  }

  String _toBanglaDigits(String numberStr) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < english.length; i++) {
      numberStr = numberStr.replaceAll(english[i], bangla[i]);
    }
    return numberStr;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.locale.languageCode == 'bn';
    final expired = _isTripExpired;

    final visibleDrivers = widget.currentTrip.drivers.where((bid) {
      final id = bid.rentBidUuid ?? bid.driverUuid ?? bid.name ?? "";
      return !_hiddenBidUuids.contains(id);
    }).toList();

    final countStr = isBn ? _toBanglaDigits(visibleDrivers.length.toString()) : visibleDrivers.length.toString();
    final driversFoundText = loc.translate("drivers_found_count").replaceAll('{count}', countStr);

    return Column(
      children: [
        if (!expired) ...[
          const SizedBox(height: 4),
          const SizedBox(
             height: 50,
             child: RadarAnimation(size: 50, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate("searching_for_more_drivers"),
            style: GoogleFonts.poppins(
               fontSize: 12,
               color: widget.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          expired 
              ? loc.translate("bidding_expired") 
              : driversFoundText,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: expired ? Colors.redAccent : Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: visibleDrivers.isEmpty
              ? Center(
                  child: Text(
                    loc.translate("no_active_bids_right_now"),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: widget.isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: visibleDrivers.length,
                  itemBuilder: (context, index) {
                    final bid = visibleDrivers[index];
                    return DriverBidCard(
                      key: ValueKey(bid.rentBidUuid ?? bid.driverUuid ?? index.toString()),
                      bid: bid,
                      currentTrip: widget.currentTrip,
                      isDark: widget.isDark,
                      isBn: isBn,
                      onAcceptBid: widget.onAcceptBid,
                      onHide: () => _hideBid(bid),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class DriverBidCard extends StatefulWidget {
  final RentalDriverBid bid;
  final RentalTrip currentTrip;
  final bool isDark;
  final bool isBn;
  final Function(RentalDriverBid bid) onAcceptBid;
  final VoidCallback onHide;

  const DriverBidCard({
    super.key,
    required this.bid,
    required this.currentTrip,
    required this.isDark,
    required this.isBn,
    required this.onAcceptBid,
    required this.onHide,
  });

  @override
  State<DriverBidCard> createState() => _DriverBidCardState();
}

class _DriverBidCardState extends State<DriverBidCard> with SingleTickerProviderStateMixin {
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _startSmoothAnimation();
  }

  @override
  void didUpdateWidget(covariant DriverBidCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTrip.serviceName != widget.currentTrip.serviceName) {
      _startSmoothAnimation();
    }
  }

  DateTime? _parseDateTime(String? raw, {String? countryCode}) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      String clean = raw.trim();
      if (clean.contains(' ') && !clean.contains('T')) {
        clean = clean.replaceAll(' ', 'T');
      }

      final code = (countryCode != null && countryCode.isNotEmpty)
          ? countryCode.toUpperCase()
          : AppGlobals.countryCode.toUpperCase();
      final isBD = code == "BD";

      if (!clean.endsWith('Z') && !clean.contains('+') && !RegExp(r'T\d{2}:\d{2}:\d{2}-\d{2}').hasMatch(clean)) {
        if (isBD) {
          clean += "+06:00";
        }
      }

      DateTime parsed = DateTime.parse(clean);
      return parsed.toLocal();
    } catch (_) {
      try {
        int? ts = int.tryParse(raw.trim());
        if (ts != null) {
          if (ts < 10000000000) {
            return DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal();
          } else {
            return DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
          }
        }
      } catch (_) {}
      return null;
    }
  }

  void _startSmoothAnimation() {
    final service = widget.currentTrip.serviceName?.toLowerCase() ?? "";
    final isRideShare = service == "ride_share" || 
                        service.contains("ride_share") || 
                        service == "rideshare";
    final int totalDurationSeconds = isRideShare ? 40 : (30 * 60);

    final createdAtStr = widget.currentTrip.createdAt;
    final createdAt = _parseDateTime(
      createdAtStr,
      countryCode: widget.currentTrip.countryCode,
    );

    double initialProgress = 0.0;
    int remainingMs = totalDurationSeconds * 1000;

    if (createdAt != null) {
      final elapsedMs = DateTime.now().difference(createdAt).inMilliseconds;
      if (elapsedMs > 0 && elapsedMs < totalDurationSeconds * 1000) {
        initialProgress = (elapsedMs / (totalDurationSeconds * 1000)).clamp(0.0, 1.0);
        remainingMs = (totalDurationSeconds * 1000) - elapsedMs;
      } else if (elapsedMs >= totalDurationSeconds * 1000) {
        remainingMs = 0;
      }
    }

    if (!isRideShare) {
      if (remainingMs <= 0) {
        remainingMs = totalDurationSeconds * 1000;
        initialProgress = 0.0;
      }
    } else if (remainingMs <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onHide();
      });
      return;
    }

    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      value: initialProgress,
      duration: Duration(seconds: totalDurationSeconds),
    );

    _animController!.addListener(() {
      if (mounted) setState(() {});
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onHide();
      }
    });

    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  String _toBanglaDigits(String numberStr) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < english.length; i++) {
      numberStr = numberStr.replaceAll(english[i], bangla[i]);
    }
    return numberStr;
  }

  void _showReviewsBottomSheet(BuildContext context, RentalDriverBid bid, bool isDark) {
    final loc = AppLocalizations.of(context);
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
                loc.translate("driver_reviews"),
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
                  itemCount: bid.ratingList?.length ?? 0,
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
                                      review.customerName ?? loc.translate("customer_label"),
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

  @override
  Widget build(BuildContext context) {
    final bid = widget.bid;
    final isDark = widget.isDark;
    final loc = AppLocalizations.of(context);
    final isBn = widget.isBn;
    final bidAmount = bid.totalAmount ?? bid.bidAmount ?? 0.00;
    final formattedPrice = isBn 
        ? '৳ ${_toBanglaDigits(bidAmount.round().toString())}' 
        : 'BDT ${bidAmount.round()}';

    // Car photo gallery info & URL
    final int photoCount = bid.carPhotos?.length ?? 0;
    final int displayCount = photoCount > 0 ? photoCount : 1;
    String? carPhotoUrl;
    if (photoCount > 0) {
      carPhotoUrl = bid.carPhotos!.first.startsWith('http')
          ? bid.carPhotos!.first
          : "${AppUrls.imageBaseUrl}${bid.carPhotos!.first}";
    }

    final double progressFactor = (_animController?.value ?? 0.0).clamp(0.0, 1.0);

    final ridesCountStr = isBn ? _toBanglaDigits((bid.totalCompletedTrips ?? 0).toString()) : (bid.totalCompletedTrips ?? 0).toString();
    final ridesText = loc.translate("rides_count").replaceAll('{count}', ridesCountStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22242B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Price Row (e.g. BDT 500 / ৳ ৫০০)
          Text(
            formattedPrice,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          // 2. Middle Row: Driver Avatar, Details, and Car Photo Gallery Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Driver Profile Picture
              CircleAvatar(
                radius: 22,
                backgroundImage: (bid.profilePicture != null && bid.profilePicture!.isNotEmpty)
                    ? NetworkImage(bid.profilePicture!.startsWith('http') 
                        ? bid.profilePicture! 
                        : "${AppUrls.imageBaseUrl}${bid.profilePicture}")
                    : null,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                child: (bid.profilePicture == null || bid.profilePicture!.isEmpty)
                    ? Icon(Icons.person, size: 22, color: isDark ? Colors.white54 : Colors.black54)
                    : null,
              ),
              const SizedBox(width: 10),

              // Driver Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bid.name ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (bid.ratingList != null && bid.ratingList!.isNotEmpty) {
                              _showReviewsBottomSheet(context, bid, isDark);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: isDark ? Colors.white : Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                isBn 
                                    ? _toBanglaDigits((bid.averageRating == null || bid.averageRating == 0) ? "0.0" : bid.averageRating!.toStringAsFixed(1))
                                    : ((bid.averageRating == null || bid.averageRating == 0) ? "0.0" : bid.averageRating!.toStringAsFixed(1)),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ridesText,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (bid.carRegNumber != null && bid.carRegNumber!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        bid.carRegNumber!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Professional Car Photo Gallery Card (Multi-card stack effect + count badge)
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (photoCount > 0 && widget.bid.carPhotos != null && widget.bid.carPhotos!.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => FullScreenImageGallery(
                        images: widget.bid.carPhotos!,
                        initialIndex: 0,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: 70,
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Stack Layer 2 (Behind card for multi-photo gallery effect)
                      if (photoCount > 1)
                        Positioned(
                          right: -3,
                          top: 2,
                          bottom: 2,
                          child: Container(
                            width: 64,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2E313A) : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      // Main Photo Container Card
                      Container(
                        width: 66,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: carPhotoUrl != null
                                    ? Image.network(
                                        carPhotoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                          child: Icon(Icons.directions_car, size: 24, color: isDark ? Colors.white54 : Colors.black45),
                                        ),
                                      )
                                    : Container(
                                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                        child: Icon(Icons.directions_car, size: 24, color: isDark ? Colors.white54 : Colors.black45),
                                      ),
                              ),
                              // Bottom Gradient Overlay for readability
                              Positioned(
                                left: 0, right: 0, bottom: 0, height: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Photo Count Glassmorphism Badge
                              Positioned(
                                bottom: 3,
                                right: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.white24, width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.collections_rounded, size: 9, color: Colors.white),
                                      const SizedBox(width: 2.5),
                                      Text(
                                        isBn ? _toBanglaDigits(displayCount.toString()) : "$displayCount",
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Action Buttons: Black & White Theme with Progress Bar Accept Button
          Row(
            children: [
              // Decline Button (Black and White Theme)
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E2026) : Colors.grey.shade200,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: widget.onHide,
                    child: Text(
                      loc.translate("decline"),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Accept Button with 60s Progress Bar Background (Full Black BG + Charcoal Gray Progress Fill)
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onAcceptBid(bid),
                    child: Stack(
                      children: [
                        // Full Black Base Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                        ),
                        // Charcoal Dark Gray Progress Fill
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: progressFactor,
                                child: Container(
                                  color: const Color(0xFF5A5E6B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Text Overlay in Crisp White
                        Center(
                          child: Text(
                            loc.translate("accept"),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
