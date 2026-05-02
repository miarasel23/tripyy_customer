import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/routes/app_router.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.loc, required this.title});

  final AppLocalizations loc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            getIt<AppRouter>().pop();
          },
          child: Icon(Icons.arrow_back, size: 25),
        ),
        SizedBox(width: 10),
        Text(
          loc.translate(title),
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}