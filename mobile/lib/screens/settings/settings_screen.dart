import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Design tokens from design-style.md
const _atlasGreen = Color(0xFF2E7D5F);
const _atlasGreenLight = Color(0xFFE8F5EE);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final selectedLang = settings.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ── Language section header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.language,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w600, // SemiBold – H2
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Language card ──
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _LanguageTile(
                  flag: '\u{1F1EC}\u{1F1E7}', // GB flag
                  title: 'English',
                  langCode: 'en',
                  isSelected: selectedLang == 'en',
                  onTap: () => settings.changeLanguage('en'),
                ),
                const Divider(height: 1),
                _LanguageTile(
                  flag: '\u{1F1EC}\u{1F1F7}', // GR flag
                  title: '\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac',
                  langCode: 'el',
                  isSelected: selectedLang == 'el',
                  onTap: () => settings.changeLanguage('el'),
                ),
                const Divider(height: 1),
                _LanguageTile(
                  flag: '\u{1F1F7}\u{1F1FA}', // RU flag
                  title: '\u0420\u0443\u0441\u0441\u043a\u0438\u0439',
                  langCode: 'ru',
                  isSelected: selectedLang == 'ru',
                  onTap: () => settings.changeLanguage('ru'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── About section header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.about,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w600, // SemiBold – H2
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── About card ──
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Version
                ListTile(
                  leading: const Icon(Icons.info_outline, color: _atlasGreen),
                  title: Text(l10n.version),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),

                // Data Sources
                ListTile(
                  leading: const Icon(Icons.storage_outlined, color: _atlasGreen),
                  title: Text(l10n.dataSources),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDataSourcesDialog(context, l10n),
                ),
                const Divider(height: 1),

                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: _atlasGreen),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://littleatlas.app/privacy'),
                ),
                const Divider(height: 1),

                // Terms of Service
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: _atlasGreen),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://littleatlas.app/terms'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  void _showDataSourcesDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dataSources),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dataSourcesDescription),
            const SizedBox(height: 16),
            _DataSourceRow(label: l10n.openStreetMap),
            _DataSourceRow(label: l10n.googlePlaces),
            _DataSourceRow(label: l10n.openWeatherMap),
            _DataSourceRow(label: l10n.communityContributions),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.close,
              style: const TextStyle(color: _atlasGreen),
            ),
          ),
        ],
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

// ── Language tile ──────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String title;
  final String langCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.title,
    required this.langCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isSelected ? _atlasGreenLight : null,
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check, color: _atlasGreen)
          : null,
      onTap: onTap,
    );
  }
}

// ── Data source row ───────────────────────────────────────────────────

class _DataSourceRow extends StatelessWidget {
  final String label;

  const _DataSourceRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: _atlasGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
