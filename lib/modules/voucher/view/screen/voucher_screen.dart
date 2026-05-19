import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.voucherScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.voucherScreenAppBarBackground,
        title: Text(
          loc.translate("voucher_appbar_title"),
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 50),
            SizedBox(height: 4),
            Text(
              loc.translate("voucher_empty_warning"),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Text(
              loc.translate("voucher_come_back_message"),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.voucherScreenNoVoucherComeBackText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}