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
      colorScheme: const ColorScheme.light(
        primary: AppColors.modernPrimary,
        secondary: AppColors.modernSecondary,
        tertiary: Color(0xFF6366F1),
        surface: AppColors.modernSurface,
        primaryContainer: Color(0xFFFFEDD5), // Light orange
        secondaryContainer: Color(0xFFCCFBF1), // Light teal
      ),
      scaffoldBackgroundColor: AppColors.modernBackground,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.modernSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
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

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: const Color(0xFFF8FAFC),
      displayColor: const Color(0xFFF8FAFC),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.modernPrimary,
        secondary: AppColors.modernSecondary,
        tertiary: Color(0xFF818CF8), // Lighter indigo for dark mode
        surface: Color(0xFF1E293B), // Slate 800
        primaryContainer: Color(0xFF9A3412), // Dark orange
        secondaryContainer: Color(0xFF115E59), // Dark teal
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
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
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF8FAFC),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: AppColors.modernPrimary,
        unselectedItemColor: Color(0xFF94A3B8), // Slate 400
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
    );
  }
}
