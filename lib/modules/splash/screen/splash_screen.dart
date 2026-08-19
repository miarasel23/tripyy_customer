import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../store/user_data_store.dart';
import '../widget/trippy_brand_animation.dart';

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
        debugPrint("Splash: Loaded user data successfully: ${UserDataStore.userData?.data?.user?.fullName}");
      } catch (e, stack) {
        debugPrint("Splash: Error loading user data: $e");
        debugPrint(stack.toString());
      }

      try {
        await UserDataStore.getAccessToken();
        debugPrint("Splash: Loaded access token: ${UserDataStore.accessToken}");
      } catch (e) {
        debugPrint("Splash: Error loading token: $e");
      }

      try {
        await UserDataStore.getUuid();
        debugPrint("Splash: Loaded UUID: ${UserDataStore.uuid}");
      } catch (e) {
        debugPrint("Splash: Error loading UUID: $e");
      }
      
      final token = UserDataStore.accessToken;
      final uuid = UserDataStore.uuid;
      final isLoggedIn = token != null && token.isNotEmpty && uuid != null && uuid.isNotEmpty;

      if (mounted) {
        if (isLoggedIn) {
          debugPrint("Splash: Logged in user detected, entering home page immediately.");
          Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
        } else {
          debugPrint("Splash: New/Logged out user, showing splash animation.");
          await Future.delayed(const Duration(seconds: 4));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Match the animation background perfectly
      body: const SafeArea(
        child: Center(
          child: TrippyBrandAnimation(),
        ),
      ),
    );
  }
}
