import 'dart:io';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/providers/kundelik_provider.dart';
import 'package:fizmat_app/widgets/language_switcher.dart';
import 'package:fizmat_app/widgets/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FizProfile extends StatelessWidget {
  const FizProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header with Avatar
              _buildProfileHeader(context, theme, l10n, user, authProvider),
              const SizedBox(height: 30),
              // Position/Role Badge
              _buildPositionBadge(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Stats Card (Class, GPA, Privacy)
              _buildStatsCard(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Bio Section
              _buildBioCard(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Friends Preview
              _buildFriendsPreview(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Edit Profile Button
              _buildEditButton(context, theme, l10n),
              const SizedBox(height: 30),
              // Settings Section
              _buildSettingsSection(context, theme, l10n),
              const SizedBox(height: 20),
              // Kundelik Section (only for students)
              if (user.position == 'student')
                _buildKundelikSection(context, theme, l10n, user, authProvider),
              if (user.position == 'student') const SizedBox(height: 20),
              // Admin Panel Button (only for admins)
              if (user.position == 'admin')
                _buildAdminPanelButton(context, theme, l10n),
              if (user.position == 'admin') const SizedBox(height: 20),
              // Logout Button
              _buildLogoutButton(context, theme, l10n, authProvider),
              const SizedBox(height: 20),
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
    dynamic user,
    AuthProvider authProvider,
  ) {
    return Column(
      children: [
        // Avatar with Upload Button
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showAvatarOptions(context, authProvider),
              child: Container(
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
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showAvatarOptions(context, authProvider),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
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
        const SizedBox(height: 4),
        // Email
        Text(
          user.email,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    dynamic user,
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
    dynamic user,
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
            l10n.gpa,
            user.gpa != null ? user.gpa!.toStringAsFixed(2) : '--',
            Icons.star,
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
    dynamic user,
  ) {
    if (user.bio == null || user.bio.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.noBio,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

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
            user.bio,
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

  Widget _buildFriendsPreview(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic user,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/friends');
        },
        child: Row(
          children: [
            Icon(
              Icons.people,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.friends,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.friendCount} ${l10n.friends.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showEditProfileDialog(context);
        },
        icon: const Icon(Icons.edit),
        label: Text(
          l10n.editProfile,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
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
          Text(
            l10n.settings,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          // Theme Settings
          Row(
            children: [
              Icon(
                Icons.palette,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.appearance,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const ThemeSwitcher(),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          // Language Settings
          Row(
            children: [
              Icon(
                Icons.language,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const LanguageSwitcher(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKundelikSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic user,
    AuthProvider authProvider,
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
                user.kundelikConnected ? Icons.check_circle : Icons.cloud_off,
                color: user.kundelikConnected ? Colors.green : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.kundelik,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.kundelikConnected
                          ? l10n.kundelikConnected
                          : l10n.kundelikNotConnected,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (user.kundelikConnected) {
                    // Sync Kundelik data
                    await _syncKundelik(context, authProvider);
                  } else {
                    // Connect to Kundelik
                    await _connectToKundelik(context);
                  }
                },
                child: Text(
                  user.kundelikConnected
                      ? l10n.syncKundelik
                      : l10n.connectKundelik,
                ),
              ),
            ],
          ),
          if (user.kundelikConnected) ...[
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            // GPA
            if (user.gpa != null)
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${l10n.gpa}: ${user.gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            if (user.gpa != null) const SizedBox(height: 12),
            // Birthday
            if (user.birthday != null)
              Row(
                children: [
                  Icon(
                    Icons.cake,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${l10n.birthday}: ${_formatDate(user.birthday)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            if (user.birthday != null) const SizedBox(height: 12),
            // Last synced
            if (user.lastKundelikSync != null)
              Row(
                children: [
                  Icon(
                    Icons.sync,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${l10n.lastSynced}: ${_formatDateTime(user.lastKundelikSync)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminPanelButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/admin');
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: Text(
          l10n.adminPanel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.confirmLogout),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.no),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.yes),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await authProvider.signOut();
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(
          l10n.logout,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red),
          foregroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, authProvider, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, authProvider, ImageSource.camera);
              },
            ),
            if (authProvider.userModel?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  l10n.removeAvatar,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.updateProfile(avatarUrl: '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.avatarRemoved),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    AuthProvider authProvider,
    ImageSource source,
  ) async {
    final l10n = AppLocalizations.of(context);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!context.mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loading),
                ],
              ),
            ),
          ),
        ),
      );

      final imageFile = File(pickedFile.path);
      final url = await authProvider.uploadAvatar(imageFile);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarUploadFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog if open
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(user: user),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Connect to Kundelik
  Future<void> _connectToKundelik(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/kundelik-connect');

    if (result == true && context.mounted) {
      // Connection successful, data already synced in the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).kundelikConnected),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Sync Kundelik data
  Future<void> _syncKundelik(BuildContext context, AuthProvider authProvider) async {
    final l10n = AppLocalizations.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.loading),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Import KundelikProvider
      final kundelikProvider = Provider.of<KundelikProvider>(context, listen: false);

      // Sync data
      final data = await kundelikProvider.syncData();

      if (data != null) {
        // Update auth provider with new data
        await authProvider.updateKundelikData(
          isConnected: true,
          gpa: data['gpa'],
          birthday: data['birthday'],
          kundelikData: data['fullData'],
        );

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.syncKundelik} ${l10n.success.toLowerCase()}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kundelikProvider.errorMessage ?? l10n.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final dynamic user;

  const _EditProfileBottomSheet({required this.user});

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  int? _gradeNumber;
  String? _gradeLetter;
  bool _isPrivate = false;
  bool _isLoading = false;
  String? _usernameError; // Track username availability error

  final List<int> _grades = [7, 8, 9, 10, 11];
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user.username ?? '');
    _nameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _gradeNumber = widget.user.classGradeNumber;
    _gradeLetter = widget.user.classLetter;
    _isPrivate = widget.user.isPrivate;

    // Clear username error when user types
    _usernameController.addListener(() {
      if (_usernameError != null) {
        setState(() {
          _usernameError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  l10n.editProfile,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.changeName,
                      hint: l10n.fullName,
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildUsernameField(theme, l10n),
                    const SizedBox(height: 20),
                    // Class Dropdowns
                    _buildClassDropdowns(theme, l10n),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _bioController,
                      label: l10n.changeBio,
                      hint: l10n.enterBio,
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    // Privacy Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPrivate ? Icons.lock : Icons.public,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.privacy,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isPrivate
                                      ? l10n.privateProfile
                                      : l10n.publicProfile,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.alternate_email, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.changeUsername,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: l10n.enterUsername,
            filled: true,
            fillColor: theme.cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: _usernameError != null
                  ? BorderSide(color: Colors.red, width: 2)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _usernameError != null ? Colors.red : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.usernameRequired;
            }
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (!authProvider.validateUsername(value)) {
              return l10n.usernameInvalid;
            }
            if (value.length < 3) {
              return l10n.usernameTooShort;
            }
            if (value.length > 20) {
              return l10n.usernameTooLong;
            }
            return _usernameError;
          },
        ),
        if (_usernameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _usernameError!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClassDropdowns(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.changeClass,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Grade Number Dropdown
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _gradeNumber,
                    hint: Text(l10n.gradeNumber),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.graduated),
                      ),
                      ..._grades.map((grade) {
                        return DropdownMenuItem<int?>(
                          value: grade,
                          child: Text('$grade'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gradeNumber = value;
                        if (value == null) {
                          _gradeLetter = null;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Letter Dropdown
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _gradeLetter,
                    hint: Text(l10n.letter),
                    isExpanded: true,
                    items: _letters.map((letter) {
                      return DropdownMenuItem<String?>(
                        value: letter,
                        child: Text(letter),
                      );
                    }).toList(),
                    onChanged: _gradeNumber == null
                        ? null
                        : (value) {
                            setState(() {
                              _gradeLetter = value;
                            });
                          },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    // Check if username changed and is available
    if (_usernameController.text.trim() != widget.user.username) {
      final isAvailable = await authProvider
          .checkUsernameAvailability(_usernameController.text.trim());
      if (!isAvailable && mounted) {
        setState(() {
          _isLoading = false;
          _usernameError = l10n.usernameTaken;
        });
        _formKey.currentState!.validate(); // Trigger validation to show error
        return;
      }
    }

    final success = await authProvider.updateProfile(
      fullName: _nameController.text.trim() != widget.user.fullName
          ? _nameController.text.trim()
          : null,
      username: _usernameController.text.trim() != widget.user.username
          ? _usernameController.text.trim()
          : null,
      bio: _bioController.text.trim() != widget.user.bio
          ? _bioController.text.trim()
          : null,
      classGradeNumber: _gradeNumber != widget.user.classGradeNumber
          ? _gradeNumber
          : null,
      classLetter: _gradeLetter != widget.user.classLetter ? _gradeLetter : null,
      isPrivate: _isPrivate != widget.user.isPrivate ? _isPrivate : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && authProvider.errorCode != null) {
      final errorMessage = l10n.getAuthErrorMessage(authProvider.errorCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
