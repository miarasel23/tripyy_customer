import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/widgets/custom_appBar.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(loc: loc, title: "Points"),
              SizedBox(height: 20),
              pointsAndPackageInfo(loc),
              SizedBox(height: 15),
              Text(
                loc.translate("Point_History"),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  pointsExpenseButton(title: 'Earned'),
                  pointsExpenseButton(title: 'Benefits'),
                  pointsExpenseButton(title: 'Spent'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pointsExpenseButton({required String title}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Color(0xffeaf4fe),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 17.7, color: Color(0xffa2a3a5)),
        ),
      ),
    );
  }

  Widget pointsAndPackageInfo(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xfffdf2d6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                pointsTopLogo(),
                SizedBox(width: 7),
                availablePointsInfo(loc),
              ],
            ),
          ),
          bronzeClickableButton(loc),
        ],
      ),
    );
  }

  Widget availablePointsInfo(AppLocalizations loc) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate("Available_Points"),
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 12.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                loc.translate("50"),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Text(
                loc.translate("pts"),
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 17),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bronzeClickableButton(AppLocalizations loc) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          shape: BoxShape.rectangle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.ac_unit_rounded, size: 15),
            SizedBox(width: 4),
            Text(
              loc.translate("Bronze"),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 12),
          ],
        ),
      ),
    );
  }

  Widget pointsTopLogo() {
    return Container(
      padding: EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xfffc6801),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.star, color: Colors.white, size: 40),
    );
  }
}
