import 'package:fizmat_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final currentMode = themeProvider.themeMode;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeButton(
            icon: Icons.light_mode,
            isSelected: currentMode == AppThemeMode.light,
            onTap: () => themeProvider.setThemeMode(AppThemeMode.light),
            theme: theme,
          ),
          _ThemeButton(
            icon: Icons.dark_mode,
            isSelected: currentMode == AppThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(AppThemeMode.dark),
            theme: theme,
          ),
          _ThemeButton(
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
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeButton({
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Colors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
