import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkText),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkText),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkText),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkText),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkText),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkText),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkText),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        tertiary: AppColors.darkTertiary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 24,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}
