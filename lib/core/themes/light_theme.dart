import 'package:flutter/material.dart';

import '../utils/constants/color_code.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'Poppins',
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: ColorCode.primary,
    secondary: ColorCode.secondary,
    surface: ColorCode.surface,
    background: ColorCode.background,
    error: ColorCode.error,
  ),

  scaffoldBackgroundColor: ColorCode.background,
  disabledColor: ColorCode.disabled,
  hintColor: ColorCode.textHint,

  cardTheme: const CardThemeData(color: ColorCode.surface, elevation: 2),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorCode.primary),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: Colors.black,
    unselectedLabelColor: ColorCode.textSecondary,
    indicator: BoxDecoration(color: ColorCode.secondary),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: ColorCode.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
