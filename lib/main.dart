import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trippy_customer/core/utils/localization/app_localization_delegate.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/modules/localization/Controller/localization_controller.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/view/splash_screen.dart';

Future<void> main() async {
  await setupServiceLocator();
  
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
          navigatorKey: getIt<AppRouter>().navigatorKey,
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

          home: SplashScreen(controller: controller),
        );
      },
    );
  }
}
