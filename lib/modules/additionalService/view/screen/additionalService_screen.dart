import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';

class AdditionalserviceScreen extends StatelessWidget {
  const AdditionalserviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.additionalServiceScreenBackground,
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
                  decoration: BoxDecoration(
                    color: AppColors.additionalServiceScreenNameContainer,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 20,
                  child: Text(
                    loc.translate("additional_service_name"),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.additionalServiceScreenNameText,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 13,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.additionalServiceScreenNameContainerIcon,
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
                color: AppColors.additionalServiceScreenDescriptionContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Markdown(
                      data: loc.translate("additional_service_desc"),
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
                            backgroundColor: AppColors
                                .additionalServiceScreenCallMessageButtonBackground,
                            foregroundColor: AppColors
                                .additionalServiceScreenCallMessageButtonForeground,
                          ),
                          onPressed: () {},
                          child: Text(
                            loc.translate("call_message_and_number"),
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
