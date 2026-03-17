import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  // ── Getters ─────────────────────────────────────────────────────────

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns the current weather mode, defaulting to outdoor.
  WeatherMode get weatherMode => _weather?.mode ?? WeatherMode.outdoor;

  /// Human-readable recommendation banner text.
  String get weatherBannerText {
    switch (weatherMode) {
      case WeatherMode.outdoor:
        return 'Great day to be outside!';
      case WeatherMode.indoor:
        return 'Better to stay indoors today';
      case WeatherMode.caution:
        return 'Be cautious outdoors';
    }
  }

  /// Gradient colors for the weather recommendation banner.
  List<Color> get weatherBannerColor {
    switch (weatherMode) {
      case WeatherMode.outdoor:
        return const [Color(0xFF2E7D5F), Color(0xFF4CAF50)];
      case WeatherMode.indoor:
        return const [Color(0xFF1565C0), Color(0xFF42A5F5)];
      case WeatherMode.caution:
        return const [Color(0xFFE65100), Color(0xFFFFA726)];
    }
  }

  // ── Fetch ───────────────────────────────────────────────────────────

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _apiService.getWeather(lat, lon);
      await _cacheService.saveWeather(lat, lon, _weather!);
    } catch (e) {
      _error = e.toString();
      // Fall back to cache
      _weather = await _cacheService.getWeather(lat, lon);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
