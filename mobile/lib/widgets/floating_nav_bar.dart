import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_tokens.dart';

/// A floating bottom navigation bar with 5 tabs.
///
/// Positioned at the bottom of the screen with [AppSpacing.md] margin on all
/// sides, rounded corners, and an elevated shadow.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Index of the currently active tab (0-4).
  final int currentIndex;

  /// Called when a tab is tapped with the new index.
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.explore, label: 'Discover'),
    _NavItem(icon: Icons.search, label: 'Search'),
    _NavItem(icon: Icons.event, label: 'Events'),
    _NavItem(icon: Icons.map, label: 'Map'),
    _NavItem(icon: Icons.settings, label: 'Settings'),
  ];

  void _handleTap(int index) {
    if (index != currentIndex) {
      HapticFeedback.lightImpact();
      onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.navBar),
          boxShadow: AppShadows.nav,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;
            return Expanded(
              child: _NavBarItem(
                icon: item.icon,
                label: item.label,
                isActive: isActive,
                onTap: () => _handleTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active dot indicator above icon
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : Colors.transparent,
                ),
              ),
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(102), // 40%
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
