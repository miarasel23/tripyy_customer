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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252833) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                child: profilePicUrl == null
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
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driver?.averageRating?.toStringAsFixed(1) ?? "0.0",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.star, color: isDark ? Colors.black : Colors.white, size: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver?.name != null && driver!.name!.isNotEmpty
                      ? driver!.name!
                      : (isBn ? "ড্রাইভার" : "Driver"),
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (driver?.carRegNumber != null && driver!.carRegNumber!.isNotEmpty && driver!.carRegNumber != "N/A") ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      driver!.carRegNumber!,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? "ট্রিপ (${ActiveTripHelper.toBanglaDigits((driver?.totalCompletedTrips ?? 0).toString())})"
                      : "Trips (${driver?.totalCompletedTrips ?? 0})",
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ActiveTripHelper.formatCarType(trip.carCategory?.carType),
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (driver?.phone != null && driver!.phone!.isNotEmpty && driver!.phone != 'N/A') ...[
                    GestureDetector(
                      onTap: () => ActiveTripHelper.launchCallOrUrl(context, "tel:${driver!.phone}"),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
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
                            child: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.translate('call') == 'call' ? "Call" : loc.translate('call'),
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                  ],
                  if (driver?.driverUuid != null && driver!.driverUuid!.isNotEmpty)
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
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
                            child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.translate('chat') == 'chat' ? "Chat" : loc.translate('chat'),
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
