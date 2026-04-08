import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/utils/images.dart';
import '../controller/localization_controller.dart';
import '../core/localization/app_localization.dart';

class HomePage extends StatelessWidget {
  final LocalizationController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
              numberBasedLoginField(loc),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: loc.translate("by_proceeding,_you_consent_to_agree_with_our"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xffb3b3b3)
                  ),
                  children: [
                    TextSpan(
                      text: loc.translate("by_proceeding,_you_consent_to_agree_with_our"),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                      )
                    )
                  ]
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  controller.changeLanguage('en');
                },
                child: const Text("English"),
              ),

              ElevatedButton(
                onPressed: () {
                  controller.changeLanguage('bn');
                },
                child: const Text("বাংলা"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column numberBasedLoginField(AppLocalizations loc) {
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
