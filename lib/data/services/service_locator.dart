import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trippy_customer/routes/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerLazySingleton(() => AppRouter());
  
}