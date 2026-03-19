import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// A full-width gradient button (Atlas Violet → Violet Light).
///
/// Provides haptic feedback on tap. Disabled state renders at 45 % opacity.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadii.buttonBorder,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            boxShadow: AppShadows.button,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
