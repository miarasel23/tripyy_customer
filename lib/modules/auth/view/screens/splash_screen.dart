import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/constants/color_code.dart' show ColorCode;
import '../../../../core/utils/localization/app_localization.dart'
    show AppLocalizations;
import '../../../../utils/images.dart';
import '../../../../widgets/inverted_curve_clipper.dart';
import '../../../localization/Controller/localization_controller.dart'
    show LocalizationController;

class SplashScreen extends StatefulWidget {
  final LocalizationController controller;

  const SplashScreen({super.key, required this.controller});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Images.countryflag, height: 120),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate("welcome_to_trippy"),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
