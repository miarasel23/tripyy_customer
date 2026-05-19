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
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocalizationBloc()),
        BlocProvider(create: (_) => MainBottomNavBarBloc()),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localizationState) {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              )
            ),
            debugShowCheckedModeBanner: false,

            // 🌍 Localization
            locale: localizationState.locale,
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
          );
        },
      ),
    );
  }
}
