import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playful_theme.dart';
import 'modern_theme.dart';

enum AppThemeType { playful, modern }

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeType>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppThemeType> {
  static const _themeKey = 'selected_theme';

  @override
  AppThemeType build() {
    _loadTheme();
    return AppThemeType.playful;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isModern = prefs.getBool(_themeKey) ?? false;
    if (isModern) {
      state = AppThemeType.modern;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == AppThemeType.playful) {
      state = AppThemeType.modern;
      await prefs.setBool(_themeKey, true);
    } else {
      state = AppThemeType.playful;
      await prefs.setBool(_themeKey, false);
    }
  }

  ThemeData get currentThemeData {
    return state == AppThemeType.playful
        ? PlayfulTheme.theme
        : ModernTheme.theme;
  }
}
