import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/widgets/category_chips.dart';

/// Builds a [MarkerLayer] for a list of places.
///
/// [selectedPlaceId] highlights the selected marker.
/// [onMarkerTap] is called with the tapped [Place].
class PlaceMarkerLayer extends StatelessWidget {
  final List<Place> places;
  final int? selectedPlaceId;
  final ValueChanged<Place>? onMarkerTap;

  const PlaceMarkerLayer({
    super.key,
    required this.places,
    this.selectedPlaceId,
    this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: places.map((place) {
        final isSelected = place.id == selectedPlaceId;
        final size = isSelected ? 44.0 : 36.0;

        return Marker(
          point: LatLng(place.lat, place.lon),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => onMarkerTap?.call(place),
            child: _MarkerCircle(
              place: place,
              isSelected: isSelected,
              size: size,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MarkerCircle extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final double size;

  const _MarkerCircle({
    required this.place,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(place.category);
    final icon = categoryIcon(place.category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
