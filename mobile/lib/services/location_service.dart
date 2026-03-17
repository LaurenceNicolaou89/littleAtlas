import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../utils/constants.dart';

class LocationService {
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
    } catch (e) {
      debugPrint('LocationService: failed to check service status: $e');
      return false;
    }

    if (!serviceEnabled) {
      debugPrint('LocationService: location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('LocationService: permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('LocationService: permission denied forever');
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
    } catch (e) {
      debugPrint('LocationService: error getting location: $e');
      return _lastKnownLocation ?? cyprusCenter;
    }
  }
}
