import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../store/important_consts.dart';
import '../../../utils/colors_code.dart';
import '../../../utils/enums.dart';
import '../../../utils/images.dart';
import '../../../widgets/inverted_curve_clipper.dart';
import '../controller/splash_bloc.dart';
import '../controller/splash_event.dart';
import '../controller/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await ImportantConsts.getAccessToken();
      print(token);
      final loc = AppLocalizations.of(context);

      if (token != null) {
        context.read<SplashBloc>().add(
          SplashAuthCheck(
            platform: "web",
            languageCode: loc.locale.languageCode,
            actionWhen: "admin_login",
            email: "superadmin@gmail.com",
            password: "123456",
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.numberInput);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.success) {
          Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
        } else if (state.status == SplashStatus.failure) {
          Navigator.pushReplacementNamed(context, AppRoutes.numberInput);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
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
                    color: AppColors.pageBackground,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 45),

                        /// 🌍 Localized Text
                        firstLine(loc),
                        const SizedBox(height: 8),
                        secondLine(loc),

                        const SizedBox(height: 20),

                        /// 🔘 Button
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.submitButton,
                              foregroundColor: AppColors.submitButtonText,
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
                              loc.translate("get_started"),
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
                    color: AppColors.pageBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔤 TEXT UI

  Widget firstLine(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          loc.translate("city"),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(loc.translate("to"), style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 4),
        Text(
          loc.translate("city"),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget secondLine(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(loc.translate("all"), style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 4),
        Text(
          loc.translate("over"),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(loc.translate("bangladesh"), style: const TextStyle(fontSize: 22)),
      ],
    );
  }
}
