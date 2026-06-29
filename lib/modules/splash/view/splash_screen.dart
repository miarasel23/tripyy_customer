import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../store/user_data_store.dart';
import 'widgets/trippy_brand_animation.dart';
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
      // Let the beautiful Trippy animation play for 4 seconds
      await Future.delayed(const Duration(seconds: 4));
      
      // Attempt to load user data in background if needed
      await UserDataStore.getUserData();
      
      // Get the last route the user visited
      final lastRoute = await UserDataStore.getLastRoute();

      // Navigate to last route if exists, otherwise to default home
      if (mounted) {
        if (lastRoute != null && lastRoute.isNotEmpty) {
          Navigator.pushReplacementNamed(context, lastRoute);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
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
