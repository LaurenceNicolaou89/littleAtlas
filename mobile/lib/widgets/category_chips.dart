import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:little_atlas/providers/places_provider.dart';
import 'package:little_atlas/theme/design_tokens.dart';
import 'package:provider/provider.dart';

/// Data class for a filter category displayed as a chip on the map.
class _ChipCategory {
  final String slug;
  final String label;
  final IconData icon;

  const _ChipCategory({
    required this.slug,
    required this.label,
    required this.icon,
  });
}

const _categories = [
  _ChipCategory(
    slug: 'playground',
    label: 'Playgrounds',
    icon: Icons.child_care,
  ),
  _ChipCategory(
    slug: 'park',
    label: 'Parks',
    icon: Icons.park,
  ),
  _ChipCategory(
    slug: 'restaurant',
    label: 'Restaurants',
    icon: Icons.restaurant,
  ),
  _ChipCategory(
    slug: 'entertainment',
    label: 'Entertainment',
    icon: Icons.attractions,
  ),
  _ChipCategory(
    slug: 'culture',
    label: 'Culture',
    icon: Icons.museum,
  ),
  _ChipCategory(
    slug: 'sports',
    label: 'Sports',
    icon: Icons.sports_soccer,
  ),
];

/// A stateless chip bar that reads selected categories directly from
/// [PlacesProvider], eliminating dual-state bugs.
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();
    final selected = placesProvider.selectedCategories;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selected.contains(cat.slug);
          final catColor = AppColors.categoryColor(cat.slug);

          return AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: FilterChip(
              label: Text(cat.label),
              avatar: isSelected
                  ? Icon(Icons.check, size: 16, color: AppColors.primary)
                  : Icon(cat.icon, size: 16, color: catColor),
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.lightImpact();
                context.read<PlacesProvider>().toggleCategory(cat.slug);
              },
              selectedColor: AppColors.primaryWash,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              checkmarkColor: AppColors.primary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.chips),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}

// ── Helpers exposed for other widgets (markers, cards) ───────────────

Color categoryColor(String category) {
  return AppColors.categoryColor(category);
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
