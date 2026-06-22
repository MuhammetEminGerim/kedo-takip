import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class ModernTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.modernText,
      displayColor: AppColors.modernText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.modernPrimary,
        secondary: AppColors.modernSecondary,
        background: AppColors.modernBackground,
        surface: AppColors.modernSurface,
      ),
      scaffoldBackgroundColor: AppColors.modernBackground,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.modernSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.modernPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.modernBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.modernText),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.modernText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.modernSurface,
        selectedItemColor: AppColors.modernPrimary,
        unselectedItemColor: AppColors.modernTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
    );
  }
}
