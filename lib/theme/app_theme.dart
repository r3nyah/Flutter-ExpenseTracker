import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF006D6F); // Deep Teal
  static const Color accent = Color(0xFFFF6F61);  // Coral

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary,
      textTheme: GoogleFonts.poppinsTextTheme(),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
      ),
    );
  }
}
