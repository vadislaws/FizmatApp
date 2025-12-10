import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentMode = themeProvider.themeMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeButton(
            label: l10n.lightTheme,
            icon: Icons.light_mode,
            isSelected: currentMode == AppThemeMode.light,
            onTap: () => themeProvider.setThemeMode(AppThemeMode.light),
            theme: theme,
          ),
          const SizedBox(width: 4),
          _ThemeButton(
            label: l10n.darkTheme,
            icon: Icons.dark_mode,
            isSelected: currentMode == AppThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(AppThemeMode.dark),
            theme: theme,
          ),
          const SizedBox(width: 4),
          _ThemeButton(
            label: l10n.autoTheme,
            icon: Icons.brightness_auto,
            isSelected: currentMode == AppThemeMode.system,
            onTap: () => themeProvider.setThemeMode(AppThemeMode.system),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeButton({
    required this.label,
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
