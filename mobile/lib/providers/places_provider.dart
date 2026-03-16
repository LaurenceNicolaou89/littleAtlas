import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class PlacesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _categoryFilter;
  bool? _indoorFilter;
  int? _ageFilter;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get categoryFilter => _categoryFilter;
  bool? get indoorFilter => _indoorFilter;
  int? get ageFilter => _ageFilter;

  List<Place> get filteredPlaces {
    var result = List<Place>.from(_places);
    if (_categoryFilter != null) {
      result = result.where((p) => p.category == _categoryFilter).toList();
    }
    if (_indoorFilter != null) {
      result = result.where((p) => p.isIndoor == _indoorFilter).toList();
    }
    if (_ageFilter != null) {
      result = result.where((p) {
        final min = p.ageMin ?? 0;
        final max = p.ageMax ?? 99;
        return _ageFilter! >= min && _ageFilter! <= max;
      }).toList();
    }
    return result;
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setIndoorFilter(bool? indoor) {
    _indoorFilter = indoor;
    notifyListeners();
  }

  void setAgeFilter(int? age) {
    _ageFilter = age;
    notifyListeners();
  }

  void clearFilters() {
    _categoryFilter = null;
    _indoorFilter = null;
    _ageFilter = null;
    notifyListeners();
  }

  Future<void> fetchNearby(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.placesNearby,
        queryParameters: {'lat': lat, 'lon': lon},
      );

      final data = response.data;
      if (data != null && data['results'] is List) {
        _places = (data['results'] as List<dynamic>)
            .map((e) => Place.fromJson(e as Map<String, dynamic>))
            .toList();
        await _cacheService.savePlaces(_places);
      }
    } catch (e) {
      _error = e.toString();
      // Fall back to cache
      _places = await _cacheService.getPlaces();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
