import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../utils/formatters.dart';
import '../../utils/launchers.dart';
import '../../widgets/category_chips.dart';

/// Maps amenity slugs to their display icon.
const Map<String, IconData> _amenityIcons = {
  'changing_table': Icons.baby_changing_station,
  'high_chair': Icons.chair,
  'kids_menu': Icons.restaurant_menu,
  'stroller_access': Icons.accessible,
  'fenced_area': Icons.fence,
  'parking': Icons.local_parking,
  'wheelchair_access': Icons.wheelchair_pickup,
  'nursing_room': Icons.child_friendly,
  'shade': Icons.umbrella,
  'water_fountain': Icons.water_drop,
  'toilets': Icons.wc,
  'wifi': Icons.wifi,
};

/// Returns localized amenity label for the given slug.
String _amenityLabel(String slug, AppLocalizations l10n) {
  switch (slug) {
    case 'changing_table':
      return l10n.amenityChangingTable;
    case 'high_chair':
      return l10n.amenityHighChair;
    case 'kids_menu':
      return l10n.amenityKidsMenu;
    case 'stroller_access':
      return l10n.amenityStrollerAccess;
    case 'fenced_area':
      return l10n.amenityFencedArea;
    case 'parking':
      return l10n.amenityParking;
    case 'wheelchair_access':
      return l10n.amenityWheelchairAccess;
    case 'nursing_room':
      return l10n.amenityNursingRoom;
    case 'shade':
      return l10n.amenityShade;
    case 'water_fountain':
      return l10n.amenityWaterFountain;
    case 'toilets':
      return l10n.amenityToilets;
    case 'wifi':
      return l10n.amenityWifi;
    default:
      return slug.replaceAll('_', ' ');
  }
}

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _currentPhotoPage = 0;
  final PageController _pageController = PageController();

  Place get place => widget.place;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoCarousel(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    place.name,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  // Category + city subtitle
                  Text(
                    place.category,
                    style: textTheme.bodyMedium?.copyWith(
                      color: LittleAtlasApp.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Status row
                  _buildStatusRow(textTheme),
                  const SizedBox(height: 8),

                  // Age suitability
                  if (place.ageMin != null || place.ageMax != null) ...[
                    _buildAgeSuitability(textTheme),
                    const SizedBox(height: 12),
                  ],
                  const Divider(),
                  const SizedBox(height: 12),

                  // Amenities
                  if (place.amenities.isNotEmpty) ...[
                    Text(
                      l10n.amenities,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildAmenityChips(),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  // About
                  if (place.description.isNotEmpty) ...[
                    Text(
                      l10n.about,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place.description,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  // Details section
                  Text(
                    l10n.details,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // Address row
                  if (place.address != null)
                    _buildDetailRow(
                      icon: Icons.place,
                      text: place.address!,
                      onTap: () => launchDirections(place.lat, place.lon),
                    ),

                  // Phone row
                  if (place.phone != null)
                    _buildDetailRow(
                      icon: Icons.phone,
                      text: place.phone!,
                      onTap: () => launchPhone(place.phone!),
                    ),

                  // Website row
                  if (place.website != null)
                    _buildDetailRow(
                      icon: Icons.language,
                      text: place.website!,
                      onTap: () => launchWebsite(place.website!),
                    ),

                  const SizedBox(height: 24),

                  // Get Directions button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => launchDirections(place.lat, place.lon),
                      icon: const Icon(Icons.directions),
                      label: Text(l10n.getDirections),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LittleAtlasApp.atlasGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Photo carousel ─────────────────────────────────────────────────

  Widget _buildPhotoCarousel(BuildContext context) {
    final hasPhotos = place.photos.isNotEmpty;
    final bgColor = categoryColor(place.category);
    final iconData = categoryIcon(place.category);

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          if (hasPhotos)
            PageView.builder(
              controller: _pageController,
              itemCount: place.photos.length,
              onPageChanged: (index) {
                setState(() => _currentPhotoPage = index);
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: place.photos[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: bgColor.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: bgColor.withValues(alpha: 0.3),
                    child: Icon(iconData, size: 48, color: Colors.white),
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              color: bgColor,
              child: Center(
                child: Icon(
                  iconData,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

          // Page indicator dots
          if (hasPhotos && place.photos.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  place.photos.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPhotoPage == index ? 10 : 8,
                    height: _currentPhotoPage == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPhotoPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status row ──────────────────────────────────────────────────────

  Widget _buildStatusRow(TextTheme textTheme) {
    final distanceText = place.distanceM != null
        ? formatDistance(place.distanceM)
        : null;

    return Row(
      children: [
        // Distance badge
        if (distanceText != null) ...[
          Icon(
            Icons.near_me,
            size: 16,
            color: LittleAtlasApp.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            distanceText,
            style: textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  // ── Age suitability ─────────────────────────────────────────────────

  Widget _buildAgeSuitability(TextTheme textTheme) {
    final ageText = formatAgeRange(place.ageMin, place.ageMax);
    return Row(
      children: [
        Icon(
          Icons.child_care,
          size: 18,
          color: LittleAtlasApp.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          ageText,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  // ── Amenity chips ───────────────────────────────────────────────────

  Widget _buildAmenityChips() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: place.amenities.map((slug) {
        final icon = _amenityIcons[slug];
        final label = _amenityLabel(slug, l10n);
        return Chip(
          avatar: icon != null
              ? Icon(
                  icon,
                  size: 16,
                  color: LittleAtlasApp.atlasGreen,
                )
              : null,
          label: Text(label),
          backgroundColor: LittleAtlasApp.atlasGreenLight,
          labelStyle: const TextStyle(
            color: LittleAtlasApp.atlasGreen,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  // ── Detail row ──────────────────────────────────────────────────────

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: LittleAtlasApp.atlasGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: onTap != null
                      ? LittleAtlasApp.atlasGreen
                      : LittleAtlasApp.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: LittleAtlasApp.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
