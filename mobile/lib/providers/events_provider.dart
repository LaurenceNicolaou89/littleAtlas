import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class EventsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  String _timeFilter = 'all'; // thisWeek | thisMonth | all

  // Last fetch coordinates for re-fetching on filter change.
  double? _lastLat;
  double? _lastLon;

  // ── Getters ─────────────────────────────────────────────────────────

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get timeFilter => _timeFilter;

  /// Events that are currently happening (startDate <= now <= endDate).
  List<Event> get happeningNow {
    final now = DateTime.now();
    return _events
        .where((e) =>
            e.startDate.isBefore(now) && e.endDate.isAfter(now))
        .toList();
  }

  // ── Fetch ───────────────────────────────────────────────────────────

  Future<void> fetchUpcoming(double lat, double lon) async {
    _lastLat = lat;
    _lastLon = lon;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cacheKey = _buildCacheKey(lat, lon);

    try {
      final dateRange = _dateRangeForFilter();
      _events = await _apiService.getEvents(
        lat,
        lon,
        dateFrom: dateRange.$1,
        dateTo: dateRange.$2,
      );

      // Finding #11: cache events.
      await _cacheService.saveEvents(cacheKey, _events);
    } catch (e) {
      _error = e.toString();
      // Fall back to cache.
      _events = await _cacheService.getEvents(cacheKey) ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter ──────────────────────────────────────────────────────────

  void setTimeFilter(String filter) {
    if (_timeFilter == filter) return;
    _timeFilter = filter;
    if (_lastLat != null && _lastLon != null) {
      fetchUpcoming(_lastLat!, _lastLon!);
    } else {
      notifyListeners();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Returns (dateFrom, dateTo) ISO strings based on the current time filter.
  (String?, String?) _dateRangeForFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_timeFilter) {
      case 'thisWeek':
        final endOfWeek =
            today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
        return (today.toIso8601String(), endOfWeek.toIso8601String());
      case 'thisMonth':
        final endOfMonth =
            DateTime(today.year, today.month + 1, 0, 23, 59, 59);
        return (today.toIso8601String(), endOfMonth.toIso8601String());
      default:
        return (null, null);
    }
  }

  String _buildCacheKey(double lat, double lon) {
    return 'events_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}_$_timeFilter';
  }
}
