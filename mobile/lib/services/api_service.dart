import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/place.dart';
import '../models/weather.dart';

class ApiService {
  static ApiService? _instance;

  late final Dio _dio;
  String _lang = 'en';

  factory ApiService() => _instance ??= ApiService._internal();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['lang'] = _lang;
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            'ApiService error: ${error.requestOptions.method} '
            '${error.requestOptions.path} -> ${error.message}',
          );

          final statusCode = error.response?.statusCode;
          String message;

          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            message = 'Connection timed out. Please try again.';
          } else if (error.type == DioExceptionType.connectionError) {
            message =
                'Unable to connect to server. Check your internet connection.';
          } else if (statusCode != null) {
            switch (statusCode) {
              case 400:
                message = 'Bad request. Please check your input.';
              case 401:
                message = 'Unauthorized. Please log in again.';
              case 403:
                message = 'Access denied.';
              case 404:
                message = 'Resource not found.';
              case 500:
                message = 'Server error. Please try again later.';
              default:
                message = 'Request failed (status $statusCode).';
            }
          } else {
            message = 'An unexpected error occurred.';
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: message,
              message: message,
            ),
          );
        },
      ),
    );
  }

  void setLanguage(String langCode) {
    _lang = langCode;
  }

  // ── Places ──────────────────────────────────────────────────────────

  Future<List<Place>> getPlaces(
    double lat,
    double lon, {
    int? radius,
    String? category,
    String? ageGroup,
    bool? indoor,
    String? q,
  }) async {
    final params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    if (radius != null) params['radius'] = radius;
    if (category != null) params['category'] = category;
    if (ageGroup != null) params['age_group'] = ageGroup;
    if (indoor != null) params['indoor'] = indoor;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.placesNearby,
      queryParameters: params,
    );

    final data = response.data;
    if (data != null && data['results'] is List) {
      return (data['results'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Place> getPlace(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.placeDetail}/$id',
    );

    return Place.fromJson(response.data!);
  }

  // ── Events ──────────────────────────────────────────────────────────

  Future<List<Event>> getEvents(
    double lat,
    double lon, {
    String? dateFrom,
    String? dateTo,
    String? ageGroup,
  }) async {
    final params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (ageGroup != null) params['age_group'] = ageGroup;

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.eventsUpcoming,
      queryParameters: params,
    );

    final data = response.data;
    if (data != null && data['results'] is List) {
      return (data['results'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Weather ─────────────────────────────────────────────────────────

  Future<Weather> getWeather(double lat, double lon) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.weather,
      queryParameters: {'lat': lat, 'lon': lon},
    );

    return Weather.fromJson(response.data!);
  }

  // ── Categories ──────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.categories,
    );

    final data = response.data;
    if (data != null && data['results'] is List) {
      return (data['results'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
