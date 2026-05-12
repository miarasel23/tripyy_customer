import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/utils/colors_code.dart';
import 'package:trippy_customer/widgets/customAdd_button.dart';

class SavedlocationScreen extends StatelessWidget {
  const SavedlocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.savedLocationsScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.savedLocationsScreenAppBarBackground,
        title: Text(
          loc.translate("saved_locations"),
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: AppColors.savedLocationsScreenAppBarText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            savedLocationCredentials(
              loc,
              Icon(
                Icons.home_filled,
                color: AppColors.savedLocationsScreenSavedLocationIcon,
                size: 30,
              ),
              "home",
            ),
            SizedBox(height: 8),
            savedLocationCredentials(
              loc,
              Icon(
                Icons.work,
                color: AppColors.savedLocationsScreenSavedLocationIcon,
                size: 30,
              ),
              "work",
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: CustomAddButton(
                loc: loc,
                labelKey: 'add_location',
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget savedLocationCredentials(
    AppLocalizations loc,
    Widget icon,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.savedLocationsScreenSavedLocationContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate(label),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.savedLocationsScreenSavedLocationTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    loc.translate("set_address"),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.savedLocationsScreenSavedLocationDetails,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: AppColors.savedLocationsScreenSavedLocationArrow,
          ),
        ],
      ),
    );
  }
}
