import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/utils/choose_car_args.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../utils/colors_code.dart';

class TripRequestScreen extends StatelessWidget {
  const TripRequestScreen({super.key, required this.args});
  final ChooseCarArgs args;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.tripRequestScreenBackground,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.tripRequestScreenAppBarBackground,
        title: Text(
          loc.translate("intercity"),
          style: GoogleFonts.poppins(
            color: AppColors.tripRequestScreenAppBarText,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding: EdgeInsets.all(5),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffedf6ff),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Test",
                  style: TextStyle(fontSize: 32, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
