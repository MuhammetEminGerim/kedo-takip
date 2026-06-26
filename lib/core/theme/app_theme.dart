import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playful_theme.dart';
import 'modern_theme.dart';
import 'dark_theme.dart';

enum AppThemeType { playful, modern, dark }

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
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    state = AppThemeType.values[themeIndex];
  }

  Future<void> setTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    state = theme;
    await prefs.setInt(_themeKey, theme.index);
  }

  ThemeData get currentThemeData {
    switch (state) {
      case AppThemeType.modern:
        return ModernTheme.theme;
      case AppThemeType.dark:
        return DarkTheme.theme;
      case AppThemeType.playful:
      default:
        return PlayfulTheme.theme;
    }
  }
}
