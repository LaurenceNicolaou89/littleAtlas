import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/category.dart';
import '../models/place.dart';
import '../models/weather.dart';

class CacheService {
  static const String _placesBoxName = 'places_cache';
  static const String _weatherBoxName = 'weather_cache';
  static const String _categoriesBoxName = 'categories_cache';
  static const String _timestampBoxName = 'cache_timestamps';

  static const String _categoriesKey = 'all_categories';

  /// Weather cache expires after 30 minutes.
  static const Duration weatherTtl = Duration(minutes: 30);

  /// Places cache expires after 1 hour.
  static const Duration placesTtl = Duration(hours: 1);

  // ── Places ──────────────────────────────────────────────────────────

  Future<void> savePlaces(String key, List<Place> places) async {
    final box = await Hive.openBox<String>(_placesBoxName);
    final jsonList = places.map(_placeToJson).toList();
    await box.put(key, jsonEncode(jsonList));
    await _setTimestamp('$_placesBoxName:$key');
  }

  Future<List<Place>?> getPlaces(String key) async {
    if (_isExpired('$_placesBoxName:$key', placesTtl)) return null;

    final box = await Hive.openBox<String>(_placesBoxName);
    final raw = box.get(key);
    if (raw == null) return null;

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Weather ─────────────────────────────────────────────────────────

  String _weatherKey(double lat, double lon) =>
      'weather_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<void> saveWeather(double lat, double lon, Weather weather) async {
    final box = await Hive.openBox<String>(_weatherBoxName);
    final key = _weatherKey(lat, lon);
    await box.put(key, jsonEncode(_weatherToJson(weather)));
    await _setTimestamp('$_weatherBoxName:$key');
  }

  Future<Weather?> getWeather(double lat, double lon) async {
    final key = _weatherKey(lat, lon);
    if (_isExpired('$_weatherBoxName:$key', weatherTtl)) return null;

    final box = await Hive.openBox<String>(_weatherBoxName);
    final raw = box.get(key);
    if (raw == null) return null;

    return Weather.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── Categories ──────────────────────────────────────────────────────

  Future<void> saveCategories(List<Category> categories) async {
    final box = await Hive.openBox<String>(_categoriesBoxName);
    final jsonList = categories
        .map((c) => {
              'id': c.id,
              'slug': c.slug,
              'name': c.name,
              'icon': c.slug, // store slug as icon hint
            })
        .toList();
    await box.put(_categoriesKey, jsonEncode(jsonList));
  }

  Future<List<Category>?> getCategories() async {
    final box = await Hive.openBox<String>(_categoriesBoxName);
    final raw = box.get(_categoriesKey);
    if (raw == null) return null;

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── TTL helpers ─────────────────────────────────────────────────────

  final Map<String, DateTime> _timestamps = {};

  Future<void> _setTimestamp(String key) async {
    _timestamps[key] = DateTime.now();
    final box = await Hive.openBox<String>(_timestampBoxName);
    await box.put(key, DateTime.now().toIso8601String());
  }

  bool _isExpired(String key, Duration ttl) {
    // Check in-memory cache first.
    final inMemory = _timestamps[key];
    if (inMemory != null) {
      return DateTime.now().difference(inMemory) > ttl;
    }

    // Fall back to persisted timestamp (synchronous check against opened box).
    // If we cannot read the timestamp, treat it as expired so we refetch.
    try {
      final box = Hive.box<String>(_timestampBoxName);
      final raw = box.get(key);
      if (raw == null) return true;
      final ts = DateTime.parse(raw);
      _timestamps[key] = ts;
      return DateTime.now().difference(ts) > ttl;
    } catch (_) {
      return true;
    }
  }

  // ── JSON helpers ────────────────────────────────────────────────────

  Map<String, dynamic> _placeToJson(Place place) {
    return {
      'id': place.id,
      'name': place.name,
      'description': place.description,
      'lat': place.lat,
      'lon': place.lon,
      'category': place.category,
      'distance_m': place.distanceM,
      'is_indoor': place.isIndoor,
      'age_min': place.ageMin,
      'age_max': place.ageMax,
      'amenities': place.amenities,
      'photos': place.photos,
      'address': place.address,
      'phone': place.phone,
      'website': place.website,
    };
  }

  Map<String, dynamic> _weatherToJson(Weather weather) {
    return {
      'temp': weather.temp,
      'description': weather.description,
      'icon': weather.icon,
      'humidity': weather.humidity,
      'wind_speed': weather.windSpeed,
      'uv_index': weather.uvIndex,
      'mode': weather.mode.name,
    };
  }
}
