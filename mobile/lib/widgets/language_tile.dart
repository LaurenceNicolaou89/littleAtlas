import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// A selectable language tile showing a flag emoji and language name.
///
/// Designed to be used as an [Expanded] child in a [Row] of language
/// options (typically three for English, Greek, Russian).
class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.flag,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardBorder,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2.5 : 1,
          ),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryWash, AppColors.surface],
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag emoji
            Text(
              flag,
              style: const TextStyle(fontSize: 36),
            ),

            // Selected indicator dot
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // Language name
            Text(
              languageName,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
