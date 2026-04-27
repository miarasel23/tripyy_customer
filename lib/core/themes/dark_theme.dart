import 'package:flutter/material.dart';
import '../utils/constants/color_code.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'Poppins',
  brightness: Brightness.dark,

  colorScheme: ColorScheme.dark(
    primary: ColorCode.primary,
    secondary: ColorCode.secondary,
    surface: ColorCode.darkSurface,
    background: ColorCode.darkBackground,
    error: ColorCode.error,
  ),

  scaffoldBackgroundColor: ColorCode.darkBackground,
  disabledColor: ColorCode.darkDisabled,
  hintColor: ColorCode.darkTextHint,

  cardTheme: const CardThemeData(color: ColorCode.darkSurface, elevation: 2),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorCode.primary),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: ColorCode.textHint,
    indicator: BoxDecoration(color: ColorCode.secondary),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: ColorCode.darkSurface,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
