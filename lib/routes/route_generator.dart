import 'package:flutter/material.dart';
import 'package:trippy_customer/modules/notification/view/screen/notifiication_screen.dart';

import '../modules/additionalService/view/screen/additionalService_screen.dart';
import '../modules/auth/view/screen/number_Input_screen.dart';
import '../modules/dashbiard/view/screen/dashboard_screen.dart';
import '../modules/editProfile/view/screen/editProfile_screen.dart';
import '../modules/helpCenter/view/screen/helpCenter_screen.dart';
import '../modules/mainBottomNavBar/view/screen/main_bottom_nav_bar_screen.dart';
import '../modules/offerDetails/view/screen/offerDetails_screen.dart';
import '../modules/otp/view/screen/otp_signin_screen.dart';
import '../modules/points/view/screen/points_screen.dart';
import '../modules/savedLocation/view/screen/savedLocation_screen.dart';
import '../modules/savedRoutes/view/screen/savedRoutes_screen.dart';
import '../modules/splash/view/splash_screen.dart';
import '../modules/tripDetails/view/screen/trip_details_screen.dart';
import '../modules/userLevel/view/screen/user_level.dart';
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

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditprofileScreen());

      case AppRoutes.helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpcenterScreen());
      case AppRoutes.bottomNav:
        return MaterialPageRoute(
          builder: (_) => const MainBottomNavBarScreen(),
        );
      case AppRoutes.savedLoc:
        return MaterialPageRoute(builder: (_) => const SavedlocationScreen());
      case AppRoutes.savedRoute:
        return MaterialPageRoute(builder: (_) => const SavedroutesScreen());
      case AppRoutes.viewDetails:
        return MaterialPageRoute(builder: (_) => const OfferdetailsScreen());
      case AppRoutes.additionalService:
        return MaterialPageRoute(
          builder: (_) => const AdditionalserviceScreen(),
        );
      case AppRoutes.tripDetails:
        return MaterialPageRoute(builder: (_) => const TripDetailsScreen());
      case AppRoutes.points:
        return MaterialPageRoute(builder: (_) => const PointsScreen());
      case AppRoutes.userLevel:
        return MaterialPageRoute(builder: (_) => const UserLevel());
      case AppRoutes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
