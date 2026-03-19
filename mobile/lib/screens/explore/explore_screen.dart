import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:little_atlas/l10n/app_localizations.dart';
import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/providers/places_provider.dart';
import 'package:little_atlas/providers/weather_provider.dart';
import 'package:little_atlas/screens/place_detail/place_detail_screen.dart';
import 'package:little_atlas/services/location_service.dart';
import 'package:little_atlas/theme/design_tokens.dart';
import 'package:little_atlas/widgets/category_chips.dart';
import 'package:little_atlas/widgets/map/place_marker.dart';
import 'package:little_atlas/widgets/map/place_preview.dart';
import 'package:little_atlas/widgets/place_card_horizontal.dart';
import 'package:little_atlas/widgets/weather_hero_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LatLng _currentCenter = LocationService.cyprusCenter;
  Place? _selectedPlace;

  Timer? _mapMoveDebounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapMoveDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _currentCenter = location;
    });

    _mapController.move(location, 13);

    // Initial data fetch
    final placesProvider = context.read<PlacesProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    placesProvider.fetchNearby(location.latitude, location.longitude);
    weatherProvider.fetchWeather(location.latitude, location.longitude);
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final center = camera.center;
    _currentCenter = center;

    _mapMoveDebounce?.cancel();
    _mapMoveDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<PlacesProvider>().fetchNearby(
            center.latitude,
            center.longitude,
          );
    });
  }

  void _recenterOnLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _currentCenter = location;
    });

    _mapController.move(location, 13);

    context.read<PlacesProvider>().fetchNearby(
          location.latitude,
          location.longitude,
        );
    context.read<WeatherProvider>().fetchWeather(
          location.latitude,
          location.longitude,
        );
  }

  void _onMarkerTap(Place place) {
    setState(() {
      _selectedPlace = _selectedPlace?.id == place.id ? null : place;
    });
  }

  void _navigateToPlaceDetail(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceDetailScreen(place: place),
      ),
    );
  }

  String _weatherModeString(dynamic mode) {
    return mode.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.filteredPlaces;
    final weather = weatherProvider.weather;
    final l10n = AppLocalizations.of(context)!;

    // Determine suggestion text for WeatherHeroCard
    String weatherSuggestion = '';
    if (weather != null) {
      switch (_weatherModeString(weather.mode)) {
        case 'outdoor':
          weatherSuggestion = l10n.weatherOutdoor;
        case 'indoor':
          weatherSuggestion = l10n.weatherIndoor;
        case 'caution':
          weatherSuggestion = l10n.weatherCaution;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Map (full screen, bottom layer) ─────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13,
              onPositionChanged: _onMapMoved,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.littleatlas.app',
              ),
              PlaceMarkerLayer(
                places: places,
                selectedPlaceId: _selectedPlace?.id,
                onMarkerTap: _onMarkerTap,
              ),
            ],
          ),

          // ── Weather hero card (top) ─────────────────────────────
          if (weather != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: WeatherHeroCard(
                temperature: weather.temp,
                description: weather.description,
                weatherMode: _weatherModeString(weather.mode),
                suggestion: weatherSuggestion,
              ),
            ),

          // ── Category chips (below weather card) ─────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top +
                (weather != null ? 96 : 0),
            left: 0,
            right: 0,
            child: const CategoryChips(),
          ),

          // ── Place preview card (above selected marker) ──────────
          if (_selectedPlace != null)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.12 + 16,
              left: 0,
              right: 0,
              child: Center(
                child: PlacePreview(
                  place: _selectedPlace!,
                  onTap: () => _navigateToPlaceDetail(_selectedPlace!),
                  onClose: () => setState(() => _selectedPlace = null),
                ),
              ),
            ),

          // ── Draggable bottom sheet ──────────────────────────────
          _buildBottomSheet(places),

          // ── My location FAB ─────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1 + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: AppShadows.card,
              ),
              child: IconButton(
                onPressed: _recenterOnLocation,
                icon: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(List<Place> places) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.1, 0.4, 0.8],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.sheetBorder,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.pullUpForNearby,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Place list ────────────────────────────────────
              Expanded(
                child: places.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noPlacesNearby,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          bottom: 80,
                        ),
                        itemCount: places.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return PlaceCardHorizontal(
                            place: place,
                            onTap: () => _navigateToPlaceDetail(place),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
