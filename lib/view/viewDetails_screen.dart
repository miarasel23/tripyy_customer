import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';

class ViewdetailsScreen extends StatelessWidget {
  const ViewdetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            loc.translate("BOISHAK_400"),
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w200,),
          ),
        ),
      ),
    );
  }
}
