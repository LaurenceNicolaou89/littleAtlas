import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../theme/design_tokens.dart';
import '../utils/amenity_utils.dart';
import '../utils/formatters.dart';

/// A full-width place card with tall image hero and amenity chips.
///
/// Used in full-width list sections (e.g. Discover "Nearby" or search results).
class PlaceCardFullWidth extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  final VoidCallback? onShowOnMap;

  const PlaceCardFullWidth({
    super.key,
    required this.place,
    this.onTap,
    this.onShowOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catColor = AppColors.categoryColor(place.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardBorder,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area (160dp) ────────────────────────────────
            _buildImageArea(catColor, l10n),

            // ── Amenity chips row ─────────────────────────────────
            if (place.amenities.isNotEmpty) _buildAmenityRow(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea(Color catColor, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: place.amenities.isNotEmpty
          ? const BorderRadius.vertical(
              top: Radius.circular(AppRadii.cards),
            )
          : AppRadii.cardBorder,
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or gradient placeholder
            if (place.photos.isNotEmpty)
              Semantics(
                label: place.name,
                child: CachedNetworkImage(
                  imageUrl: place.photos.first,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _gradientPlaceholder(catColor),
                  errorWidget: (_, __, ___) => _gradientPlaceholder(catColor),
                ),
              )
            else
              _gradientPlaceholder(catColor),

            // Bottom gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(153), // ~0.6
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Open status badge — top-left
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: _openStatusBadge(l10n),
            ),

            // "Show on Map" badge — top-right
            if (onShowOnMap != null)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: GestureDetector(
                  onTap: onShowOnMap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235), // ~0.92
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.showOnMap,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

            // Name, category, distance, status — bottom overlay
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        place.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(217), // ~0.85
                        ),
                      ),
                      if (place.distanceM != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          child: Text(
                            '\u00B7',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(179),
                            ),
                          ),
                        ),
                        Text(
                          formatDistance(place.distanceM),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(204), // ~0.8
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: place.amenities.map((slug) {
          final icon = amenityIcons[slug];
          final label = amenityLabel(slug, l10n);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryWash, // Violet Wash #F0EDFF
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────

  Widget _gradientPlaceholder(Color catColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            catColor.withAlpha(179), // ~0.7
            catColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.place,
          color: Colors.white.withAlpha(128),
          size: 40,
        ),
      ),
    );
  }

  Widget _openStatusBadge(AppLocalizations l10n) {
    // Only show badge if opening_hours data exists
    if (place.openingHours == null) {
      return const SizedBox.shrink();
    }

    // TODO(open-status): compute real open/closed from openingHours
    const statusColor = AppColors.statusOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.openNow,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
