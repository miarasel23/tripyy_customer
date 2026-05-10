import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';

class HelpcenterScreen extends StatelessWidget {
  const HelpcenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          loc.translate("help_center"),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.call, color: Colors.white, size: 70),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.translate("how_can_we_help"),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                helpCenterCommonTasks(
                  operation: loc.translate('chat_support'),
                  icon: Icon(Icons.chat_rounded, color: Colors.blue, size: 30),
                ),
                helpCenterCommonTasks(
                  operation: loc.translate('customer_care'),
                  icon: Icon(Icons.chat_rounded, color: Colors.blue, size: 30),
                ),
                helpCenterCommonTasks(
                  operation: 'support@garibook.com',
                  icon: Icon(Icons.mail, color: Colors.blue, size: 30),
                ),
                helpCenterCommonTasks(
                  operation: loc.translate('emergency_service'),
                  icon: Icon(Icons.emergency, color: Colors.blue, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column helpCenterCommonTasks({
    required String operation,
    required Widget icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            print("clicked");
          },
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Color(0xffedf6ff),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon,
                    SizedBox(width: 5),
                    Text(
                      operation,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
