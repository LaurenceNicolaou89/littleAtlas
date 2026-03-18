import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../utils/constants.dart';

/// Finding #16: LocationService is now a singleton so the same instance
/// is shared across explore_screen, events_screen, etc.
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  static final LatLng cyprusCenter = LatLng(
    AppConstants.cyprusCenterLat,
    AppConstants.cyprusCenterLon,
  );

  LatLng? _lastKnownLocation;

  /// The most recently retrieved location, or null if never fetched.
  LatLng? get lastKnownLocation => _lastKnownLocation;

  /// Checks whether location services are enabled and the app has permission.
  /// Requests permission if it has not been granted yet.
  /// Returns `true` when permission is granted.
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Returns the device's current position with high accuracy.
  /// Falls back to [lastKnownLocation] or the Cyprus centre default when
  /// location is unavailable.
  Future<LatLng> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return _lastKnownLocation ?? cyprusCenter;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _lastKnownLocation = LatLng(position.latitude, position.longitude);
      return _lastKnownLocation!;
    } catch (_) {
      return _lastKnownLocation ?? cyprusCenter;
    }
  }
}
