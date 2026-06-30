import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'deep_ocean_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DeepOceanColors.bgPrimary,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: DeepOceanColors.accent,
        secondary: DeepOceanColors.accentTeal,
        tertiary: DeepOceanColors.accentIndigo,
        surface: DeepOceanColors.bgSecondary,
        background: DeepOceanColors.bgPrimary,
        error: DeepOceanColors.error,
        onPrimary: DeepOceanColors.bgPrimary,
        onSecondary: DeepOceanColors.bgPrimary,
        onSurface: DeepOceanColors.textPrimary,
        onBackground: DeepOceanColors.textPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: DeepOceanColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: DeepOceanColors.textPrimary),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: DeepOceanColors.textPrimary,
        displayColor: DeepOceanColors.textPrimary,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: DeepOceanColors.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: DeepOceanColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DeepOceanColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: DeepOceanColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: DeepOceanColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: DeepOceanColors.textSecondary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: DeepOceanColors.textMuted,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: DeepOceanColors.textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: DeepOceanColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DeepOceanColors.accent,
          foregroundColor: DeepOceanColors.bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DeepOceanColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DeepOceanColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: DeepOceanColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DeepOceanColors.bgSecondary,
        selectedItemColor: DeepOceanColors.accent,
        unselectedItemColor: DeepOceanColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: DeepOceanColors.bgCard,
        thickness: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: DeepOceanColors.bgCard,
        selectedColor: DeepOceanColors.accent,
        labelStyle: const TextStyle(color: DeepOceanColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
