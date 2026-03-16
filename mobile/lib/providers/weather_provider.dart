import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/weather.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherMode get weatherMode => _weather?.mode ?? WeatherMode.outdoor;

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.weather,
        queryParameters: {'lat': lat, 'lon': lon},
      );

      final data = response.data;
      if (data != null) {
        _weather = Weather.fromJson(data);
        await _cacheService.saveWeather(_weather!);
      }
    } catch (e) {
      _error = e.toString();
      _weather = await _cacheService.getWeather();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
