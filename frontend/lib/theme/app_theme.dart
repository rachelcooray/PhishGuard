import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF64FFDA); // Neon Teal
  static const Color backgroundColor = Color(0xFF0A192F); // Deep Navy
  static const Color surfaceColor = Color(0xFF112240); // Lighter Navy
  static const Color errorColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFFAB40);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme), // Modern Font
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.5),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: backgroundColor),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: primaryColor,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF2563EB), // Royal Blue
      scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Cool Grey
      cardColor: Colors.white,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme), // Modern Font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Color(0xFF1E293B)),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        secondary: Color(0xFF1E40AF),
        surface: Colors.white,
        background: Color(0xFFF3F4F6),
        error: Color(0xFFDC2626),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        prefixIconColor: const Color(0xFF2563EB),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
    );
  }
}
