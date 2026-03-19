import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../theme/design_tokens.dart';
import '../../utils/amenity_utils.dart';
import '../../utils/formatters.dart';
import '../../utils/launchers.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/info_pill.dart';
import '../../widgets/section_header.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoHero(context),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick info pills
                  _buildInfoPills(),
                  const SizedBox(height: AppSpacing.xl),

                  // Amenities
                  if (place.amenities.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: const SectionHeader(title: 'AMENITIES'),
                    ),
                    _buildAmenityChips(),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // About
                  if (place.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: const SectionHeader(title: 'ABOUT'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        place.description,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Details section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: SectionHeader(title: l10n.details),
                  ),
                  _buildDetailsSection(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: GradientButton(
              label: l10n.getDirections,
              icon: Icons.near_me,
              onTap: () => launchDirections(place.lat, place.lon),
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo Hero ────────────────────────────────────────────────────

  Widget _buildPhotoHero(BuildContext context) {
    final hasPhotos = place.photos.isNotEmpty;
    final bgColor = categoryColor(place.category);
    final iconData = categoryIcon(place.category);

    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo carousel or category gradient placeholder
          if (hasPhotos)
            PageView.builder(
              controller: _pageController,
              itemCount: place.photos.length,
              onPageChanged: (index) {
                setState(() => _currentPhotoPage = index);
              },
              itemBuilder: (context, index) {
                return Semantics(
                  label: '${place.name} photo',
                  child: CachedNetworkImage(
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
                  ),
                );
              },
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgColor, bgColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(iconData, size: 48, color: Colors.white),
              ),
            ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Place name + category on gradient
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  place.category.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Page indicator dots
          if (hasPhotos && place.photos.length > 1)
            Positioned(
              bottom: AppSpacing.md,
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

          // Back button — white circle, top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Info Pills ──────────────────────────────────────────────

  Widget _buildInfoPills() {
    final pills = <Widget>[];

    // TODO: open/closed status requires runtime check against openingHours
    // For now we show a generic "Open" pill as placeholder
    pills.add(
      const InfoPill(
        label: 'Open',
        icon: Icons.check_circle_outline,
        backgroundColor: Color(0xFFE0FFF9),
        textColor: AppColors.statusOpen,
      ),
    );

    // Distance pill
    if (place.distanceM != null) {
      pills.add(
        InfoPill(
          label: formatDistance(place.distanceM),
          icon: Icons.near_me,
          backgroundColor: AppColors.primaryWash,
          textColor: AppColors.primary,
        ),
      );
    }

    // Age range pill
    final ageText = formatAgeRange(place.ageMin, place.ageMax);
    if (ageText.isNotEmpty) {
      pills.add(
        InfoPill(
          label: ageText,
          icon: Icons.child_care,
          backgroundColor: const Color(0xFFFFF0F6),
          textColor: AppColors.rosePink,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: pills,
      ),
    );
  }

  // ── Amenity Chips ─────────────────────────────────────────────────

  Widget _buildAmenityChips() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: place.amenities.map((slug) {
          final icon = amenityIcons[slug];
          final label = amenityLabel(slug, l10n);
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Details Section ───────────────────────────────────────────────

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
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
              isLink: true,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLink ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
