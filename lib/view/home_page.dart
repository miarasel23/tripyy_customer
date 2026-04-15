import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/modules/localization/Controller/localization_controller.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/utils/images.dart';
import 'package:trippy_customer/view/otp_screen.dart';

class HomePage extends StatelessWidget {
  final LocalizationController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final TextEditingController numberField = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate("enter_your_phone_number"),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              numberBasedLoginField(loc, numberField),
              const SizedBox(height: 10),

              controller.locale.languageCode == "en"
                  ? richTextEnglish(loc)
                  : richTextBangla(loc),

              SizedBox(height: 16),

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
                  getIt<AppRouter>().push(OtpScreen(number: numberField.text, loc: loc, controller: controller,));
                },
                child: Text(
                  loc.translate("Continue"),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),

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
            color: Color(0xffedf6ff),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Images.countryflag, height: 25, width: 25),
                        SizedBox(width: 16),
                        Text(
                          loc.translate("+880"),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Form(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: loc.translate("enter_your_number"),
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffa2a3a4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
