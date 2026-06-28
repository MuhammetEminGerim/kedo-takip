import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playful_theme.dart';
import 'modern_theme.dart';
import 'dark_theme.dart';

enum AppThemeType { playful, modern }

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeType>(ThemeNotifier.new);
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key) ?? 0; // 0=system, 1=light, 2=dark
    state = ThemeMode.values[idx];
  }

  Future<void> setMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setInt(_key, mode.index);
  }
}

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
    // ensure backward compatibility if index was 2 (dark)
    if (themeIndex >= AppThemeType.values.length) {
      state = AppThemeType.playful;
    } else {
      state = AppThemeType.values[themeIndex];
    }
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
      case AppThemeType.playful:
      default:
        return PlayfulTheme.theme;
    }
  }

  ThemeData get currentDarkThemeData {
    switch (state) {
      case AppThemeType.modern:
        return ModernTheme.darkTheme;
      case AppThemeType.playful:
      default:
        return PlayfulTheme.darkTheme;
    }
  }
}
