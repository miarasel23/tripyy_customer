import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/modules/localization/Controller/localization_controller.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/utils/images.dart';
import 'package:trippy_customer/view/home_page.dart';
import 'package:trippy_customer/widgets/inverted_curve_clipper.dart';

class SplashScreen extends StatefulWidget {
  final LocalizationController controller;

  const SplashScreen({super.key, required this.controller});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      getIt<AppRouter>().pushReplacement(
        HomePage(controller: widget.controller),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: 600,
              width: double.infinity,
              child: Image.asset(Images.splashScreenBgImg, fit: BoxFit.cover),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: InvertedCurveClipper(),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: const BoxDecoration(color: Color(0xffededed)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 45),
                      firstLine(),
                      secondLine(),
                      SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xff0e52ff),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 270,
              left: 155,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: Colors.blue, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row secondLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("সারা", style: TextStyle(fontSize: 22)),
        SizedBox(width: 4),
        Text(
          "বাংলাদেশ",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Text("জুড়ে!", style: TextStyle(fontSize: 22)),
      ],
    );
  }

  Row firstLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "শহর",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Text("থেকে", style: TextStyle(fontSize: 22)),
        SizedBox(width: 4),
        Text(
          "শহরে",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
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
