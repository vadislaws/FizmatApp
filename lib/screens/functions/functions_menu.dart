import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/screens/birthday/birthday.dart';
import 'package:fizmat_app/screens/book/book.dart';
import 'package:fizmat_app/screens/clubs/clubs_screen.dart';
import 'package:fizmat_app/screens/formula/formula.dart';
import 'package:fizmat_app/screens/olympiads/olympiads_screen.dart';
import 'package:fizmat_app/screens/timetb/timetb.dart';
import 'package:flutter/material.dart';

class FunctionsMenu extends StatelessWidget {
  const FunctionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Title
            Text(
              l10n.translate('functions'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('functions_description'),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            // Menu Grid
            _buildMenuGrid(context, theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final menuItems = [
      // Olympiads - moved to first position (main priority)
      _MenuItem(
        title: l10n.translate('olympiads'),
        icon: Icons.emoji_events,
        color: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OlympiadsScreen()),
        ),
      ),
      _MenuItem(
        title: l10n.translate('schedules'),
        icon: Icons.calendar_today,
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizTimetb()),
        ),
      ),
      _MenuItem(
        title: l10n.translate('clubs'),
        icon: Icons.groups,
        color: Colors.purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClubsScreen()),
        ),
      ),
      _MenuItem(
        title: l10n.translate('formulas'),
        icon: Icons.functions,
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizFormula()),
        ),
      ),
      _MenuItem(
        title: l10n.translate('birthdays'),
        icon: Icons.cake,
        color: Colors.pink,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizBirthday()),
        ),
      ),
      _MenuItem(
        title: l10n.translate('books'),
        icon: Icons.menu_book,
        color: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizBookOnline()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(context, theme, item);
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    ThemeData theme,
    _MenuItem item,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                item.color.withValues(alpha: 0.1),
                item.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 32,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
