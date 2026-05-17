import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/widgets/language_switcher.dart';
import 'package:fizmat_app/widgets/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FizProfile extends StatelessWidget {
  const FizProfile({super.key});

  /// Check if user has admin panel access
  bool _hasAdminAccess(String position) {
    const adminRoles = ['admin', 'moderator', 'teacher', 'school_government'];
    return adminRoles.contains(position);
  }

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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 80 : 24,
            vertical: 20,
          ),
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
              // Social Links
              _buildSocialLinks(context, theme, user),
              // Friends Preview
              _buildFriendsPreview(context, theme, l10n, user),
              const SizedBox(height: 20),
              // Edit Profile Button
              _buildEditButton(context, theme, l10n),
              const SizedBox(height: 30),
              // Settings Section
              _buildSettingsSection(context, theme, l10n),
              const SizedBox(height: 20),
              // Admin Panel Button (for admin roles)
              if (_hasAdminAccess(user.position))
                _buildAdminPanelButton(context, theme, l10n),
              if (_hasAdminAccess(user.position)) const SizedBox(height: 20),
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
        // Avatar (display only)
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

  Widget _buildSocialLinks(BuildContext context, ThemeData theme, dynamic user) {
    final instagram = user.instagram as String?;
    final telegram = user.telegram as String?;
    if ((instagram == null || instagram.isEmpty) && (telegram == null || telegram.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (instagram != null && instagram.isNotEmpty)
              _buildSocialRow(theme, Icons.camera_alt, '@$instagram', Colors.purple),
            if (instagram != null && instagram.isNotEmpty && telegram != null && telegram.isNotEmpty)
              const SizedBox(height: 12),
            if (telegram != null && telegram.isNotEmpty)
              _buildSocialRow(theme, Icons.send, '@$telegram', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow(ThemeData theme, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
      ],
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
                    '${user.friendCount} ${_pluralizeFriends(user.friendCount, l10n)}',
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

  String _pluralizeFriends(int count, AppLocalizations l10n) {
    final lang = l10n.locale.languageCode;
    if (lang == 'ru') {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return 'друг';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return 'друга';
      return 'друзей';
    }
    if (lang == 'kk') return 'дос';
    return count == 1 ? 'friend' : 'friends';
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
  late TextEditingController _instagramController;
  late TextEditingController _telegramController;
  int? _gradeNumber;
  String? _gradeLetter;
  bool _isPrivate = false;
  bool _isLoading = false;
  String? _usernameError;

  final List<int> _grades = [7, 8, 9, 10, 11];
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user.username ?? '');
    _nameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _instagramController = TextEditingController(text: widget.user.instagram ?? '');
    _telegramController = TextEditingController(text: widget.user.telegram ?? '');
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
    _instagramController.dispose();
    _telegramController.dispose();
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
                    _buildTextField(
                      controller: _instagramController,
                      label: 'Instagram',
                      hint: 'username',
                      icon: Icons.camera_alt,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _telegramController,
                      label: 'Telegram',
                      hint: 'username',
                      icon: Icons.send,
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
    final isKundelikConnected = widget.user.kundelikConnected == true;

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
        if (isKundelikConnected) ...[
          // Read-only display when Kundelik is connected
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  _gradeNumber != null
                      ? '$_gradeNumber${_gradeLetter ?? ''}'
                      : l10n.graduated,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(
                      'Kundelik',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
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
                          if (value == null) _gradeLetter = null;
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
      instagram: _instagramController.text.trim() != (widget.user.instagram ?? '')
          ? _instagramController.text.trim()
          : null,
      telegram: _telegramController.text.trim() != (widget.user.telegram ?? '')
          ? _telegramController.text.trim()
          : null,
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

