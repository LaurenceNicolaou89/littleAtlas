import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// A generic settings section card with a gradient icon, title, optional
/// subtitle, and an arbitrary [child] widget slot.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.iconGradient,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardBorder,
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              // Gradient icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.iconContainerBorder,
                  gradient: LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title + optional subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Child content ───────────────────────────────────────────
          child,
        ],
      ),
    );
  }
}
