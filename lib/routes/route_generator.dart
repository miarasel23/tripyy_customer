import 'package:flutter/material.dart';

import '../core/utils/localization/app_localization.dart';
import '../modules/auth/view/screen/number_Input_screen.dart';
import '../modules/dashbiard/view/screen/dashboard_screen.dart';
import '../modules/otp/view/screen/otp_signin_screen.dart';
import '../modules/splash/view/splash_screen.dart';

import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.numberInput:
        return MaterialPageRoute(builder: (_) => NumberInputScreen());

      case AppRoutes.otp:
        final number = settings.arguments as String? ?? "";
        return MaterialPageRoute(builder: (_) => OtpSignIn(number: number));

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
