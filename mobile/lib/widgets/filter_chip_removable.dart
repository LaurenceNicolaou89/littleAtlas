import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// A removable filter chip used in the Search screen for active filters.
///
/// Displays a label and an X icon that calls [onRemove] with haptic feedback.
class FilterChipRemovable extends StatelessWidget {
  const FilterChipRemovable({
    super.key,
    required this.label,
    required this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final VoidCallback onRemove;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryWash;
    final fg = textColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.chipBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: fg.withAlpha(128), // 50 %
            ),
          ),
        ],
      ),
    );
  }
}
