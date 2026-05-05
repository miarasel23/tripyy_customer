import 'package:flutter/material.dart';

import '../modules/auth/view/screen/numberInput_screen.dart';
import '../modules/splash/view/splash_screen.dart';

import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.numberInput:
        return MaterialPageRoute(builder: (_) => NumberInputScreen());

      // case AppRoutes.dashboard:
      //   return MaterialPageRoute(builder: (_) => const DashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
