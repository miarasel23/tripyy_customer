import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controller/localization_controller.dart';
import 'core/localization/app_localization_delegate.dart';
import 'view/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final LocalizationController controller = LocalizationController();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // ✅ Locale from controller
          locale: controller.locale,

          // ✅ Supported languages
          supportedLocales: const [Locale('en'), Locale('bn')],

          // ✅ VERY IMPORTANT (FIX ERROR)
          localizationsDelegates: const [
            AppLocalizationsDelegate(),

            // 🔥 REQUIRED
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: HomePage(controller: controller),
        );
      },
    );
  }
}
