import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'military_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get militaryTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MilitaryColors.bgPrimary,
      
      colorScheme: const ColorScheme.dark(
        primary: MilitaryColors.accent,
        secondary: MilitaryColors.accentCyan,
        tertiary: MilitaryColors.accentOlive,
        surface: MilitaryColors.bgSecondary,
        background: MilitaryColors.bgPrimary,
        error: MilitaryColors.danger,
        onPrimary: MilitaryColors.bgPrimary,
        onSecondary: MilitaryColors.bgPrimary,
        onSurface: MilitaryColors.textPrimary,
        onBackground: MilitaryColors.textPrimary,
      ),

      textTheme: GoogleFonts.orbitronTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: MilitaryColors.textPrimary,
        displayColor: MilitaryColors.textPrimary,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: MilitaryColors.accent,
          letterSpacing: 3,
        ),
        headlineMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MilitaryColors.textPrimary,
          letterSpacing: 2,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MilitaryColors.textPrimary,
          letterSpacing: 1,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14,
          color: MilitaryColors.textSecondary,
          letterSpacing: 1,
        ),
        bodyMedium: const TextStyle(
          fontSize: 12,
          color: MilitaryColors.textMuted,
        ),
        labelLarge: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MilitaryColors.accent,
          letterSpacing: 2,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardTheme(
        color: MilitaryColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: MilitaryColors.accent.withOpacity(0.15),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MilitaryColors.accent,
          foregroundColor: MilitaryColors.bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: MilitaryColors.accent,
      ),
    );
  }
}
