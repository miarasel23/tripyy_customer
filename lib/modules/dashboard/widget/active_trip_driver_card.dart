import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_urls.dart';
import '../helper/active_trip_helper.dart';
import '../model/create_rental_trip_model.dart';

class ActiveTripDriverCard extends StatelessWidget {
  final RentalTrip trip;
  final RentalDriverBid? driver;
  final String customerUuid;
  final bool isDark;
  final bool isBn;
  final AppLocalizations loc;

  const ActiveTripDriverCard({
    super.key,
    required this.trip,
    required this.driver,
    required this.customerUuid,
    required this.isDark,
    required this.isBn,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final profilePicUrl = (driver?.profilePicture != null && driver!.profilePicture!.isNotEmpty)
        ? AppUrls.getImageUrl(driver!.profilePicture)
        : null;

    final hasCall = driver?.phone != null && driver!.phone!.isNotEmpty && driver!.phone != 'N/A';
    final hasChat = driver?.driverUuid != null && driver!.driverUuid!.isNotEmpty;
    final fareAmount = driver?.totalAmount ?? driver?.bidAmount ?? trip.offerAmount ?? 0.0;
    final displayFare = isBn
        ? "৳ ${ActiveTripHelper.toBanglaDigits(fareAmount.round().toString())}"
        : "BDT ${fareAmount.round()}";

    return Container(
      padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252833) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Driver Avatar with Rating Badge overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                child: profilePicUrl == null
                    ? Icon(Icons.person, size: 22, color: isDark ? Colors.white70 : Colors.black54)
                    : null,
              ),
              Positioned(
                bottom: -4,
                left: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driver?.averageRating?.toStringAsFixed(1) ?? "0.0",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.star, color: isDark ? Colors.black : Colors.white, size: 9),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // 2. Middle Info (Driver Name, Big Full Car Reg Number & Trips)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Line 1: Driver Name + Completed Trips Count
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver?.name != null && driver!.name!.isNotEmpty
                            ? driver!.name!
                            : (isBn ? "ড্রাইভার" : "Driver"),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBn
                          ? "(${ActiveTripHelper.toBanglaDigits((driver?.totalCompletedTrips ?? 0).toString())} ট্রিপ)"
                          : "(${driver?.totalCompletedTrips ?? 0} trips)",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Line 2: Bigger & Prominent Full Car Registration Number Pill ONLY
                if (driver?.carRegNumber != null && driver!.carRegNumber!.isNotEmpty && driver!.carRegNumber != "N/A") ...[
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.black12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              driver!.carRegNumber!,
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 6),

          // 3. Right Side: Total Amount (Top Right) + Call & Chat Buttons (Bottom Right)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fareAmount > 0) ...[
                Text(
                  displayFare,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCall) ...[
                    GestureDetector(
                      onTap: () => ActiveTripHelper.launchCallOrUrl(context, "tel:${driver!.phone}"),
                      child: Container(
                        width: 38,
                        height: 38,
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
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (hasChat)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chat,
                          arguments: {
                            'customerUuid': customerUuid,
                            'driverUuid': driver!.driverUuid,
                            'receiverType': 'DRIVER',
                            'title': driver!.name ?? 'Driver Chat',
                          },
                        );
                      },
                      child: Container(
                        width: 38,
                        height: 38,
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
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 17),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
