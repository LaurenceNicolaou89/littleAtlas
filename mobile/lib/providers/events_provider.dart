import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUpcoming(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.eventsUpcoming,
        queryParameters: {'lat': lat, 'lon': lon},
      );

      final data = response.data;
      if (data != null && data['results'] is List) {
        _events = (data['results'] as List<dynamic>)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
