import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _settingsBoxName = 'settings';
  static const String _localeKey = 'locale';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('el'),
    Locale('ru'),
  ];

  late Locale _locale;

  SettingsProvider() : _locale = _defaultLocale() {
    _loadPersistedLocale();
  }

  Locale get locale => _locale;

  /// Changes the app language, persists the choice, and updates the API client.
  Future<void> changeLanguage(String langCode) async {
    _locale = Locale(langCode);
    ApiService().setLanguage(langCode);
    notifyListeners();

    try {
      final box = await Hive.openBox<String>(_settingsBoxName);
      await box.put(_localeKey, langCode);
    } catch (e) {
      debugPrint('SettingsProvider: failed to persist locale: $e');
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────

  Future<void> _loadPersistedLocale() async {
    try {
      final box = await Hive.openBox<String>(_settingsBoxName);
      final saved = box.get(_localeKey);
      if (saved != null && _isSupportedLang(saved)) {
        _locale = Locale(saved);
        ApiService().setLanguage(saved);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('SettingsProvider: failed to load persisted locale: $e');
    }
  }

  static bool _isSupportedLang(String code) {
    return supportedLocales.any((l) => l.languageCode == code);
  }

  static Locale _defaultLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (_isSupportedLang(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }
}
