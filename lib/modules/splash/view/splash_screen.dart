import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/images.dart';
import '../../../widgets/inverted_curve_clipper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.numberInput);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// 🔥 Background Image
            SizedBox(
              height: 600,
              width: double.infinity,
              child: Image.asset(Images.splashScreenBgImg, fit: BoxFit.cover),
            ),

            /// 🔥 Bottom Curved Section
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
                      const SizedBox(height: 45),

                      /// 🌍 Language Based Text
                      langCode == "bn"
                          ? Column(
                              children: [
                                firstLine(),
                                const SizedBox(height: 8),
                                secondLine(),
                              ],
                            )
                          : Column(
                              children: [
                                firstLineEn(),
                                const SizedBox(height: 8),
                                secondLineEn(),
                              ],
                            ),

                      const SizedBox(height: 20),

                      /// 🔘 Button
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0e52ff),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.numberInput,
                            );
                          },
                          child: Text(
                            loc.translate("Get_Started"),
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

            /// 📍 Floating Icon
            Positioned(
              bottom: 270,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔤 TEXT FUNCTIONS

  Row firstLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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

  Row secondLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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

  Row firstLineEn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "City",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Text("to", style: TextStyle(fontSize: 22)),
        SizedBox(width: 4),
        Text(
          "City",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Row secondLineEn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text("All", style: TextStyle(fontSize: 22)),
        SizedBox(width: 4),
        Text(
          "Over",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Text("Bangladesh!", style: TextStyle(fontSize: 22)),
      ],
    );
  }
}
