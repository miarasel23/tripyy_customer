import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes/app_router.dart'; // your file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routeBloc = RouteBloc();

    return BlocProvider(
      create: (_) => routeBloc,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        // ✅ USE YOUR ROUTE MANAGER
        routerDelegate: AppRouteManager(routeBloc),
        routeInformationParser: AppRouteParser(),
      ),
    );
  }
}
