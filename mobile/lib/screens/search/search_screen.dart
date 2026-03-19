import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:little_atlas/l10n/app_localizations.dart';
import 'package:little_atlas/providers/places_provider.dart';
import 'package:little_atlas/screens/home/home_screen.dart';
import 'package:little_atlas/screens/place_detail/place_detail_screen.dart';
import 'package:little_atlas/theme/design_tokens.dart';
import 'package:little_atlas/widgets/branded_skeleton.dart';
import 'package:little_atlas/widgets/filter_chip_removable.dart';
import 'package:little_atlas/widgets/filter_sheet.dart';
import 'package:little_atlas/widgets/gradient_button.dart';
import 'package:little_atlas/widgets/place_card_full_width.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // -- Debounced search -----------------------------------------------------

  void _onSearchChanged(String value) {
    // Rebuild to toggle the clear button visibility.
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final provider = context.read<PlacesProvider>();
      provider.setSearchQuery(value.isEmpty ? null : value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {});
    context.read<PlacesProvider>().setSearchQuery(null);
  }

  // -- Navigate to map tab --------------------------------------------------

  void _navigateToMapTab() {
    HomeScreen.switchTab(context, 3);
  }

  // -- Filter sheet ---------------------------------------------------------

  Future<void> _openFilterSheet() async {
    final provider = context.read<PlacesProvider>();
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialDistance: provider.distanceRadius,
        initialCategories: provider.selectedCategories,
        initialAgeGroup: provider.selectedAgeGroup,
        initialPlaceType: provider.placeType,
        initialAmenities: provider.selectedAmenities,
      ),
    );

    if (result == null) return;

    provider.applyFilters(result);
  }

  // -- Filter chip helpers --------------------------------------------------

  String _distanceLabel(int meters) {
    if (meters >= 1000) {
      return '< ${meters ~/ 1000} km';
    }
    return '< $meters m';
  }

  String _ageGroupLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'infant':
        return l10n.ageInfant;
      case 'toddler':
        return l10n.ageToddler;
      case 'preschool':
        return l10n.agePreschool;
      case 'school_age':
        return l10n.ageSchoolAge;
      default:
        return value;
    }
  }

  String _placeTypeLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'indoor':
        return l10n.indoor;
      case 'outdoor':
        return l10n.outdoor;
      default:
        return value;
    }
  }

  // -- Active filter count --------------------------------------------------

  int _activeFilterCount(PlacesProvider provider) {
    var count = 0;
    if (provider.distanceRadius != null) count++;
    if (provider.placeType != null) count++;
    if (provider.selectedAgeGroup != null) count++;
    count += provider.selectedCategories.length;
    count += provider.selectedAmenities.length;
    return count;
  }

  // -- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(l10n),
            _buildActiveFilterChips(provider, l10n),
            _buildResultsHeader(provider, l10n),
            Expanded(
              child: _buildResultsBody(provider, l10n),
            ),
          ],
        ),
      ),
    );
  }

  // -- Search bar (pill-shaped) ---------------------------------------------

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.searchBarBorder,
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000), // black 6%
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchPlaces,
            hintStyle: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textTertiary,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.primary,
                  ),
                  onPressed: _openFilterSheet,
                ),
              ],
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // -- Active filter chips row ----------------------------------------------

  Widget _buildActiveFilterChips(
    PlacesProvider provider,
    AppLocalizations l10n,
  ) {
    final chips = <Widget>[];

    // Distance chip
    if (provider.distanceRadius != null) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChipRemovable(
            label: _distanceLabel(provider.distanceRadius!),
            onRemove: () => provider.setDistanceRadius(null),
          ),
        ),
      );
    }

    // Place type chip
    if (provider.placeType != null) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChipRemovable(
            label: _placeTypeLabel(provider.placeType!, l10n),
            onRemove: () => provider.setPlaceType(null),
          ),
        ),
      );
    }

    // Age group chip
    if (provider.selectedAgeGroup != null) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChipRemovable(
            label: _ageGroupLabel(provider.selectedAgeGroup!, l10n),
            onRemove: () => provider.setAgeGroup(null),
          ),
        ),
      );
    }

    // Category chips
    for (final cat in provider.selectedCategories) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChipRemovable(
            label: cat,
            onRemove: () => provider.toggleCategory(cat),
          ),
        ),
      );
    }

    // Amenity chips
    for (final amenity in provider.selectedAmenities) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChipRemovable(
            label: amenity,
            onRemove: () => provider.toggleAmenity(amenity),
          ),
        ),
      );
    }

    // "Clear all" link when 2+ filters active
    if (_activeFilterCount(provider) >= 2) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: GestureDetector(
            onTap: () => provider.clearFilters(),
            child: Text(
              l10n.clearAll,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: chips,
      ),
    );
  }

  // -- Results header -------------------------------------------------------

  Widget _buildResultsHeader(PlacesProvider provider, AppLocalizations l10n) {
    if (provider.isLoading || provider.error != null) {
      return const SizedBox.shrink();
    }

    final count = provider.filteredPlaces.length;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        l10n.placesFound(count),
        style: GoogleFonts.nunito(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // -- Results body (list / loading / empty / error) ------------------------

  Widget _buildResultsBody(PlacesProvider provider, AppLocalizations l10n) {
    // Loading state -- skeleton shimmer
    if (provider.isLoading) {
      return _buildLoadingSkeleton();
    }

    // Error state
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      return _buildErrorFallback(provider, l10n);
    }

    // Empty state
    if (provider.filteredPlaces.isEmpty) {
      return _buildEmptyState(provider, l10n);
    }

    // Results list with pull-to-refresh
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        final p = context.read<PlacesProvider>();
        if (p.isLoading) return;
        if (p.places.isNotEmpty || p.searchQuery != null) {
          p.setSearchQuery(p.searchQuery);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: 80,
        ),
        itemCount: provider.filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = provider.filteredPlaces[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: PlaceCardFullWidth(
              place: place,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlaceDetailScreen(place: place),
                  ),
                );
              },
              onShowOnMap: _navigateToMapTab,
            ),
          );
        },
      ),
    );
  }

  // -- Loading skeleton -----------------------------------------------------

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: const [
        BrandedSkeleton(height: 160),
        SizedBox(height: 10),
        BrandedSkeleton(height: 160),
        SizedBox(height: 10),
        BrandedSkeleton(height: 160),
      ],
    );
  }

  // -- Empty state ----------------------------------------------------------

  Widget _buildEmptyState(PlacesProvider provider, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.primaryWash,
            borderRadius: AppRadii.cardBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.primary.withAlpha(128),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.noPlacesFound,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.tryAdjustingFilters,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (provider.hasActiveFilters) ...[
                const SizedBox(height: AppSpacing.xl),
                GradientButton(
                  label: l10n.clearAll,
                  icon: Icons.filter_list_off,
                  onTap: () => provider.clearFilters(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -- Error fallback (below snackbar) --------------------------------------

  Widget _buildErrorFallback(PlacesProvider provider, AppLocalizations l10n) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        provider.setSearchQuery(provider.searchQuery);
      },
      child: ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              l10n.errorOccurred,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
