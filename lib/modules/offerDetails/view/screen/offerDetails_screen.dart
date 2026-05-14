import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/utils/colors_code.dart';

class OfferdetailsScreen extends StatelessWidget {
  const OfferdetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.offerDetailsScreenBackground,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.offerDetailsScreenAppBarBackground,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            loc.translate("boishak_400"),
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: AppColors.offerDetailsScreenAppBarText,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.offerDetailsScreenOfferContainer,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 10),
            Text(
              loc.translate("boishak_400"),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              loc.translate("offer_desc"),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
