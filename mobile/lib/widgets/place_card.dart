import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/widgets/category_chips.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(place.category);
    final icon = categoryIcon(place.category);

    return InkWell(
      onTap: onTap ?? () => debugPrint('Navigate to place detail: ${place.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ─────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: place.photos.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: place.photos.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _thumbnailPlaceholder(
                          color,
                          icon,
                        ),
                        errorWidget: (_, __, ___) => _thumbnailPlaceholder(
                          color,
                          icon,
                        ),
                      )
                    : _thumbnailPlaceholder(color, icon),
              ),
            ),
            const SizedBox(width: 12),

            // ── Content ───────────────────────────────────────────
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name (H3 style)
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Category + open/closed status
                    Row(
                      children: [
                        Text(
                          place.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Open',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Amenity chips (top 2) + age range badge
                    Expanded(
                      child: Row(
                        children: [
                          ...place.amenities.take(2).map(
                            (amenity) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  amenity,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (place.ageMin != null || place.ageMax != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _ageRangeText(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D5F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Distance (right-aligned, caption style) ──────────
            if (place.distanceM != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _formatDistance(place.distanceM!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder(Color color, IconData icon) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _ageRangeText() {
    if (place.ageMin != null && place.ageMax != null) {
      return '${place.ageMin}-${place.ageMax} yrs';
    } else if (place.ageMin != null) {
      return '${place.ageMin}+ yrs';
    } else if (place.ageMax != null) {
      return '0-${place.ageMax} yrs';
    }
    return '';
  }
}
