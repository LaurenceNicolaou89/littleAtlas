import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../widgets/filter_sheet.dart';

class PlacesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedCategory;
  Set<String> _selectedCategories = {};
  String? _selectedAgeGroup;
  bool? _isIndoor;
  String? _placeType; // 'indoor', 'outdoor', or null (both)
  String? _searchQuery;
  int? _distanceRadius; // in meters
  Set<String> _selectedAmenities = {};

  // Last fetch coordinates for re-fetching on filter change.
  double? _lastLat;
  double? _lastLon;

  // ── Getters ─────────────────────────────────────────────────────────

  List<Place> get places => _places;
  List<Place> get filteredPlaces => _places; // already filtered by API
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  Set<String> get selectedCategories => _selectedCategories;
  String? get selectedAgeGroup => _selectedAgeGroup;
  bool? get isIndoor => _isIndoor;
  String? get placeType => _placeType;
  String? get searchQuery => _searchQuery;
  int? get distanceRadius => _distanceRadius;
  Set<String> get selectedAmenities => _selectedAmenities;

  bool get hasActiveFilters =>
      _selectedCategories.isNotEmpty ||
      _selectedAgeGroup != null ||
      _placeType != null ||
      _distanceRadius != null ||
      _selectedAmenities.isNotEmpty;

  // ── Fetch ───────────────────────────────────────────────────────────

  Future<void> fetchNearby(double lat, double lon) async {
    _lastLat = lat;
    _lastLon = lon;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cacheKey = _buildCacheKey(lat, lon);

    try {
      // Limitation: the backend 'category' param accepts a single slug only.
      // When multiple categories are selected, we send the first one to the API
      // and filter the rest client-side below.
      final categoryParam = _selectedCategories.isNotEmpty
          ? _selectedCategories.first
          : _selectedCategory;

      // Map placeType to the indoor bool the API expects.
      bool? indoorParam = _isIndoor;
      if (_placeType == 'indoor') {
        indoorParam = true;
      } else if (_placeType == 'outdoor') {
        indoorParam = false;
      }

      _places = await _apiService.getPlaces(
        lat,
        lon,
        radius: _distanceRadius,
        category: categoryParam,
        ageGroup: _selectedAgeGroup,
        indoor: indoorParam,
        q: _searchQuery,
        amenities: _selectedAmenities.isNotEmpty
            ? _selectedAmenities.join(',')
            : null,
      );

      // Client-side filtering for multi-category and amenities since
      // the API only supports a single category parameter.
      if (_selectedCategories.length > 1) {
        _places = _places
            .where((p) => _selectedCategories.contains(p.category))
            .toList();
      }
      if (_selectedAmenities.isNotEmpty) {
        _places = _places
            .where(
              (p) => _selectedAmenities.every(
                (a) => p.amenities.contains(a),
              ),
            )
            .toList();
      }

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

  void setCategories(Set<String> categories) {
    _selectedCategories = categories;
    _refetch();
  }

  void toggleCategory(String category) {
    final updated = Set<String>.from(_selectedCategories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    _selectedCategories = updated;
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

  void setPlaceType(String? type) {
    _placeType = type;
    _refetch();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _refetch();
  }

  void setDistanceRadius(int? radius) {
    _distanceRadius = radius;
    _refetch();
  }

  void setAmenities(Set<String> amenities) {
    _selectedAmenities = amenities;
    _refetch();
  }

  void toggleAmenity(String amenity) {
    final updated = Set<String>.from(_selectedAmenities);
    if (updated.contains(amenity)) {
      updated.remove(amenity);
    } else {
      updated.add(amenity);
    }
    _selectedAmenities = updated;
    _refetch();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedCategories = {};
    _selectedAgeGroup = null;
    _isIndoor = null;
    _placeType = null;
    _searchQuery = null;
    _distanceRadius = null;
    _selectedAmenities = {};
    _refetch();
  }

  /// Applies all filter values at once and triggers a single refetch
  /// Applies all filters in a single batch to avoid sequential API calls.
  void applyFilters(FilterResult result) {
    _distanceRadius = result.distance;
    _selectedCategories = result.categories;
    _selectedAgeGroup = result.ageGroup;
    _placeType = result.placeType;
    _selectedAmenities = result.amenities;
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
    if (_selectedCategories.isNotEmpty) {
      parts.add('cats:${_selectedCategories.join(',')}');
    }
    if (_selectedAgeGroup != null) parts.add('age:$_selectedAgeGroup');
    if (_isIndoor != null) parts.add('in:$_isIndoor');
    if (_placeType != null) parts.add('type:$_placeType');
    if (_distanceRadius != null) parts.add('r:$_distanceRadius');
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      parts.add('q:$_searchQuery');
    }
    return parts.join('_');
  }
}
