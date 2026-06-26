import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    return AppStrings.locale;
  }

  void setLocale(String locale) {
    AppStrings.setLocale(locale);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);
