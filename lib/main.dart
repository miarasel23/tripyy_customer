import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controller/bloc/main_bottom_nav_bar/main_bottom_nav_bar_bloc.dart';
import 'core/utils/localization/app_localization_delegate.dart';
import 'modules/localization/Controller/localization_controller.dart';

import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        return BlocProvider(
          create: (_) => MainBottomNavBarBloc(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,

            // 🌍 Localization
            locale: controller.locale,
            supportedLocales: const [Locale('en'), Locale('bn')],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 🔥 ROUTING
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
          ),
        );
      },
    );
  }
}
