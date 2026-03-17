import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/providers/places_provider.dart';
import 'package:little_atlas/providers/weather_provider.dart';
import 'package:little_atlas/services/location_service.dart';
import 'package:little_atlas/widgets/category_chips.dart';
import 'package:little_atlas/widgets/map/place_marker.dart';
import 'package:little_atlas/widgets/map/place_preview.dart';
import 'package:little_atlas/widgets/place_card.dart';
import 'package:little_atlas/widgets/weather_banner.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LatLng _currentCenter = LocationService.cyprusCenter;
  bool _initialLocationLoaded = false;
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _currentCenter = location;
      _initialLocationLoaded = true;
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

    // Refetch places for the new center
    context.read<PlacesProvider>().fetchNearby(
          center.latitude,
          center.longitude,
        );
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

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.filteredPlaces;
    final weather = weatherProvider.weather;

    return Scaffold(
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

          // ── Weather banner (top) ────────────────────────────────
          if (weather != null)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: WeatherBanner(weather: weather),
            ),

          // ── Category chips (below weather banner) ───────────────
          Positioned(
            top: MediaQuery.of(context).padding.top +
                (weather != null ? 48 : 0),
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
                  onTap: () {
                    debugPrint(
                      'Navigate to place detail: ${_selectedPlace!.id}',
                    );
                  },
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
            child: FloatingActionButton(
              heroTag: 'myLocation',
              mini: true,
              elevation: 4,
              backgroundColor: Colors.white,
              onPressed: _recenterOnLocation,
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF2E7D5F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(List<Place> places) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.1, 0.4, 0.8],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
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
                          color: const Color(0xFFBDBDBD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pull up for nearby places',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
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
                    ? const Center(
                        child: Text(
                          'No places nearby',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: places.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFEEEEEE),
                        ),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return PlaceCard(
                            place: place,
                            onTap: () => debugPrint(
                              'Navigate to place detail: ${place.id}',
                            ),
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
