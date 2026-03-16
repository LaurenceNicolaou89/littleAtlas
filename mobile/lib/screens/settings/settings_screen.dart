import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _LanguageTile(
            title: 'English',
            langCode: 'en',
            isSelected: settings.locale.languageCode == 'en',
            onTap: () => settings.changeLanguage('en'),
          ),
          _LanguageTile(
            title: '\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac',
            langCode: 'el',
            isSelected: settings.locale.languageCode == 'el',
            onTap: () => settings.changeLanguage('el'),
          ),
          _LanguageTile(
            title: '\u0420\u0443\u0441\u0441\u043a\u0438\u0439',
            langCode: 'ru',
            isSelected: settings.locale.languageCode == 'ru',
            onTap: () => settings.changeLanguage('ru'),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String langCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.langCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF2E7D5F)) : null,
      onTap: onTap,
    );
  }
}
