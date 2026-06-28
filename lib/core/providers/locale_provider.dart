import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString('app_locale') ?? 'tr';
    AppStrings.setLocale(savedLocale);
    return savedLocale;
  }

  void setLocale(String locale) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('app_locale', locale);
    AppStrings.setLocale(locale);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);
