import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// A small pill-shaped badge showing an icon + label.
///
/// Used for open/closed status, distance, age range, closing time, etc.
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.iconContainers),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
