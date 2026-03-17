import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:little_atlas/app.dart';
import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/utils/formatters.dart';
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
      onTap: onTap,
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
                        color: LittleAtlasApp.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Category row
                    // Finding #13: only show open/closed if we have data.
                    // The Place model has no opening_hours field, so we
                    // hide the indicator entirely.
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
                                  color: LittleAtlasApp.background,
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
                                    color: LittleAtlasApp.textSecondary,
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
                                color: LittleAtlasApp.atlasGreenLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _ageRangeText(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: LittleAtlasApp.atlasGreen,
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
                  formatDistance(place.distanceM),
                  style: const TextStyle(
                    fontSize: 12,
                    color: LittleAtlasApp.textTertiary,
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
