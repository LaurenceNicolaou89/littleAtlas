import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../theme/design_tokens.dart';
import '../utils/amenity_utils.dart';
import '../utils/formatters.dart';

/// A compact, horizontally-scrollable place card (160dp wide).
///
/// Used in horizontal list sections on the Discover / Home screens.
class PlaceCardHorizontal extends StatefulWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCardHorizontal({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  State<PlaceCardHorizontal> createState() => _PlaceCardHorizontalState();
}

class _PlaceCardHorizontalState extends State<PlaceCardHorizontal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // ~20dp relative slide
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final l10n = AppLocalizations.of(context)!;
    final catColor = AppColors.categoryColor(place.category);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.cardBorder,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area (110dp) ──────────────────────────────
                _buildImageArea(place, catColor, l10n),

                // ── Info area below image ───────────────────────────
                _buildInfoArea(place, catColor, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(Place place, Color catColor, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.cards),
      ),
      child: SizedBox(
        height: 110,
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(140), // ~0.55
                    ],
                  ),
                ),
              ),
            ),

            // Open status badge — top-left
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: _openStatusBadge(place, l10n),
            ),

            // Name + distance — bottom-left
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (place.distanceM != null)
                    Text(
                      formatDistance(place.distanceM),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(204), // ~0.8
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

  Widget _buildInfoArea(Place place, Color catColor, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          // Category pill
          _pill(
            label: place.category,
            backgroundColor: const Color(0xFFFFF0F6),
            textColor: AppColors.rosePink,
          ),

          // Age pill
          if (place.ageMin != null || place.ageMax != null)
            _pill(
              label: formatAgeRange(place.ageMin, place.ageMax),
              backgroundColor: AppColors.primaryWash,
              textColor: AppColors.primary,
            ),

          // Up to 2 amenity pills
          ...place.amenities.take(2).map(
                (slug) => _pill(
                  label: amenityLabel(slug, l10n),
                  backgroundColor: const Color(0xFFF8F9FA),
                  textColor: AppColors.textSecondary,
                ),
              ),
        ],
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
          size: 32,
        ),
      ),
    );
  }

  Widget _openStatusBadge(Place place, AppLocalizations l10n) {
    // Simple heuristic: if opening_hours exists, show status.
    // Without real-time data we default to open.
    final isOpen = place.openingHours != null;
    if (!isOpen && place.openingHours == null) {
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

  Widget _pill({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.chips),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
