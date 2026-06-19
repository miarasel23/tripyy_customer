import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';
import '../../../../widgets/customAdd_button.dart';

class SavedlocationScreen extends StatelessWidget {
  const SavedlocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          loc.translate("saved_locations"),
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
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
              context,
              loc,
              Icon(
                Icons.home_filled,
                color: Theme.of(context).colorScheme.onSurface,
                size: 30,
              ),
              "home",
            ),
            SizedBox(height: 8),
            savedLocationCredentials(
              context,
              loc,
              Icon(
                Icons.work,
                color: Theme.of(context).colorScheme.onSurface,
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
                  color: AppColors.savedLocationsScreenSavedLocationButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget savedLocationCredentials(
    BuildContext context,
    AppLocalizations loc,
    Widget icon,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
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
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    loc.translate("set_address"),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
