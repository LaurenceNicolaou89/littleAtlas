import 'package:flutter/material.dart';

import 'package:little_atlas/providers/places_provider.dart';
import 'package:provider/provider.dart';

/// Data class for a filter category displayed as a chip on the map.
class _ChipCategory {
  final String slug;
  final String label;
  final Color color;
  final IconData icon;

  const _ChipCategory({
    required this.slug,
    required this.label,
    required this.color,
    required this.icon,
  });
}

const _categories = [
  _ChipCategory(
    slug: 'playground',
    label: 'Playgrounds',
    color: Color(0xFFFF8A65),
    icon: Icons.child_care,
  ),
  _ChipCategory(
    slug: 'park',
    label: 'Parks',
    color: Color(0xFF66BB6A),
    icon: Icons.park,
  ),
  _ChipCategory(
    slug: 'restaurant',
    label: 'Restaurants',
    color: Color(0xFFEF5350),
    icon: Icons.restaurant,
  ),
  _ChipCategory(
    slug: 'entertainment',
    label: 'Entertainment',
    color: Color(0xFFAB47BC),
    icon: Icons.attractions,
  ),
  _ChipCategory(
    slug: 'culture',
    label: 'Culture',
    color: Color(0xFF42A5F5),
    icon: Icons.museum,
  ),
  _ChipCategory(
    slug: 'sports',
    label: 'Sports',
    color: Color(0xFF26A69A),
    icon: Icons.sports_soccer,
  ),
];

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selected.contains(cat.slug);

          return FilterChip(
            label: Text(cat.label),
            avatar: isSelected
                ? null
                : Icon(cat.icon, size: 16, color: cat.color),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selected.add(cat.slug);
                } else {
                  _selected.remove(cat.slug);
                }
              });

              final placesProvider = context.read<PlacesProvider>();
              if (_selected.isEmpty) {
                placesProvider.setCategory(null);
              } else if (_selected.length == 1) {
                placesProvider.setCategory(_selected.first);
              } else {
                // Multiple selected — pass comma-separated or first
                placesProvider.setCategory(_selected.join(','));
              }
            },
            selectedColor: cat.color.withValues(alpha: 0.2),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? cat.color : const Color(0xFFE0E0E0),
            ),
            checkmarkColor: cat.color,
            labelStyle: TextStyle(
              color: isSelected ? cat.color : const Color(0xFF616161),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ── Helpers exposed for other widgets (markers, cards) ───────────────

Color categoryColor(String category) {
  final slug = category.toLowerCase();
  for (final cat in _categories) {
    if (slug.contains(cat.slug) || cat.slug.contains(slug)) {
      return cat.color;
    }
  }
  return const Color(0xFF9E9E9E);
}

IconData categoryIcon(String category) {
  final slug = category.toLowerCase();
  for (final cat in _categories) {
    if (slug.contains(cat.slug) || cat.slug.contains(slug)) {
      return cat.icon;
    }
  }
  return Icons.place;
}
