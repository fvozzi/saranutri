import 'package:flutter/material.dart';
import 'package:saranutri/l10n/app_localizations.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({required this.onLocaleChanged, super.key});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return PopupMenuButton<Locale>(
      tooltip: localizations.changeLanguage,
      icon: const Icon(Icons.language),
      onSelected: onLocaleChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Text(localizations.languageEnglish),
        ),
        PopupMenuItem(
          value: const Locale('es'),
          child: Text(localizations.languageSpanish),
        ),
        PopupMenuItem(
          value: const Locale('pt'),
          child: Text(localizations.languagePortuguese),
        ),
      ],
    );
  }
}
