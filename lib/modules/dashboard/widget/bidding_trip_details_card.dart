import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../store/user_data_store.dart';
import '../../../../utils/app_urls.dart';
import '../model/create_rental_trip_model.dart';
import '../repository/create_trip_repository.dart';
import '../../../../store/app_globals.dart';
import '../helper/active_trip_helper.dart';

class BiddingTripDetailsCard extends StatefulWidget {
  final bool isDark;
  final RentalTrip currentTrip;
  final VoidCallback onCancel;

  const BiddingTripDetailsCard({
    super.key,
    required this.isDark,
    required this.currentTrip,
    required this.onCancel,
  });

  @override
  State<BiddingTripDetailsCard> createState() => _BiddingTripDetailsCardState();
}

class _BiddingTripDetailsCardState extends State<BiddingTripDetailsCard> {
  late int _remainingSeconds;
  Timer? _timer;
  late int _offerPrice;
  bool _isExpanded = false;
  bool _hasShownExpiredDialog = false;
  bool _isUpdatingOffer = false;

  @override
  void initState() {
    super.initState();
    _initPrice();
    _initTimer();
    _startTimer();
  }

  late int _initialBasePrice;

  void _initPrice() {
    final rawPrice = widget.currentTrip.offerAmount ?? 
                     widget.currentTrip.priceInfo?.minimumBookingPrice ?? 
                     379.0;
    _offerPrice = rawPrice.round();
    _initialBasePrice = _offerPrice;
  }

  @override
  void didUpdateWidget(covariant BiddingTripDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTrip.serviceName != widget.currentTrip.serviceName) {
      _timer?.cancel();
      _initTimer();
      _startTimer();
    }
    if (oldWidget.currentTrip.offerAmount != widget.currentTrip.offerAmount) {
      _initPrice();
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

  void _initTimer() {
    final service = widget.currentTrip.serviceName?.toLowerCase() ?? "";
    final isRideShare = service == "ride_share" || 
                        service.contains("ride_share") || 
                        service == "rideshare";
    final int maxSeconds = isRideShare ? (2 * 60) : (60 * 60);

    final createdAtStr = widget.currentTrip.createdAt ?? widget.currentTrip.startDatetime;
    final createdAt = _parseDateTime(
      createdAtStr,
      countryCode: widget.currentTrip.countryCode,
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0 && mounted) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds == 0) {
          _timer?.cancel();
          _onTimerExpired();
        }
      } else {
        _timer?.cancel();
        if (_remainingSeconds == 0 && mounted) {
          _onTimerExpired();
        }
      }
    });
  }

  void _onTimerExpired() {
    if (_hasShownExpiredDialog || !mounted) return;
    _hasShownExpiredDialog = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showExpiredOfferDialog();
      }
    });
  }

  Future<bool> _sendUpdateOfferAmount({
    required int newPrice,
    required bool isKeepTrying,
  }) async {
    if (_isUpdatingOffer) return false;
    setState(() {
      _isUpdatingOffer = true;
    });

    final loc = AppLocalizations.of(context);
    final isBn = loc.locale.languageCode == 'bn';
    final currencySymbol = isBn ? '৳' : 'BDT';
    final isDark = widget.isDark;

    String customerUuid = UserDataStore.userData?.data?.user?.uuid ?? UserDataStore.uuid ?? "";
    if (customerUuid.isEmpty) {
      customerUuid = await UserDataStore.getUuid() ?? "";
    }
    final tripUuid = widget.currentTrip.uuid ?? "";

    try {
      final repo = CreateTripRepository();
      await repo.updateTripOfferAmount(
        customerUuid: customerUuid,
        tripUuid: tripUuid,
        offerAmount: newPrice.toString(),
        langCode: loc.locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _offerPrice = newPrice;
          _initialBasePrice = newPrice;
          _initTimer();
          _hasShownExpiredDialog = false;
        });
        _startTimer();

        final formattedPriceText = isBn
            ? "$currencySymbol ${_toBanglaDigits(newPrice.toString())}"
            : "$currencySymbol $newPrice";

        final msg = isKeepTrying
            ? (isBn ? "বর্তমান দামে আবার চেষ্টা করা হচ্ছে ($formattedPriceText)" : "Continuing search with $formattedPriceText")
            : loc.translate("fare_updated_to").replaceAll('{amount}', formattedPriceText);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 3),
            backgroundColor: isDark ? Colors.white : Colors.black,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        final errText = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingOffer = false;
        });
      }
    }
  }

  Future<void> _showExpiredOfferDialog() async {
    final loc = AppLocalizations.of(context);
    final isBn = loc.locale.languageCode == 'bn';
    final currencySymbol = isBn ? '৳' : 'BDT';
    final isDark = widget.isDark;

    int tempOfferPrice = _offerPrice + 50;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final formattedPriceText = isBn
                ? "$currencySymbol ${_toBanglaDigits(tempOfferPrice.toString())}"
                : "$currencySymbol $tempOfferPrice";
            final currentPriceText = isBn
                ? "$currencySymbol ${_toBanglaDigits(_offerPrice.toString())}"
                : "$currencySymbol $_offerPrice";

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF191B23) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isBn
                          ? "গাড়িচালকদের দ্রুত প্রতিক্রিয়া পেতে আপনার অফারের দাম বাড়ান অথবা বর্তমান দামে অনুসন্ধান চালিয়ে যান।"
                          : "No driver accepted yet. Increase your offer to get responses faster, or continue trying with your current fare.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232733) : const Color(0xFFF4F6F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: isDialogLoading
                                ? null
                                : () {
                                    if (tempOfferPrice > _offerPrice) {
                                      setDialogState(() {
                                        tempOfferPrice -= 10;
                                      });
                                    }
                                  },
                            child: Container(
                              width: 56,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF14161D) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isBn ? "-১০" : "-10",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Text(
                            formattedPriceText,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),

                          GestureDetector(
                            onTap: isDialogLoading
                                ? null
                                : () {
                                    setDialogState(() {
                                      tempOfferPrice += 10;
                                    });
                                  },
                            child: Container(
                              width: 56,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF14161D) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isBn ? "+১০" : "+10",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isDialogLoading
                            ? null
                            : () async {
                                setDialogState(() {
                                  isDialogLoading = true;
                                });
                                final success = await _sendUpdateOfferAmount(
                                  newPrice: tempOfferPrice,
                                  isKeepTrying: false,
                                );
                                if (context.mounted) {
                                  setDialogState(() {
                                    isDialogLoading = false;
                                  });
                                }
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                        child: isDialogLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              )
                            : Text(
                                isBn
                                    ? "দাম বাড়ান ($formattedPriceText)"
                                    : "Raise Offer ($formattedPriceText)",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF232733) : Colors.grey.shade100,
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isDialogLoading
                            ? null
                            : () async {
                                setDialogState(() {
                                  isDialogLoading = true;
                                });
                                final success = await _sendUpdateOfferAmount(
                                  newPrice: _offerPrice,
                                  isKeepTrying: true,
                                );
                                if (context.mounted) {
                                  setDialogState(() {
                                    isDialogLoading = false;
                                  });
                                }
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                        child: Text(
                          isBn
                              ? "বর্তমান দামে চেষ্টা করুন ($currentPriceText)"
                              : "Keep Trying ($currentPriceText)",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  String _formattedTimer(BuildContext context, bool isBn) {
    if (_remainingSeconds <= 0) {
      return AppLocalizations.of(context).translate("expired");
    }
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    String mStr = minutes.toString().padLeft(2, '0');
    String sStr = seconds.toString().padLeft(2, '0');
    String timerText = "$mStr:$sStr";
    return isBn ? _toBanglaDigits(timerText) : timerText;
  }

  Widget _buildDriverAvatarStack() {
    final List<String> avatarList = [];
    if (widget.currentTrip.seenDrivers.isNotEmpty) {
      for (var d in widget.currentTrip.seenDrivers) {
        if (d.profilePicture != null && d.profilePicture!.isNotEmpty) {
          avatarList.add(d.profilePicture!);
        }
      }
    } else if (widget.currentTrip.seenDriverPhotos.isNotEmpty) {
      avatarList.addAll(widget.currentTrip.seenDriverPhotos.where((p) => p.isNotEmpty));
    } else if (widget.currentTrip.drivers.isNotEmpty) {
      for (var d in widget.currentTrip.drivers) {
        if (d.profilePicture != null && d.profilePicture!.isNotEmpty) {
          avatarList.add(d.profilePicture!);
        }
      }
    }

    final int totalCount = widget.currentTrip.seenDriverCount ?? 
                           (avatarList.isNotEmpty ? avatarList.length : (widget.currentTrip.totalBids ?? 0));

    if (avatarList.isEmpty && totalCount == 0) {
      return const SizedBox.shrink();
    }

    final int maxVisible = 3;
    final visibleAvatars = avatarList.take(maxVisible).toList();
    final int extraCount = totalCount > visibleAvatars.length 
        ? totalCount - visibleAvatars.length 
        : (avatarList.length > maxVisible ? avatarList.length - maxVisible : 0);

    final double stackWidth = (visibleAvatars.isEmpty ? 1 : visibleAvatars.length + (extraCount > 0 ? 1 : 0)) * 18.0 + 10;

    return SizedBox(
      height: 28,
      width: stackWidth,
      child: Stack(
        children: [
          for (int i = 0; i < visibleAvatars.length; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isDark ? const Color(0xFF1C1E26) : Colors.white, 
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  backgroundImage: visibleAvatars[i].startsWith('http')
                      ? NetworkImage(visibleAvatars[i])
                      : (AppUrls.getImageUrl(visibleAvatars[i]) != null
                          ? NetworkImage(AppUrls.getImageUrl(visibleAvatars[i])!)
                          : null),
                  child: (AppUrls.getImageUrl(visibleAvatars[i]) == null && !visibleAvatars[i].startsWith('http'))
                      ? Icon(Icons.person, size: 14, color: widget.isDark ? Colors.white70 : Colors.black54)
                      : null,
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visibleAvatars.length * 18.0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isDark ? const Color(0xFF1C1E26) : Colors.white, 
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    "+$extraCount",
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required String address,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final loc = AppLocalizations.of(context);
    final isBn = loc.locale.languageCode == 'bn';
    final currencySymbol = isBn ? '৳' : 'BDT';
    final totalDriversViewed = widget.currentTrip.seenDriverCount ?? 
                               widget.currentTrip.totalBids ?? 
                               (widget.currentTrip.drivers.isEmpty ? 0 : widget.currentTrip.drivers.length);

    final List<_LocationDisplayItem> locationItems = [];
    if (widget.currentTrip.pickupLocations.isNotEmpty) {
      for (int i = 0; i < widget.currentTrip.pickupLocations.length; i++) {
        final addr = widget.currentTrip.pickupLocations[i].address ?? "Senpara Parbata Ln 392 (Mirpur)";
        locationItems.add(_LocationDisplayItem(
          icon: Icons.accessibility_new_rounded,
          iconColor: const Color(0xFF2196F3),
          address: addr,
        ));
      }
    } else {
      locationItems.add(_LocationDisplayItem(
        icon: Icons.accessibility_new_rounded,
        iconColor: const Color(0xFF2196F3),
        address: "Senpara Parbata Ln 392 (Mirpur)",
      ));
    }

    if (widget.currentTrip.dropoffLocations.isNotEmpty) {
      for (int i = 0; i < widget.currentTrip.dropoffLocations.length; i++) {
        final addr = widget.currentTrip.dropoffLocations[i].address ?? "Gulshan 1 (Dhaka)";
        final isLast = (i == widget.currentTrip.dropoffLocations.length - 1);
        locationItems.add(_LocationDisplayItem(
          icon: isLast ? Icons.flag_rounded : Icons.location_on,
          iconColor: isLast ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          address: addr,
        ));
      }
    } else {
      locationItems.add(_LocationDisplayItem(
        icon: Icons.flag_rounded,
        iconColor: const Color(0xFF4CAF50),
        address: "Gulshan 1 (Dhaka)",
      ));
    }

    final isExpired = _remainingSeconds <= 0;

    final timerBgColor = isExpired
        ? (isDark ? const Color(0xFF3E1E1E) : const Color(0xFFFFEBEE))
        : (isDark ? const Color(0xFF1E3A29) : const Color(0xFFE8F5E9));

    final timerBorderColor = isExpired
        ? (isDark ? const Color(0xFFC62828) : const Color(0xFFEF5350))
        : (isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784));

    final timerTextColor = isExpired
        ? (isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F))
        : (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32));

    final String currentStatus = widget.currentTrip.tripStatus?.toUpperCase() ?? "";
    final bool isRideStarted = currentStatus == "RIDE_STARTED" || currentStatus == "FIRST_COMPLETED" || currentStatus == "ON_GOING";
    final bool isAcceptedOrInProgress = currentStatus == "ACCEPTED" || currentStatus == "IN_PROGRESS" || currentStatus == "BOOKED" || currentStatus == "ARRIVED_PICKUP_LOCATION";

    final driversCountStr = isBn ? _toBanglaDigits(totalDriversViewed.toString()) : totalDriversViewed.toString();
    String driversViewedText = isRideStarted
        ? (isBn ? "গন্তব্যের দিকে যাওয়া হচ্ছে" : "ARRIVING AT DESTINATION")
        : (isAcceptedOrInProgress
            ? (isBn ? "ড্রাইভার পিকআপের দিকে আসছেন" : "DRIVER ARRIVING AT PICKUP LOCATION")
            : loc.translate("drivers_viewed_request").replaceAll('{count}', driversCountStr));
    if (!isRideStarted && !isAcceptedOrInProgress && !isBn && totalDriversViewed == 1) {
      driversViewedText = driversViewedText.replaceAll("drivers viewed", "driver viewed");
    }

    final maxCardHeight = MediaQuery.of(context).size.height * 0.58;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -150) {
            // Swiped / scrolled UP -> show bottom section
            if (!_isExpanded) {
              setState(() {
                _isExpanded = true;
              });
            }
          } else if (details.primaryVelocity! > 150) {
            // Swiped / scrolled DOWN -> collapse bottom section
            if (_isExpanded) {
              setState(() {
                _isExpanded = false;
              });
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14161D) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxCardHeight,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            // 1. Top Header Row: Drivers Viewed Request & Overlapping Avatars & Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    driversViewedText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDriverAvatarStack(),
                const SizedBox(width: 8),
                // Timer Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: timerBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: timerBorderColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
                        size: 14,
                        color: timerTextColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formattedTimer(context, isBn),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: timerTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 2. Main Box: "Waiting for offers from drivers" & Fare Adjustment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F222B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRideStarted
                        ? (isBn ? "গন্তব্যের দিকে যাওয়া হচ্ছে" : "ARRIVING AT DESTINATION")
                        : (isAcceptedOrInProgress
                            ? (isBn ? "ড্রাইভার পিকআপের দিকে আসছেন" : "DRIVER ARRIVING AT PICKUP LOCATION")
                            : loc.translate("waiting_offers_drivers")),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: isDark ? Colors.white10 : Colors.grey.shade200, height: 1),
                  const SizedBox(height: 16),

                  if (isRideStarted || isAcceptedOrInProgress) ...[
                    Center(
                      child: Text(
                        isBn 
                            ? "$currencySymbol ${_toBanglaDigits(_offerPrice.toString())}" 
                            : "$currencySymbol $_offerPrice",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final driver = widget.currentTrip.drivers.isNotEmpty ? widget.currentTrip.drivers.first : null;
                              final phone = driver?.phone ?? "";
                              if (phone.isNotEmpty) {
                                ActiveTripHelper.launchCallOrUrl(context, "tel:$phone");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isBn ? "ড্রাইভারের ফোন নম্বর পাওয়া যায়নি" : "Driver phone number unavailable"),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.call_rounded, size: 24, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBn ? "কল" : "Call",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final driver = widget.currentTrip.drivers.isNotEmpty ? widget.currentTrip.drivers.first : null;
                              final phone = driver?.phone ?? "";
                              if (phone.isNotEmpty) {
                                ActiveTripHelper.launchCallOrUrl(context, "sms:$phone");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isBn ? "ড্রাইভারের ফোন নম্বর পাওয়া যায়নি" : "Driver phone number unavailable"),
                                    backgroundColor: isDark ? Colors.white : Colors.black,
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0E52FF), Color(0xFF0038D6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0E52FF).withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.chat_bubble_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBn ? "চ্যাট" : "Chat",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_offerPrice > _initialBasePrice) {
                              setState(() {
                                _offerPrice -= 10;
                              });
                            }
                          },
                          child: Container(
                            width: 75,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2E3B) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isBn ? "-১০" : "-10",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            isBn 
                                ? "$currencySymbol ${_toBanglaDigits(_offerPrice.toString())}" 
                                : "$currencySymbol $_offerPrice",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _offerPrice += 10;
                            });
                          },
                          child: Container(
                            width: 75,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2E3B) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isBn ? "+১০" : "+10",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF2D3240) : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isUpdatingOffer 
                            ? null 
                            : () => _sendUpdateOfferAmount(
                                newPrice: _offerPrice, 
                                isKeepTrying: false,
                              ),
                        child: _isUpdatingOffer
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                loc.translate("raise_fare"),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 3. Expandable Bottom Details Section (Payment method, Pickup/Destination Route, Cancel Request)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Payment Method Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F222B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 20, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 12),
                              Text(
                                isBn 
                                    ? "$currencySymbol ${_toBanglaDigits(_offerPrice.toString())} ${loc.translate('cash')}"
                                    : "$currencySymbol $_offerPrice ${loc.translate('cash')}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Pickup & Destination Route Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F222B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < locationItems.length; i++) ...[
                                _buildLocationItem(
                                  icon: locationItems[i].icon,
                                  iconColor: locationItems[i].iconColor,
                                  address: locationItems[i].address,
                                  isDark: isDark,
                                ),
                                if (i < locationItems.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 9, top: 4, bottom: 4),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: 2,
                                        height: 16,
                                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Action Button (Cancel Request)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF2D3240) : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: widget.onCancel,
                            child: Text(
                              loc.translate("cancel_request"),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

class _LocationDisplayItem {
  final IconData icon;
  final Color iconColor;
  final String address;

  _LocationDisplayItem({
    required this.icon,
    required this.iconColor,
    required this.address,
  });
}

