import 'package:flutter/material.dart';

import 'package:little_atlas/app.dart';
import 'package:little_atlas/models/place.dart';
import 'package:little_atlas/utils/formatters.dart';
import 'package:little_atlas/widgets/category_chips.dart';

/// A small floating card that appears above the selected map marker.
class PlacePreview extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const PlacePreview({
    super.key,
    required this.place,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(place.category);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIcon(place.category),
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: LittleAtlasApp.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onClose != null)
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: LittleAtlasApp.textTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
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
                  if (place.distanceM != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.near_me,
                      size: 12,
                      color: LittleAtlasApp.textTertiary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatDistance(place.distanceM),
                      style: const TextStyle(
                        fontSize: 12,
                        color: LittleAtlasApp.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
