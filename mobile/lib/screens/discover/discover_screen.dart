import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/weather.dart';
import '../../providers/events_provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/weather_provider.dart';
import '../../screens/event_detail/event_detail_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/place_detail/place_detail_screen.dart';
import '../../services/location_service.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/branded_skeleton.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/event_card_horizontal.dart';
import '../../widgets/place_card_full_width.dart';
import '../../widgets/place_card_horizontal.dart';
import '../../widgets/section_header.dart';
import '../../utils/transitions.dart';
import '../../widgets/weather_hero_card.dart';

/// The Discovery home screen — the default tab that shows weather, events,
/// nearby places, and curated sections.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _visible = false;
  bool _locationDenied = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Fade-in animation on first load.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  Future<void> _loadData() async {
    try {
      final location = await LocationService().getCurrentLocation();

      if (!mounted) return;

      final placesProvider = context.read<PlacesProvider>();
      final weatherProvider = context.read<WeatherProvider>();
      final eventsProvider = context.read<EventsProvider>();

      // Fire all fetches concurrently.
      await Future.wait([
        placesProvider.fetchNearby(location.latitude, location.longitude),
        weatherProvider.fetchWeather(location.latitude, location.longitude),
        eventsProvider.fetchUpcoming(location.latitude, location.longitude),
      ]);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('permission') || errorMsg.contains('denied')) {
        setState(() => _locationDenied = true);
      } else {
        setState(() => _isOffline = true);
      }
    }
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  String _weatherSuggestion(AppLocalizations l10n, WeatherMode mode) {
    switch (mode) {
      case WeatherMode.outdoor:
        return l10n.weatherSuggestionOutdoor;
      case WeatherMode.indoor:
        return l10n.weatherSuggestionIndoor;
      case WeatherMode.caution:
        return l10n.weatherSuggestionCaution;
    }
  }

  String _weatherModeString(WeatherMode mode) {
    switch (mode) {
      case WeatherMode.outdoor:
        return 'outdoor';
      case WeatherMode.indoor:
        return 'indoor';
      case WeatherMode.caution:
        return 'caution';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Location denied — show full-screen friendly message.
    if (_locationDenied) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Location access is needed to show nearby places',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please enable location in your device settings.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton.icon(
                    onPressed: () {
                      Geolocator.openAppSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.settings),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.buttonBorder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Offline banner ──────────────────────────────────────
              if (_isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  color: AppColors.primaryWash,
                  child: Text(
                    "You're offline — showing cached data",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              // ── 1. Greeting ────────────────────────────────────────
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(l10n),
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Cyprus',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Text(
                            '\u2600\uFE0F',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 2. Weather Hero Card ───────────────────────────────
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, _) {
                  if (weatherProvider.isLoading &&
                      weatherProvider.weather == null) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: BrandedSkeleton(height: 80),
                    );
                  }
                  final weather = weatherProvider.weather;
                  if (weather == null) return const SizedBox.shrink();
                  return WeatherHeroCard(
                    temperature: weather.temp,
                    description: weather.description,
                    weatherMode: _weatherModeString(weather.mode),
                    suggestion:
                        _weatherSuggestion(l10n, weather.mode),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 3. Category chips ──────────────────────────────────
              const CategoryChips(),
              const SizedBox(height: AppSpacing.xl),

              // ── 4. Happening Now ───────────────────────────────────
              Consumer<EventsProvider>(
                builder: (context, eventsProvider, _) {
                  if (eventsProvider.isLoading &&
                      eventsProvider.events.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: l10n.happeningNow),
                          const BrandedSkeleton(height: 210),
                        ],
                      ),
                    );
                  }

                  final happeningNow = eventsProvider.happeningNow;
                  if (happeningNow.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: SectionHeader(
                          title: l10n.happeningNow,
                          onSeeAll: () {
                            HomeScreen.switchTab(context, 2);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                            left: AppSpacing.lg,
                          ),
                          itemCount: happeningNow.length,
                          itemBuilder: (context, index) {
                            final event = happeningNow[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: EventCardHorizontal(
                                event: event,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    slideUpRoute(
                                      EventDetailScreen(event: event),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  );
                },
              ),

              // ── 5. Nearby Places ───────────────────────────────────
              Consumer<PlacesProvider>(
                builder: (context, placesProvider, _) {
                  if (placesProvider.isLoading &&
                      placesProvider.places.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: l10n.nearbyPlaces),
                          const BrandedSkeleton(height: 200),
                        ],
                      ),
                    );
                  }

                  if (placesProvider.places.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: SectionHeader(
                          title: l10n.nearbyPlaces,
                          onSeeAll: () {
                            HomeScreen.switchTab(context, 1);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                            left: AppSpacing.lg,
                          ),
                          itemCount: placesProvider.places.length,
                          itemBuilder: (context, index) {
                            final place = placesProvider.places[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: PlaceCardHorizontal(
                                place: place,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlaceDetailScreen(place: place),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  );
                },
              ),

              // ── 6. Popular This Week ───────────────────────────────
              Consumer<PlacesProvider>(
                builder: (context, placesProvider, _) {
                  if (placesProvider.places.length < 3) {
                    return const SizedBox.shrink();
                  }

                  // Show first 5 places as "popular".
                  final popular = placesProvider.places.take(5).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.popularThisWeek),
                        ...List.generate(popular.length, (index) {
                          final place = popular[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10),
                            child: PlaceCardFullWidth(
                              place: place,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  slideUpRoute(
                                    PlaceDetailScreen(place: place),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

              // Bottom padding for floating nav bar
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
