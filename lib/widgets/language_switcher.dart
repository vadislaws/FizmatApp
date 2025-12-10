import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale.languageCode;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(25),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'RU',
            isSelected: currentLang == 'ru',
            onTap: () => localeProvider.setLocale(const Locale('ru')),
            theme: theme,
          ),
          const SizedBox(width: 4),
          _LanguageButton(
            label: 'KZ',
            isSelected: currentLang == 'kk',
            onTap: () => localeProvider.setLocale(const Locale('kk')),
            theme: theme,
          ),
          const SizedBox(width: 4),
          _LanguageButton(
            label: 'EN',
            isSelected: currentLang == 'en',
            onTap: () => localeProvider.setLocale(const Locale('en')),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withAlpha(180),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
