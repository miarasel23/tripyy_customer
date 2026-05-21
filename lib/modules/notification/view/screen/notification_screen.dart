import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.notificationScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.notificationScreenAppBarBackground,
        title: Text(
          loc.translate("notification_appbar_title"),
          style: GoogleFonts.poppins(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 17.0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.notificationScreenClearAllContainer,
                border: Border.all(
                  width: 1,
                  color: AppColors.notificationScreenClearAllContainerBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.clear_all, size: 13),
                  SizedBox(width: 3),
                  Text(
                    loc.translate("notification_clear_all"),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.notificationScreenClearAllText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 50),
            SizedBox(height: 4),
            Text(
              loc.translate("notification_empty_warning"),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Text(
              loc.translate("notification_saying_no_notification"),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.notificationScreenNoNotificationComeBackText,
              ),
            ),
            Text(
              loc.translate("notification_come_back_message"),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.notificationScreenNoNotificationComeBackText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
