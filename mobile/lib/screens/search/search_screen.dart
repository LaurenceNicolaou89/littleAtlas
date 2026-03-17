import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:little_atlas/app.dart';
import 'package:little_atlas/l10n/app_localizations.dart';
import 'package:little_atlas/providers/places_provider.dart';
import 'package:little_atlas/screens/place_detail/place_detail_screen.dart';
import 'package:little_atlas/widgets/filter_sheet.dart';
import 'package:little_atlas/widgets/place_card.dart';
import 'package:little_atlas/widgets/skeleton_card.dart';

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

  // ── Debounced search ──────────────────────────────────────────────

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

  // ── Filter sheet ──────────────────────────────────────────────────

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

    // Finding #3: apply all filters at once — single API call.
    provider.applyFilters(result);
  }

  // ── Filter chip helpers ───────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(l10n),
            _buildFilterChips(provider, l10n),
            _buildResultsHeader(provider, l10n),
            Expanded(
              child: _buildResultsBody(provider, l10n),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black12,
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchPlaces,
            hintStyle: const TextStyle(
              color: LittleAtlasApp.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: LittleAtlasApp.textTertiary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: LittleAtlasApp.textSecondary,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            filled: true,
            fillColor: LittleAtlasApp.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: LittleAtlasApp.atlasGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter chips row ──────────────────────────────────────────────

  Widget _buildFilterChips(PlacesProvider provider, AppLocalizations l10n) {
    final chips = <Widget>[];

    // "+ Add filter" action chip — always first
    chips.add(
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          avatar: const Icon(
            Icons.tune,
            size: 18,
            color: LittleAtlasApp.atlasGreen,
          ),
          label: Text(l10n.addFilter),
          labelStyle: const TextStyle(
            color: LittleAtlasApp.atlasGreen,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          side: const BorderSide(color: LittleAtlasApp.atlasGreen),
          backgroundColor: LittleAtlasApp.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: _openFilterSheet,
        ),
      ),
    );

    // Distance chip
    if (provider.distanceRadius != null) {
      chips.add(
        _buildRemovableChip(
          label: _distanceLabel(provider.distanceRadius!),
          onDeleted: () => provider.setDistanceRadius(null),
        ),
      );
    }

    // Place type chip
    if (provider.placeType != null) {
      chips.add(
        _buildRemovableChip(
          label: _placeTypeLabel(provider.placeType!, l10n),
          onDeleted: () => provider.setPlaceType(null),
        ),
      );
    }

    // Age group chip
    if (provider.selectedAgeGroup != null) {
      chips.add(
        _buildRemovableChip(
          label: _ageGroupLabel(provider.selectedAgeGroup!, l10n),
          onDeleted: () => provider.setAgeGroup(null),
        ),
      );
    }

    // Category chips
    for (final cat in provider.selectedCategories) {
      chips.add(
        _buildRemovableChip(
          label: cat,
          onDeleted: () => provider.toggleCategory(cat),
        ),
      );
    }

    // Amenity chips
    for (final amenity in provider.selectedAmenities) {
      chips.add(
        _buildRemovableChip(
          label: amenity,
          onDeleted: () => provider.toggleAmenity(amenity),
        ),
      );
    }

    // "Clear all" button if any filters are active
    if (provider.hasActiveFilters) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: TextButton(
            onPressed: () => provider.clearFilters(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.clearAll,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips,
      ),
    );
  }

  Widget _buildRemovableChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: LittleAtlasApp.atlasGreen,
          ),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        deleteIconColor: LittleAtlasApp.atlasGreen,
        onDeleted: onDeleted,
        backgroundColor: LittleAtlasApp.atlasGreenLight,
        side: const BorderSide(color: LittleAtlasApp.atlasGreen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ── Results header ────────────────────────────────────────────────

  Widget _buildResultsHeader(PlacesProvider provider, AppLocalizations l10n) {
    if (provider.isLoading || provider.error != null) {
      return const SizedBox.shrink();
    }

    final count = provider.filteredPlaces.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        l10n.placesFound(count),
        style: const TextStyle(
          color: LittleAtlasApp.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Results body (list / loading / empty / error) ─────────────────

  Widget _buildResultsBody(PlacesProvider provider, AppLocalizations l10n) {
    // Loading state — skeleton shimmer
    if (provider.isLoading) {
      return _buildLoadingSkeleton();
    }

    // Error state
    if (provider.error != null) {
      return _buildErrorState(provider);
    }

    // Empty state
    if (provider.filteredPlaces.isEmpty) {
      return _buildEmptyState(l10n);
    }

    // Results list with pull-to-refresh
    return RefreshIndicator(
      color: LittleAtlasApp.atlasGreen,
      onRefresh: () async {
        final p = context.read<PlacesProvider>();
        if (p.places.isNotEmpty || p.searchQuery != null) {
          // Re-trigger the current fetch.
          p.setSearchQuery(p.searchQuery);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: provider.filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = provider.filteredPlaces[index];
          return PlaceCard(
            place: place,
            onTap: () {
              // Finding #5: navigate to place detail.
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlaceDetailScreen(place: place),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────────

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonCard(),
        );
      },
    );
  }

  // ── Empty state ───────────────────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPlacesFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: LittleAtlasApp.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryAdjustingFilters,
              style: const TextStyle(
                fontSize: 14,
                color: LittleAtlasApp.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────

  Widget _buildErrorState(PlacesProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? AppLocalizations.of(context)!.errorOccurred,
              style: const TextStyle(
                fontSize: 14,
                color: LittleAtlasApp.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                provider.setSearchQuery(provider.searchQuery);
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
