import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header with Avatar
              _buildProfileHeader(context, theme, l10n, user),
              const SizedBox(height: 30),
              // Position/Role Badge
              _buildPositionBadge(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Stats Card
              _buildStatsCard(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Bio Section
              if (user.bio != null && user.bio!.isNotEmpty)
                _buildBioCard(context, theme, l10n, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
  ) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: user.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(theme, user.fullName);
                    },
                  ),
                )
              : _buildDefaultAvatar(theme, user.fullName),
        ),
        const SizedBox(height: 16),
        // Full Name
        Text(
          user.fullName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        // Username
        Text(
          user.username != null ? '@${user.username}' : l10n.noUsername,
          style: TextStyle(
            fontSize: 16,
            color: user.username != null
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme, String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPositionBadge(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
  ) {
    final positionLabel = _getPositionLabel(l10n, user.position);
    final positionColor = _getPositionColor(user.position);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: positionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: positionColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPositionIcon(user.position),
            color: positionColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            positionLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: positionColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getPositionLabel(AppLocalizations l10n, String position) {
    switch (position) {
      case 'student':
        return l10n.positionStudent;
      case 'teacher':
        return l10n.positionTeacher;
      case 'director':
        return l10n.positionDirector;
      case 'school_government':
        return l10n.positionSchoolGovernment;
      case 'admin':
        return l10n.positionAdmin;
      default:
        return l10n.positionStudent;
    }
  }

  Color _getPositionColor(String position) {
    switch (position) {
      case 'student':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'director':
        return Colors.purple;
      case 'school_government':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getPositionIcon(String position) {
    switch (position) {
      case 'student':
        return Icons.school;
      case 'teacher':
        return Icons.person;
      case 'director':
        return Icons.business_center;
      case 'school_government':
        return Icons.groups;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.school;
    }
  }

  Widget _buildStatsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            l10n.classGrade,
            user.formattedClass,
            Icons.school,
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          _buildStatItem(
            theme,
            l10n.friends,
            user.friendCount.toString(),
            Icons.people,
          ),
          if (user.gpa != null) ...[
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            _buildStatItem(
              theme,
              l10n.gpa,
              user.gpa!.toStringAsFixed(2),
              Icons.star,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.bio,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.bio!,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
