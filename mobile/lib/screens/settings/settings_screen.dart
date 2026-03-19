import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/info_pill.dart';
import '../../widgets/language_tile.dart';
import '../../widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final selectedLang = settings.locale.languageCode;

    // Resolve current language display name
    final currentLanguageName = switch (selectedLang) {
      'el' => 'Ελληνικά',
      'ru' => 'Русский',
      _ => 'English',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 24),

            // ── Header ──────────────────────────────────────────────
            Text(
              l10n.settings,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Make Little Atlas yours',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ── Language card ───────────────────────────────────────
            SettingsCard(
              icon: Icons.language,
              iconGradient: const [AppColors.primary, AppColors.primaryLight],
              title: l10n.language,
              subtitle: 'Currently: $currentLanguageName',
              child: Row(
                children: [
                  Expanded(
                    child: LanguageTile(
                      flag: '\u{1F1EC}\u{1F1E7}',
                      languageName: 'English',
                      isSelected: selectedLang == 'en',
                      onTap: () => settings.changeLanguage('en'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: LanguageTile(
                      flag: '\u{1F1EC}\u{1F1F7}',
                      languageName: 'Ελληνικά',
                      isSelected: selectedLang == 'el',
                      onTap: () => settings.changeLanguage('el'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: LanguageTile(
                      flag: '\u{1F1F7}\u{1F1FA}',
                      languageName: 'Русский',
                      isSelected: selectedLang == 'ru',
                      onTap: () => settings.changeLanguage('ru'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Data Sources card ───────────────────────────────────
            SettingsCard(
              icon: Icons.bar_chart,
              iconGradient: const [
                AppColors.aquaTeal,
                Color(0xFF81ECEC),
              ],
              title: l10n.dataSources,
              subtitle: 'Where our info comes from',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  InfoPill(
                    label: 'OpenStreetMap',
                    backgroundColor: AppColors.aquaTeal.withAlpha(30),
                    textColor: AppColors.aquaTeal,
                  ),
                  InfoPill(
                    label: 'Google Places',
                    backgroundColor: AppColors.primary.withAlpha(30),
                    textColor: AppColors.primary,
                  ),
                  InfoPill(
                    label: 'OpenWeather',
                    backgroundColor: AppColors.honeyGold.withAlpha(50),
                    textColor: const Color(0xFF6C5100),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Legal card ──────────────────────────────────────────
            SettingsCard(
              icon: Icons.description,
              iconGradient: const [
                AppColors.honeyGold,
                Color(0xFFFFEAA7),
              ],
              title: 'Legal',
              child: Row(
                children: [
                  Expanded(
                    child: _LegalTile(
                      label: l10n.privacyPolicy,
                      onTap: () =>
                          _launchUrl('https://littleatlas.app/privacy'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _LegalTile(
                      label: l10n.termsOfService,
                      onTap: () =>
                          _launchUrl('https://littleatlas.app/terms'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Branding footer ─────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'Little Atlas',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v2.0.0 \u00B7 Made with \u2665 in Cyprus',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Legal tile ────────────────────────────────────────────────────────

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
