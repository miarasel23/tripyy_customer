import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modules/auth/view/screens/splash_screen.dart';
import '../modules/localization/Controller/localization_controller.dart'
    show LocalizationController;

/// =======================
/// ROUTE NAMES
/// =======================
class AppRoutes {
  static const splash = '/';
  static const intro = '/intro';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const home = '/home';
}

/// =======================
/// BLOC EVENTS
/// =======================
abstract class RouteEvent {}

class GoToRoute extends RouteEvent {
  final String route;
  GoToRoute(this.route);
}

class ResetRoute extends RouteEvent {}

/// =======================
/// BLOC STATE
/// =======================
class RouteState {
  final String route;

  const RouteState(this.route);
}

/// =======================
/// ROUTE BLOC
/// =======================
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(const RouteState(AppRoutes.splash)) {
    on<GoToRoute>((event, emit) {
      emit(RouteState(event.route));
    });

    on<ResetRoute>((event, emit) {
      emit(const RouteState(AppRoutes.splash));
    });
  }
}

/// =======================
/// ROUTE MANAGER (SINGLE FILE)
/// =======================
class AppRouteManager extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final RouteBloc routeBloc;

  AppRouteManager(this.routeBloc) : navigatorKey = GlobalKey<NavigatorState>() {
    routeBloc.stream.listen((_) => notifyListeners());
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  String? get currentConfiguration => routeBloc.state.route;

  @override
  Widget build(BuildContext context) {
    final route = routeBloc.state.route;

    return Navigator(
      key: navigatorKey,
      pages: [
        if (route == AppRoutes.splash)
          MaterialPage(
            child: SplashScreen(controller: LocalizationController()),
          ),

        // if (route == AppRoutes.intro) const MaterialPage(child: IntroScreen()),

        // if (route == AppRoutes.login) const MaterialPage(child: LoginScreen()),

        // if (route == AppRoutes.dashboard)
        //   const MaterialPage(child: DashboardScreen()),

        // if (route == AppRoutes.home) const MaterialPage(child: HomeScreen()),
      ],
      // ignore: deprecated_member_use
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    routeBloc.add(GoToRoute(configuration));
  }
}

/// =======================
/// ROUTE PARSER
/// =======================
class AppRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    // ignore: deprecated_member_use
    return routeInformation.location;
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    // ignore: deprecated_member_use
    return RouteInformation(location: configuration);
  }
}
