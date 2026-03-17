import 'package:flutter/foundation.dart';

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
  String? _selectedCategory;
  String? _selectedAgeGroup;
  bool? _isIndoor;
  String? _searchQuery;

  // Last fetch coordinates for re-fetching on filter change.
  double? _lastLat;
  double? _lastLon;

  // ── Getters ─────────────────────────────────────────────────────────

  List<Place> get places => _places;
  List<Place> get filteredPlaces => _places; // already filtered by API
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedAgeGroup => _selectedAgeGroup;
  bool? get isIndoor => _isIndoor;
  String? get searchQuery => _searchQuery;

  // ── Fetch ───────────────────────────────────────────────────────────

  Future<void> fetchNearby(double lat, double lon) async {
    _lastLat = lat;
    _lastLon = lon;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cacheKey = _buildCacheKey(lat, lon);

    try {
      _places = await _apiService.getPlaces(
        lat,
        lon,
        category: _selectedCategory,
        ageGroup: _selectedAgeGroup,
        indoor: _isIndoor,
        q: _searchQuery,
      );
      await _cacheService.savePlaces(cacheKey, _places);
    } catch (e) {
      _error = e.toString();
      // Fall back to cache
      _places = await _cacheService.getPlaces(cacheKey) ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter setters (each triggers refetch) ──────────────────────────

  void setCategory(String? category) {
    _selectedCategory = category;
    _refetch();
  }

  void setAgeGroup(String? ageGroup) {
    _selectedAgeGroup = ageGroup;
    _refetch();
  }

  void setIndoor(bool? indoor) {
    _isIndoor = indoor;
    _refetch();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _refetch();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedAgeGroup = null;
    _isIndoor = null;
    _searchQuery = null;
    _refetch();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  void _refetch() {
    if (_lastLat != null && _lastLon != null) {
      fetchNearby(_lastLat!, _lastLon!);
    } else {
      notifyListeners();
    }
  }

  String _buildCacheKey(double lat, double lon) {
    final parts = <String>[
      'places',
      '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}',
    ];
    if (_selectedCategory != null) parts.add('cat:$_selectedCategory');
    if (_selectedAgeGroup != null) parts.add('age:$_selectedAgeGroup');
    if (_isIndoor != null) parts.add('in:$_isIndoor');
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      parts.add('q:$_searchQuery');
    }
    return parts.join('_');
  }
}
