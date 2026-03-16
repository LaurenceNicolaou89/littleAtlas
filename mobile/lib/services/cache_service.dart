import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/place.dart';
import '../models/weather.dart';

class CacheService {
  static const String _placesBoxName = 'places_cache';
  static const String _weatherBoxName = 'weather_cache';
  static const String _placesKey = 'nearby_places';
  static const String _weatherKey = 'current_weather';

  Future<void> savePlaces(List<Place> places) async {
    final box = await Hive.openBox<String>(_placesBoxName);
    final jsonList = places.map((p) => _placeToJson(p)).toList();
    await box.put(_placesKey, jsonEncode(jsonList));
  }

  Future<List<Place>> getPlaces() async {
    final box = await Hive.openBox<String>(_placesBoxName);
    final raw = box.get(_placesKey);
    if (raw == null) return [];
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWeather(Weather weather) async {
    final box = await Hive.openBox<String>(_weatherBoxName);
    await box.put(_weatherKey, jsonEncode(_weatherToJson(weather)));
  }

  Future<Weather?> getWeather() async {
    final box = await Hive.openBox<String>(_weatherBoxName);
    final raw = box.get(_weatherKey);
    if (raw == null) return null;
    return Weather.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

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
