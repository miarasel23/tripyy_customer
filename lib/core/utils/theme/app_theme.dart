import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade700,
        surface: Colors.white,
        onSurface: Colors.black,
        surfaceContainer: Colors.grey.shade100,
        surfaceContainerHighest: Colors.grey.shade200,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF5F5F5),
        thickness: 8,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        surfaceContainer: const Color(0xFF2C2C2C),
        surfaceContainerHighest: const Color(0xFF383838),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        surfaceTintColor: Color(0xFF1E1E1E),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 8,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
