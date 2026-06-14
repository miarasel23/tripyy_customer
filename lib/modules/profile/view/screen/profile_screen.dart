import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/colors_code.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrls.profileImageUrl;
    final loc = AppLocalizations.of(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.profileScreenBackground,
        body: Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 2),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.profileScreenCoverBanner,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: double.infinity,
                        height: 65,
                      ),
                      Positioned(
                        top: 28,
                        left: 133,
                        child: Container(
                          // padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.profileScreenProfileBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Builder(
                            builder: (context) {
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                return ClipOval(
                                  child: SizedBox(
                                    width: 55,
                                    height: 55,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder: (_, _, _) {
                                        return const Icon(Icons.person);
                                      },
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: AppColors
                                        .profileScreenProfileBackgroundBorder,
                                  ),
                                  color:
                                      AppColors.profileScreenProfileBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.profileScreenProfileIcon,
                                  size: 35,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 71,
                        left: 146,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                AppColors.profileScreenProfileRatingContainer,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      loc.translate("5"),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors
                                            .profileScreenProfileRatingText,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.star,
                                      color: AppColors
                                          .profileScreenProfileRatingStar,
                                      size: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 38),
                  Text(
                    loc.translate("user_name"),
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                    child: Text(
                      loc.translate("view_profile"),
                      style: TextStyle(
                        color: AppColors.profileScreenViewProfileText,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            AppColors.profileScreenViewProfileTextDecoration,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.points);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: AppColors.profileScreenPointsContainer,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: AppColors
                                      .profileScreenPointsBadgeContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: AppColors.profileScreenPointsBadgeIcon,
                                  size: 14,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                loc.translate("points"),
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(width: 50),
                              Icon(Icons.arrow_forward_ios_outlined, size: 15),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.voucher);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: AppColors.profileScreenVoucherContainer,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.countertops,
                                color: AppColors.profileScreenVoucherIcon,
                                size: 24,
                              ),
                              SizedBox(width: 3),
                              Text(
                                loc.translate("voucher"),
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(width: 50),
                              Icon(Icons.arrow_forward_ios_outlined, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.translate("preferences"),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.profileScreenPreferencesText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.profileScreenPreferencesContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: AppColors
                                  .profileScreenPreferencesOptionsContainer,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.signal_wifi_connected_no_internet_4,
                                      size: 20,
                                      color: AppColors
                                          .profileScreenPreferencesOptionsIcon,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      loc.translate("language"),
                                      style: TextStyle(
                                        color: AppColors
                                            .profileScreenPreferencesOptionsText,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .profileScreenPreferencesOptionsHighlighter,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        loc.translate("english"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenPreferencesOptionsHighlighterText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 18),
                                    Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenPreferencesOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenPreferencesOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("notification"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenPreferencesOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        child: Transform.scale(
                                          scale: 0.6,
                                          child: Switch(
                                            value: true,
                                            onChanged: (val) {},
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            activeTrackColor: AppColors
                                                .profileScreenPreferencesOptionsSwitchActiveTrackColor,
                                            inactiveTrackColor: AppColors
                                                .profileScreenPreferencesOptionsSwitchInactiveTrackColor,
                                            thumbColor: WidgetStateProperty.all(
                                              AppColors
                                                  .profileScreenPreferencesOptionsSwitchThumbColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenPreferencesOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenPreferencesOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("tutorial"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenPreferencesOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.translate("legal"),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.profileScreenLegalText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpCenter);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.profileScreenLegalContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.profileScreenLegalOptionsContainer,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.signal_wifi_connected_no_internet_4,
                                      size: 20,
                                      color: AppColors
                                          .profileScreenLegalOptionsIcon,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      loc.translate("help"),
                                      style: TextStyle(
                                        color: AppColors
                                            .profileScreenLegalOptionsText,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 18),
                                Icon(Icons.arrow_forward_ios_sharp, size: 15),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenLegalOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenLegalOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("terms_conditions"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenLegalOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenLegalOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenLegalOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("trip_terms_conditions"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenLegalOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenLegalOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenLegalOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("privacy_policy"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenLegalOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .profileScreenLegalOptionsContainer,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons
                                            .signal_wifi_connected_no_internet_4,
                                        size: 20,
                                        color: AppColors
                                            .profileScreenLegalOptionsIcon,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        loc.translate("logout"),
                                        style: TextStyle(
                                          color: AppColors
                                              .profileScreenLegalOptionsText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.arrow_forward_ios_sharp, size: 15),
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
        ),
      ),
    );
  }
}
