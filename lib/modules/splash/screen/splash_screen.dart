import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../routes/app_routes.dart';
import '../../../store/user_data_store.dart';

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
      // Attempt to load user data from local store safely
      try {
        await UserDataStore.getUserData();
      } catch (_) {}

      try {
        await UserDataStore.getAccessToken();
      } catch (_) {}

      try {
        await UserDataStore.getUuid();
      } catch (_) {}
      
      final token = UserDataStore.accessToken;
      final uuid = UserDataStore.uuid;
      final isLoggedIn = token != null && token.isNotEmpty && uuid != null && uuid.isNotEmpty;

      if (mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
        } else {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          await UserDataStore.clearAllData();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.numberInput);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * 0.65).clamp(260.0, 420.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SvgPicture.asset(
            'assets/images/tripyy_logo.svg',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
