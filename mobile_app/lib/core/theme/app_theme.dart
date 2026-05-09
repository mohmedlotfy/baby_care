import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF5DB075);
  static const Color primaryLight = Color(0xFFE8F5ED);
  static const Color secondaryColor = Color(0xFF8DC5A2);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF7F5F2);
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color textColor = textDark; // Alias
  
  static const Color accentColor = secondaryColor; // Alias

  // Status Colors
  static const Color error = Color(0xFFE84118);
  static const Color warning = Color(0xFFE8A44C);
  static const Color success = Color(0xFF5DB075);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        error: error,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.cairoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
