import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class PlayfulTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.playfulText),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.playfulText),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.playfulText),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.playfulText),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.playfulText),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.playfulText),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.playfulPrimary,
        secondary: AppColors.playfulSecondary,
        tertiary: AppColors.playfulTertiary,
        surface: AppColors.playfulSurface,
        primaryContainer: AppColors.playfulAccentPeach,
        secondaryContainer: AppColors.playfulAccentBlue,
      ),
      scaffoldBackgroundColor: AppColors.playfulBackground,
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        color: AppColors.playfulSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.playfulPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.playfulBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.playfulText),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.playfulText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.playfulSurface,
        selectedItemColor: AppColors.playfulPrimary,
        unselectedItemColor: AppColors.playfulTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
