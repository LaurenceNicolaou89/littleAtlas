import 'package:flutter/material.dart';

import 'package:little_atlas/models/weather.dart';

class WeatherBanner extends StatefulWidget {
  final Weather weather;

  const WeatherBanner({
    super.key,
    required this.weather,
  });

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> {
  bool _expanded = false;

  // ── Gradient backgrounds per mode ──────────────────────────────────
  static const _outdoorGradient = [Color(0xFFFFF8E1), Color(0xFFFFECB3)];
  static const _indoorGradient = [Color(0xFFE3F2FD), Color(0xFFBBDEFB)];
  static const _cautionGradient = [Color(0xFFFFF3E0), Color(0xFFFFE0B2)];

  // ── Text colors per mode ───────────────────────────────────────────
  static const _outdoorTextColor = Color(0xFF5D4037);
  static const _indoorTextColor = Color(0xFF1565C0);
  static const _cautionTextColor = Color(0xFFE65100);

  List<Color> get _gradient {
    switch (widget.weather.mode) {
      case WeatherMode.outdoor:
        return _outdoorGradient;
      case WeatherMode.indoor:
        return _indoorGradient;
      case WeatherMode.caution:
        return _cautionGradient;
    }
  }

  Color get _textColor {
    switch (widget.weather.mode) {
      case WeatherMode.outdoor:
        return _outdoorTextColor;
      case WeatherMode.indoor:
        return _indoorTextColor;
      case WeatherMode.caution:
        return _cautionTextColor;
    }
  }

  IconData get _weatherIcon {
    switch (widget.weather.mode) {
      case WeatherMode.outdoor:
        return Icons.wb_sunny;
      case WeatherMode.indoor:
        return Icons.home;
      case WeatherMode.caution:
        return Icons.warning_amber_rounded;
    }
  }

  String get _recommendationText {
    switch (widget.weather.mode) {
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

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: _expanded ? 120 : 48,
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
        child: _expanded
            ? _buildExpanded(textColor)
            : _buildCollapsed(textColor),
      ),
    );
  }

  Widget _buildCollapsed(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(_weatherIcon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '${widget.weather.temp.round()}\u00b0C',
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
          Icon(
            Icons.keyboard_arrow_down,
            color: textColor.withValues(alpha: 0.6),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_weatherIcon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.weather.temp.round()}\u00b0C \u2022 ${widget.weather.description}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_up,
                color: textColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _recommendationText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          // 3-hour forecast row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _forecastItem('+1h', widget.weather.temp + 1, textColor),
                _forecastItem('+2h', widget.weather.temp, textColor),
                _forecastItem('+3h', widget.weather.temp - 1, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastItem(String label, double temp, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Icon(_weatherIcon, color: textColor, size: 16),
        const SizedBox(height: 2),
        Text(
          '${temp.round()}\u00b0',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
