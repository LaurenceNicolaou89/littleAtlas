import 'package:flutter/material.dart';

import 'package:little_atlas/app.dart';

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

  static const List<String> _allCategories = [
    'Playgrounds',
    'Parks & Nature',
    'Restaurants',
    'Entertainment',
    'Culture & Education',
    'Sports & Activities',
    'Shopping',
    'Beaches',
  ];

  static const List<_AgeOption> _ageOptions = [
    _AgeOption(label: 'Infant (0-1)', value: 'infant'),
    _AgeOption(label: 'Toddler (1-3)', value: 'toddler'),
    _AgeOption(label: 'Preschool (3-5)', value: 'preschool'),
    _AgeOption(label: 'School Age (6-12)', value: 'school_age'),
  ];

  static const List<_TypeOption> _typeOptions = [
    _TypeOption(label: 'Indoor', value: 'indoor'),
    _TypeOption(label: 'Outdoor', value: 'outdoor'),
    _TypeOption(label: 'Both', value: null),
  ];

  static const List<String> _allAmenities = [
    'Changing Table',
    'High Chair',
    'Kids Menu',
    'Stroller Access',
    'Fenced Area',
    'Parking',
    'Wheelchair Access',
    'Toilets',
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
                      'Filters',
                      style: theme.textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
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
                    _buildSectionHeader('Distance'),
                    _buildDistanceSection(),
                    _buildSectionHeader('Category'),
                    _buildCategorySection(),
                    _buildSectionHeader('Age Group'),
                    _buildAgeGroupSection(),
                    _buildSectionHeader('Type'),
                    _buildTypeSection(),
                    _buildSectionHeader('Amenities'),
                    _buildAmenitiesSection(),
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
                    child: const Text('Apply'),
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

  Widget _buildCategorySection() {
    return Column(
      children: _allCategories.map((cat) {
        return CheckboxListTile(
          title: Text(cat),
          value: _categories.contains(cat),
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _categories.add(cat);
              } else {
                _categories.remove(cat);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAgeGroupSection() {
    return Column(
      children: _ageOptions.map((opt) {
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

  Widget _buildTypeSection() {
    return Column(
      children: _typeOptions.map((opt) {
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

  Widget _buildAmenitiesSection() {
    return Column(
      children: _allAmenities.map((amenity) {
        return CheckboxListTile(
          title: Text(amenity),
          value: _amenities.contains(amenity),
          activeColor: LittleAtlasApp.atlasGreen,
          dense: true,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _amenities.add(amenity);
              } else {
                _amenities.remove(amenity);
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
