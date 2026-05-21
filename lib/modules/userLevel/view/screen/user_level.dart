import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';
import '../../../../widgets/custom_progress_bar.dart';

class UserLevel extends StatelessWidget {
  const UserLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.userLevelScreenBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.userLevelScreenAppBarBackground,
            elevation: 0,
            title: Text(
              loc.translate("user_level_screen_appbar_title"),
              style: GoogleFonts.poppins(fontSize: 20),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 18, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  _buildUserLevelInfo(loc),
                  SizedBox(height: 13),
                  _buildPointsOfEachLevelInfo(loc),
                  SizedBox(height: 13),
                  _buildCompanyBrief(),
                  SizedBox(height: 13),
                  Text(
                    loc.translate("user_level_faq_text"),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 13),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_1")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_2")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_3")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_4")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_5")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_6")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_7")),
                  SizedBox(height: 8),
                  _buildFaqQuestion(loc.translate("user_level_screen_faq_8")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqQuestion(String title) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.userLevelScreenFaqContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            child: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.arrow_downward, size: 18),
        ],
      ),
    );
  }

  Widget _buildCompanyBrief() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.userLevelScreenCompanyBriefContainer,
        border: Border.all(
          width: 1,
          color: AppColors.userLevelScreenCompanyBriefBorder,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.",
        style: GoogleFonts.poppins(
          color: AppColors.userLevelScreenCompanyBriefText,
        ),
      ),
    );
  }

  Widget _buildPointsOfEachLevelInfo(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLevelPointsInfo(
          Icon(Icons.circle_notifications, size: 43),
          loc.translate("user_level_bronze_text"),
          loc.translate("user_level_bronze_points"),
          AppColors.userLevelScreenLevelPointsInfo,
        ),
        _buildLevelPointsInfo(
          Icon(Icons.sign_language, size: 43),
          loc.translate("user_level_silver_text"),
          loc.translate("user_level_silver_points"),
          AppColors.userLevelScreenLevelPointsInfo,
        ),
        _buildLevelPointsInfo(
          Icon(Icons.sign_language, size: 43),
          loc.translate("user_level_gold_text"),
          loc.translate("user_level_gold_points"),
          AppColors.userLevelScreenLevelPointsInfo,
        ),
        _buildLevelPointsInfo(
          Icon(Icons.sign_language, size: 43),
          loc.translate("user_level_platinum_text"),
          loc.translate("user_level_platinum_points"),
          AppColors.userLevelScreenLevelPointsInfo,
        ),
      ],
    );
  }

  Widget _buildLevelPointsInfo(
    Widget icon,
    String levelName,
    String points,
    Color backgroundColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        SizedBox(height: 3),
        Text(
          levelName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        Text(
          points,
          style: GoogleFonts.poppins(
            color: AppColors.userLevelScreenLevelPointsText,
          ),
        ),
      ],
    );
  }

  Widget _buildUserLevelInfo(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.userLevelScreenUserLevelInfoContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("user_level_user_dedicating_text"),
                    style: GoogleFonts.poppins(fontSize: 13, height: 1),
                  ),
                  SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        loc.translate("user_level_bronze_text"),
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          color: AppColors.userLevelScreenPointsInfoLevelColor,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        loc.translate("user_level_user_text"),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.circle_notifications, size: 42),
            ],
          ),
          SizedBox(height: 9),
          CustomProgressBar(),
          SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              loc.translate("user_level_user_score"),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
