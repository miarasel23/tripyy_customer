import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/modules/localization/Controller/localization_controller.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/utils/images.dart';
import 'package:trippy_customer/view/editProfile_screen.dart';
import 'package:trippy_customer/view/helpCenter_screen.dart';
import 'package:trippy_customer/view/myTrip_screen.dart';
import 'package:trippy_customer/view/offer_screen.dart';
import 'package:trippy_customer/view/profile_screen.dart';

class OtpScreen extends StatelessWidget {
  final String number;
  final AppLocalizations loc;
  final LocalizationController controller;

  const OtpScreen({
    super.key,
    required this.number,
    required this.loc,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final TextEditingController numberField = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 13.0, top: 5),
              child: InkWell(
                onTap: () {
                  getIt<AppRouter>().pop();
                },
                child: Icon(Icons.arrow_back),
              ),
            ),
            SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("enter_the_otp_sent_to_you_at"),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "+880$number",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  numberBasedLoginField(loc, numberField),
                  const SizedBox(height: 10),

                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: Text(
                      loc.translate("Change_Number"),
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0e52ff),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      getIt<AppRouter>().push(EditprofileScreen());
                    },
                    child: Text(
                      loc.translate("Continue"),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        text: loc.translate("resend_code_in"),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xffb3b3b3),
                        ),
                        children: [
                          TextSpan(
                            text: "02:00",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          controller.changeLanguage('en');
                        },
                        child: const Text("English"),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          controller.changeLanguage('bn');
                        },
                        child: const Text("বাংলা"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget richTextEnglish(AppLocalizations loc) {
    return RichText(
      text: TextSpan(
        text: "By proceeding, you consent to agree with our ",
        style: TextStyle(fontSize: 14, color: Color(0xffb3b3b3)),
        children: [
          TextSpan(
            text: "Terms and Conditions",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget richTextBangla(AppLocalizations loc) {
    return RichText(
      text: TextSpan(
        text: "এগিয়ে যাওয়ার মাধ্যমে, আপনি আমাদের ",
        style: TextStyle(fontSize: 13, color: Color(0xffb3b3b3)),
        children: [
          TextSpan(
            text: "শর্তাবলী ও নিয়মাবলীর ",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: "সাথে সম্মত হতে রাজি হচ্ছেন।",
            style: TextStyle(fontSize: 16, color: Color(0xffb3b3b3)),
          ),
        ],
      ),
    );
  }

  Column numberBasedLoginField(
    AppLocalizations loc,
    TextEditingController controller,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: MaterialPinField(
                  length: 6,
                  onCompleted: (pin) => print('PIN: $pin'),
                  onChanged: (value) => print('Changed: $value'),
                  theme: MaterialPinTheme(
                    shape: MaterialPinShape.outlined,
                    cellSize: Size(46, 64),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
