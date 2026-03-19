import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../theme/design_tokens.dart';

/// Full-width weather hero card with Lottie animation, gradient background,
/// and activity suggestion text.
class WeatherHeroCard extends StatelessWidget {
  const WeatherHeroCard({
    super.key,
    required this.temperature,
    required this.description,
    required this.weatherMode,
    required this.suggestion,
  });

  final double temperature;
  final String description;
  final String weatherMode;
  final String suggestion;

  WeatherGradient _gradient() {
    switch (weatherMode) {
      case 'indoor':
        return WeatherGradients.indoor;
      case 'caution':
        return WeatherGradients.caution;
      case 'outdoor':
      default:
        return WeatherGradients.outdoor;
    }
  }

  String _lottieAsset() {
    final desc = description.toLowerCase();
    if (desc.contains('rain')) return 'assets/lottie/weather_rainy.json';
    if (desc.contains('cloud')) return 'assets/lottie/weather_cloudy.json';
    return 'assets/lottie/weather_sunny.json';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradient();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient.toLinearGradient(),
          borderRadius: AppRadii.weatherHeroBorder,
          boxShadow: AppShadows.weather(gradient.start),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Lottie icon in a translucent white circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(89), // ~35 %
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                _lottieAsset(),
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Temperature + suggestion column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${temperature.round()}° — $description',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: gradient.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 13,
                      color: gradient.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
