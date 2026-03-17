import 'package:flutter/foundation.dart';

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

  // Finding #15: Removed weatherBannerText and weatherBannerColor —
  // the WeatherBanner widget computes its own text and gradients.

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
