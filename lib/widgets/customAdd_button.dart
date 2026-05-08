import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';

class CustomAddButton extends StatelessWidget {
  const CustomAddButton({
    super.key,
    required this.loc,
  });

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: BorderSide(
          color: Colors.blue,
          width: 1.5
        ),
        elevation: 0,
        fixedSize: Size(160, 30),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 20,
            color: Colors.blue,
          ),
          Text(
            loc.translate("Add_Location"),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}