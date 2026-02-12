import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/screens/admin/create_news_screen.dart';
import 'package:fizmat_app/screens/admin/create_notification_screen.dart';
import 'package:fizmat_app/screens/admin/manage_content_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Roles that have access to admin panel
const List<String> adminRoles = [
  'admin',           // Full admin
  'moderator',       // Can delete any content
  'teacher',         // Can create content
  'school_government', // Student council - can create content
];

/// Check if user has admin panel access
bool hasAdminAccess(String? position) {
  if (position == null) return false;
  return adminRoles.contains(position);
}

/// Check if user can delete any content (not just their own)
bool canModerateContent(String? position) {
  return position == 'admin' || position == 'moderator';
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    // Check if user has admin access
    if (user == null || !hasAdminAccess(user.position)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminPanel),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('access_denied'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('admin_only'),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanel),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Role badge
          _buildRoleBadge(context, theme, l10n, user.position),
          const SizedBox(height: 20),

          // Create news
          _buildAdminCard(
            context,
            theme,
            l10n,
            title: l10n.translate('create_news'),
            subtitle: l10n.translate('create_news_desc'),
            icon: Icons.article,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNewsScreen(user: user),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Create notification
          _buildAdminCard(
            context,
            theme,
            l10n,
            title: l10n.translate('create_notification'),
            subtitle: l10n.translate('create_notification_desc'),
            icon: Icons.notifications,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNotificationScreen(user: user),
                ),
              );
            },
          ),

          // Moderator-only features
          if (canModerateContent(user.position)) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(context, theme, l10n.translate('moderation')),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              theme,
              l10n,
              title: l10n.translate('manage_content'),
              subtitle: l10n.translate('manage_content_desc'),
              icon: Icons.admin_panel_settings,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageContentScreen(user: user),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String position,
  ) {
    final roleInfo = _getRoleInfo(position, l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: roleInfo['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: roleInfo['color'].withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: roleInfo['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              roleInfo['icon'],
              color: roleInfo['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('your_role'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleInfo['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: roleInfo['color'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(String position, AppLocalizations l10n) {
    switch (position) {
      case 'admin':
        return {
          'title': l10n.translate('role_admin'),
          'icon': Icons.admin_panel_settings,
          'color': Colors.red,
        };
      case 'moderator':
        return {
          'title': l10n.translate('role_moderator'),
          'icon': Icons.shield,
          'color': Colors.purple,
        };
      case 'teacher':
        return {
          'title': l10n.translate('role_teacher'),
          'icon': Icons.school,
          'color': Colors.green,
        };
      case 'school_government':
        return {
          'title': l10n.translate('role_school_government'),
          'icon': Icons.groups,
          'color': Colors.orange,
        };
      default:
        return {
          'title': position,
          'icon': Icons.person,
          'color': Colors.grey,
        };
    }
  }

  Widget _buildSectionTitle(
    BuildContext context,
    ThemeData theme,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
