import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/category.dart';
import '../models/event.dart';
import '../models/place.dart';
import '../models/weather.dart';

class CacheService {
  static const String _placesBoxName = 'places_cache';
  static const String _weatherBoxName = 'weather_cache';
  static const String _categoriesBoxName = 'categories_cache';
  static const String _eventsBoxName = 'events_cache';
  static const String _timestampBoxName = 'cache_timestamps';

  static const String _categoriesKey = 'all_categories';

  /// Weather cache expires after 30 minutes.
  static const Duration weatherTtl = Duration(minutes: 30);

  /// Places cache expires after 1 hour.
  static const Duration placesTtl = Duration(hours: 1);

  /// Events cache expires after 30 minutes.
  static const Duration eventsTtl = Duration(minutes: 30);

  // Finding #10: open boxes once in init() and store references.
  late final Box<String> _placesBox;
  late final Box<String> _weatherBox;
  late final Box<String> _categoriesBox;
  late final Box<String> _eventsBox;
  late final Box<String> _timestampBox;

  bool _initialized = false;

  /// Opens all Hive boxes once. Must be called before using any other method.
  Future<void> init() async {
    if (_initialized) return;
    _placesBox = await Hive.openBox<String>(_placesBoxName);
    _weatherBox = await Hive.openBox<String>(_weatherBoxName);
    _categoriesBox = await Hive.openBox<String>(_categoriesBoxName);
    _eventsBox = await Hive.openBox<String>(_eventsBoxName);
    _timestampBox = await Hive.openBox<String>(_timestampBoxName);
    _initialized = true;
  }

  /// Ensures boxes are initialized (lazy).
  Future<void> _ensureInitialized() async {
    if (!_initialized) await init();
  }

  // ── Places ──────────────────────────────────────────────────────────

  Future<void> savePlaces(String key, List<Place> places) async {
    await _ensureInitialized();
    final jsonList = places.map(_placeToJson).toList();
    await _placesBox.put(key, jsonEncode(jsonList));
    _setTimestamp('$_placesBoxName:$key');
  }

  Future<List<Place>?> getPlaces(String key) async {
    await _ensureInitialized();
    if (_isExpired('$_placesBoxName:$key', placesTtl)) return null;

    final raw = _placesBox.get(key);
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
    await _ensureInitialized();
    final key = _weatherKey(lat, lon);
    await _weatherBox.put(key, jsonEncode(_weatherToJson(weather)));
    _setTimestamp('$_weatherBoxName:$key');
  }

  Future<Weather?> getWeather(double lat, double lon) async {
    await _ensureInitialized();
    final key = _weatherKey(lat, lon);
    if (_isExpired('$_weatherBoxName:$key', weatherTtl)) return null;

    final raw = _weatherBox.get(key);
    if (raw == null) return null;

    return Weather.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── Events (Finding #11) ──────────────────────────────────────────

  Future<void> saveEvents(String key, List<Event> events) async {
    await _ensureInitialized();
    final jsonList = events.map(_eventToJson).toList();
    await _eventsBox.put(key, jsonEncode(jsonList));
    _setTimestamp('$_eventsBoxName:$key');
  }

  Future<List<Event>?> getEvents(String key) async {
    await _ensureInitialized();
    if (_isExpired('$_eventsBoxName:$key', eventsTtl)) return null;

    final raw = _eventsBox.get(key);
    if (raw == null) return null;

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Categories ──────────────────────────────────────────────────────

  Future<void> saveCategories(List<Category> categories) async {
    await _ensureInitialized();
    final jsonList = categories
        .map((c) => {
              'id': c.id,
              'slug': c.slug,
              'name': c.name,
              'icon': c.slug, // store slug as icon hint
            })
        .toList();
    await _categoriesBox.put(_categoriesKey, jsonEncode(jsonList));
  }

  Future<List<Category>?> getCategories() async {
    await _ensureInitialized();
    final raw = _categoriesBox.get(_categoriesKey);
    if (raw == null) return null;

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── TTL helpers ─────────────────────────────────────────────────────

  final Map<String, DateTime> _timestamps = {};

  // Finding #10: fixed dual DateTime.now() bug — use a single timestamp.
  void _setTimestamp(String key) {
    final now = DateTime.now();
    _timestamps[key] = now;
    _timestampBox.put(key, now.toIso8601String());
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
      final raw = _timestampBox.get(key);
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
      'opening_hours': place.openingHours,
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
      'weather_mode': weather.mode.name,
    };
  }

  Map<String, dynamic> _eventToJson(Event event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      if (event.lat != null) 'lat': event.lat,
      if (event.lon != null) 'lon': event.lon,
      'venue_name': event.venueName,
      'address': event.address,
      'start_date': event.startDate.toIso8601String(),
      'end_date': event.endDate?.toIso8601String(),
      'is_indoor': event.isIndoor,
      'age_min': event.ageMin,
      'age_max': event.ageMax,
      'source_url': event.sourceUrl,
      'distance_m': event.distanceM,
    };
  }
}
