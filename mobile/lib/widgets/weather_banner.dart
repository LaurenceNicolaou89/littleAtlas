import 'package:flutter/material.dart';

import 'package:little_atlas/app.dart';
import 'package:little_atlas/models/weather.dart';

/// A compact (48dp) weather recommendation banner.
///
/// Finding #7: Removed the fake 3-hour forecast and expand/collapse
/// behaviour since we don't have hourly data from the API.
class WeatherBanner extends StatelessWidget {
  final Weather weather;

  const WeatherBanner({
    super.key,
    required this.weather,
  });

  // ── Gradient backgrounds per mode ──────────────────────────────────
  static const _outdoorGradient = [Color(0xFFFFF8E1), Color(0xFFFFECB3)];
  static const _indoorGradient = [Color(0xFFE3F2FD), Color(0xFFBBDEFB)];
  static const _cautionGradient = [Color(0xFFFFF3E0), Color(0xFFFFE0B2)];

  // ── Text colors per mode ───────────────────────────────────────────
  static const _outdoorTextColor = Color(0xFF5D4037);
  static const _indoorTextColor = Color(0xFF1565C0);
  static const _cautionTextColor = Color(0xFFE65100);

  List<Color> get _gradient {
    switch (weather.mode) {
      case WeatherMode.outdoor:
        return _outdoorGradient;
      case WeatherMode.indoor:
        return _indoorGradient;
      case WeatherMode.caution:
        return _cautionGradient;
    }
  }

  Color get _textColor {
    switch (weather.mode) {
      case WeatherMode.outdoor:
        return _outdoorTextColor;
      case WeatherMode.indoor:
        return _indoorTextColor;
      case WeatherMode.caution:
        return _cautionTextColor;
    }
  }

  IconData get _weatherIcon {
    switch (weather.mode) {
      case WeatherMode.outdoor:
        return Icons.wb_sunny;
      case WeatherMode.indoor:
        return Icons.home;
      case WeatherMode.caution:
        return Icons.warning_amber_rounded;
    }
  }

  String get _recommendationText {
    switch (weather.mode) {
      case WeatherMode.outdoor:
        return 'Great day to be outside!';
      case WeatherMode.indoor:
        return 'Better to stay indoors today';
      case WeatherMode.caution:
        return 'Be cautious outdoors';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradient;
    final textColor = _textColor;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(_weatherIcon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              '${weather.temp.round()}\u00b0C',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _recommendationText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
