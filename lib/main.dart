import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/utils/localization/app_localization_delegate.dart';
import 'core/utils/localization/app_localization.dart';
import 'modules/auth/controller/send_otp_bloc.dart';
import 'modules/auth/repository/send_otp_repository.dart';
import 'modules/editProfile/controller/edit_profile_info_bloc.dart';
import 'modules/editProfile/controller/edit_profile_picture_bloc.dart';
import 'modules/editProfile/repository/edit_profile_repository.dart';
import 'modules/localization/Controller/localization_controller.dart';

import 'modules/mainBottomNavBar/controller/main_bottom_nav_bar_bloc.dart';
import 'modules/myTrip/controller/my_trip_bloc.dart';
import 'modules/otp/controller/otp_receive_bloc.dart';
import 'modules/otp/repository/otp_receive_repository.dart';
import 'modules/points/controller/points_bloc.dart';
import 'modules/splash/controller/splash_bloc.dart';
import 'modules/splash/repository/splash_repository.dart';
import 'modules/userLevel/controller/user_level_bloc.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import 'utils/choose_car_bottom_sheet/repository/choose_car_bottom_sheet_repository.dart';
import 'store/app_globals.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppGlobals.init();
  runApp(MyApp());
}

final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isFirstCheck = true;
  
  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasInternet = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    if (_isFirstCheck && hasInternet) {
      _isFirstCheck = false;
      return;
    }
    _isFirstCheck = false;

    String noInternetStr = "No Internet Connection";
    String backOnlineStr = "Back Online";
    final context = globalScaffoldMessengerKey.currentContext;
    if (context != null) {
      final loc = AppLocalizations.of(context);
      noInternetStr = loc.translate("no_internet") ?? noInternetStr;
      backOnlineStr = loc.translate("back_online") ?? backOnlineStr;
    }

    if (!hasInternet) {
      globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      globalScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(noInternetStr),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(days: 1),
        ),
      );
    } else {
      globalScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      globalScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(backOnlineStr),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocalizationBloc()),
        BlocProvider(create: (_) => MainBottomNavBarBloc()),
        BlocProvider(create: (_) => PointsBloc()),
        BlocProvider(create: (_) => MyTripBloc()),
        BlocProvider(create: (_) => UserLevelBloc()),
        BlocProvider(
          create: (_) => OtpReceiveBloc(repository: OtpReceiveRepository()),
        ),
        BlocProvider(
          create: (_) => SendOtpBloc(repository: SendOtpRepository()),
        ),
        BlocProvider(create: (_) => SplashBloc(repository: SplashRepository())),
        BlocProvider(
          create: (_) => EditProfilePictureBloc(
            repository: EditProfileRepository(repository: SplashRepository()),
          ),
        ),
        BlocProvider(
          create: (_) => EditProfileInfoBloc(
            repository: EditProfileRepository(repository: SplashRepository()),
          ),
        ),
        BlocProvider(
          create: (_) => ChooseCarBottomSheetBloc(repository: ChooseCarBottomSheetRepository()),
        ),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localizationState) {
          return MaterialApp(
            scaffoldMessengerKey: globalScaffoldMessengerKey,
            theme: ThemeData(
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
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
