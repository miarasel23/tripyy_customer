import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.tripDetailsScreenAppBarBackground,

      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 18, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildAppBar(context, loc),
            SizedBox(height: 20),
            _buildVehicleInfoAndTripType(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoAndTripType(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.tripDetailsScreenContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.car_crash, size: 55),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.translate("trip_details_car_name"),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.people,
                        color: AppColors.tripDetailsScreenSeatInfoLogo,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Text(
                        loc.translate("trip_details_seat_info"),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.tripDetailsScreenSeatInfoText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, size: 20, color: Colors.black),
            ),
            SizedBox(width: 7),
            Text(
              loc.translate("trip_details_appBar_title"),
              style: GoogleFonts.poppins(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }
}
