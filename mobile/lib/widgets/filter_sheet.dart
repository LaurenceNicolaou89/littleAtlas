import 'package:flutter/material.dart';

import 'package:little_atlas/app.dart';
import 'package:little_atlas/l10n/app_localizations.dart';

/// A modal bottom sheet that lets users set search filters for places.
///
/// Sections: Distance, Category, Age Group, Type, Amenities.
class FilterSheet extends StatefulWidget {
  final int? initialDistance;
  final Set<String> initialCategories;
  final String? initialAgeGroup;
  final String? initialPlaceType;
  final Set<String> initialAmenities;

  const FilterSheet({
    super.key,
    this.initialDistance,
    this.initialCategories = const {},
    this.initialAgeGroup,
    this.initialPlaceType,
    this.initialAmenities = const {},
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late int? _distance;
  late Set<String> _categories;
  late String? _ageGroup;
  late String? _placeType;
  late Set<String> _amenities;

  // ── Data ──────────────────────────────────────────────────────────

  static const List<_DistanceOption> _distanceOptions = [
    _DistanceOption(label: '1 km', meters: 1000),
    _DistanceOption(label: '5 km', meters: 5000),
    _DistanceOption(label: '10 km', meters: 10000),
    _DistanceOption(label: '25 km', meters: 25000),
  ];

  // Category labels are resolved from l10n at build time.
  static List<_CategoryOption> _categoryOptions(AppLocalizations l10n) => [
    _CategoryOption(label: l10n.categoryPlaygrounds, value: 'Playgrounds'),
    _CategoryOption(label: l10n.categoryParks, value: 'Parks & Nature'),
    _CategoryOption(label: l10n.categoryRestaurants, value: 'Restaurants'),
    _CategoryOption(label: l10n.categoryEntertainment, value: 'Entertainment'),
    _CategoryOption(label: l10n.categoryCulture, value: 'Culture & Education'),
    _CategoryOption(label: l10n.categorySports, value: 'Sports & Activities'),
    _CategoryOption(label: l10n.categoryShopping, value: 'Shopping'),
    _CategoryOption(label: l10n.categoryBeaches, value: 'Beaches'),
  ];

  static List<_AgeOption> _ageOptions(AppLocalizations l10n) => [
    _AgeOption(label: l10n.ageInfant, value: 'infant'),
    _AgeOption(label: l10n.ageToddler, value: 'toddler'),
    _AgeOption(label: l10n.agePreschool, value: 'preschool'),
    _AgeOption(label: l10n.ageSchoolAge, value: 'school_age'),
  ];

  static List<_TypeOption> _typeOptions(AppLocalizations l10n) => [
    _TypeOption(label: l10n.indoor, value: 'indoor'),
    _TypeOption(label: l10n.outdoor, value: 'outdoor'),
    _TypeOption(label: l10n.both, value: null),
  ];

  static List<_AmenityOption> _amenityOptions(AppLocalizations l10n) => [
    _AmenityOption(label: l10n.amenityChangingTable, value: 'Changing Table'),
    _AmenityOption(label: l10n.amenityHighChair, value: 'High Chair'),
    _AmenityOption(label: l10n.amenityKidsMenu, value: 'Kids Menu'),
    _AmenityOption(label: l10n.amenityStrollerAccess, value: 'Stroller Access'),
    _AmenityOption(label: l10n.amenityFencedArea, value: 'Fenced Area'),
    _AmenityOption(label: l10n.amenityParking, value: 'Parking'),
    _AmenityOption(label: l10n.amenityWheelchairAccess, value: 'Wheelchair Access'),
    _AmenityOption(label: l10n.amenityToilets, value: 'Toilets'),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
    _categories = Set<String>.from(widget.initialCategories);
    _ageGroup = widget.initialAgeGroup;
    _placeType = widget.initialPlaceType;
    _amenities = Set<String>.from(widget.initialAmenities);
  }

  void _reset() {
    setState(() {
      _distance = null;
      _categories = {};
      _ageGroup = null;
      _placeType = null;
      _amenities = {};
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      FilterResult(
        distance: _distance,
        categories: _categories,
        ageGroup: _ageGroup,
        placeType: _placeType,
        amenities: _amenities,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: LittleAtlasApp.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // ── Handle & header ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.filters,
                      style: theme.textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: Text(l10n.reset),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Scrollable content ──────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSectionHeader(l10n.distance),
                    _buildDistanceSection(),
                    _buildSectionHeader(l10n.category),
                    _buildCategorySection(l10n),
                    _buildSectionHeader(l10n.ageGroup),
                    _buildAgeGroupSection(l10n),
                    _buildSectionHeader(l10n.type),
                    _buildTypeSection(l10n),
                    _buildSectionHeader(l10n.amenities),
                    _buildAmenitiesSection(l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Apply button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LittleAtlasApp.atlasGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.apply),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Section builders ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      children: _distanceOptions.map((opt) {
        return RadioListTile<int?>(
          title: Text(opt.label),
          value: opt.meters,
          groupValue: _distance,
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (value) => setState(() => _distance = value),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    return Column(
      children: _categoryOptions(l10n).map((opt) {
        return CheckboxListTile(
          title: Text(opt.label),
          value: _categories.contains(opt.value),
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _categories.add(opt.value);
              } else {
                _categories.remove(opt.value);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAgeGroupSection(AppLocalizations l10n) {
    return Column(
      children: _ageOptions(l10n).map((opt) {
        return RadioListTile<String?>(
          title: Text(opt.label),
          value: opt.value,
          groupValue: _ageGroup,
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (value) => setState(() => _ageGroup = value),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSection(AppLocalizations l10n) {
    return Column(
      children: _typeOptions(l10n).map((opt) {
        return RadioListTile<String?>(
          title: Text(opt.label),
          value: opt.value,
          groupValue: _placeType,
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (value) => setState(() => _placeType = value),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesSection(AppLocalizations l10n) {
    return Column(
      children: _amenityOptions(l10n).map((opt) {
        return CheckboxListTile(
          title: Text(opt.label),
          value: _amenities.contains(opt.value),
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _amenities.add(opt.value);
              } else {
                _amenities.remove(opt.value);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────

class _DistanceOption {
  final String label;
  final int meters;
  const _DistanceOption({required this.label, required this.meters});
}

class _CategoryOption {
  final String label;
  final String value;
  const _CategoryOption({required this.label, required this.value});
}

class _AgeOption {
  final String label;
  final String value;
  const _AgeOption({required this.label, required this.value});
}

class _TypeOption {
  final String label;
  final String? value;
  const _TypeOption({required this.label, required this.value});
}

class _AmenityOption {
  final String label;
  final String value;
  const _AmenityOption({required this.label, required this.value});
}

/// Returned from the [FilterSheet] when the user taps "Apply".
class FilterResult {
  final int? distance;
  final Set<String> categories;
  final String? ageGroup;
  final String? placeType;
  final Set<String> amenities;

  const FilterResult({
    this.distance,
    this.categories = const {},
    this.ageGroup,
    this.placeType,
    this.amenities = const {},
  });
}
