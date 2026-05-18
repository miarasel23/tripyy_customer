import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/colors_code.dart';
import '../../../../widgets/custom_app_bar.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 18, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(loc: loc, title: "points"),
            SizedBox(height: 15),
            _buildAvailablePointsWithLevelButtonWidget(loc, context),
            SizedBox(height: 15),
            Text(
              loc.translate("points_history_text"),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3),
            _buildpointsUsageHistory(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildpointsUsageHistory(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size.zero,
            backgroundColor:
                AppColors.pointsScreenPointsHistoryButtonsContainer,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          onPressed: () {},
          child: Text(
            loc.translate("points_history_earned_button"),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.pointsScreenPointsHistoryButtonsText,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size.zero,
            backgroundColor:
                AppColors.pointsScreenPointsHistoryButtonsContainer,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          onPressed: () {},
          child: Text(
            loc.translate("points_history_benefits_button"),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.pointsScreenPointsHistoryButtonsText,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size.zero,
            backgroundColor:
                AppColors.pointsScreenPointsHistoryButtonsContainer,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          onPressed: () {},
          child: Text(
            loc.translate("points_history_spent_button"),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.pointsScreenPointsHistoryButtonsText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailablePointsWithLevelButtonWidget(
    AppLocalizations loc,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.pointsScreenPointsInfoContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pointsScreenPointsIconContainer,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.star,
                size: 35,
                color: AppColors.pointsScreenPointsIcon,
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate("points_available_point_text"),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("points_available_point_value"),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    loc.translate("points_available_pts_text"),
                    style: GoogleFonts.poppins(fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.userLevel);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.pointsScreenPointsButtonContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.badge, size: 17),
                  SizedBox(width: 5),
                  Text(
                    loc.translate("points_button_text"),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  SizedBox(width: 7),
                  Icon(Icons.arrow_forward_ios, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
