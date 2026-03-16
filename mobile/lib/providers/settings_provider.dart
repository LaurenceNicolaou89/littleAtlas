import 'dart:ui';

import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _locale;

  SettingsProvider()
      : _locale = _defaultLocale();

  Locale get locale => _locale;

  void changeLanguage(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }

  static Locale _defaultLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    const supported = ['en', 'el', 'ru'];
    if (supported.contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }
}
