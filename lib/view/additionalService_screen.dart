import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/routes/app_routes.dart';

class AdditionalserviceScreen extends StatelessWidget {
  const AdditionalserviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(color: Colors.blue),
                ),
                Positioned(
                  bottom: 8,
                  left: 20,
                  child: Text(
                    "Tourist Bus",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 13,
                  child: GestureDetector(
                    onTap: () {
                      // getIt<AppRouter>().pop();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Markdown(
                      data: """
**Need a comfortable bus for your group tour?** Our tourist bus option is perfect for larger parties travelling together. Skip the hussle of finding transportation and enjoy a stress-free journey.
              
- **Perfect for groups:** Be it is 15 people or 25 people, travel comfortably together.
- **Perfect for groups:** Be it is 15 people or 25 people, travel comfortably together.
              
**No bidding needed-** Travel without the hassle of checking bids. Relax and Enjoy.""",
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(fontSize: 17),

                        strong: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: Text(
                            loc.translate("Call_us_for_details:<number>"),
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
