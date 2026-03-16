import 'package:flutter/material.dart';

import '../models/weather.dart';

class WeatherBanner extends StatelessWidget {
  final Weather weather;

  const WeatherBanner({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final Color bannerColor;
    final IconData modeIcon;

    switch (weather.mode) {
      case WeatherMode.outdoor:
        bannerColor = const Color(0xFF2E7D5F);
        modeIcon = Icons.wb_sunny;
      case WeatherMode.indoor:
        bannerColor = Colors.blueGrey;
        modeIcon = Icons.home;
      case WeatherMode.caution:
        bannerColor = Colors.orange;
        modeIcon = Icons.warning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bannerColor,
      child: Row(
        children: [
          Icon(modeIcon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            '${weather.temp.round()}\u00b0C \u2022 ${weather.description}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
