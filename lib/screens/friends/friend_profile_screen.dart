import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendProfileScreen extends StatefulWidget {
  final String userId;

  const FriendProfileScreen({super.key, required this.userId});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final FriendsService _friendsService = FriendsService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isFriend = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!);
        final currentUid = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;

        if (currentUid != null) {
          final friendDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .collection('friends')
              .doc(widget.userId)
              .get();
          _isFriend = friendDoc.exists;
        }

        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.userModel;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.translate('error')),
        ),
      );
    }

    final isOwnProfile = currentUser?.uid == widget.userId;
    final isPrivate = _user!.isPrivate && !_isFriend && !isOwnProfile;

    // Helper functions for privacy checks
    bool canShowGpa() {
      if (isOwnProfile) return true;
      if (isPrivate) return false;
      if (_user!.showGpaToFriendsOnly) return _isFriend;
      return true;
    }

    bool canShowBio() {
      if (isOwnProfile) return true;
      if (isPrivate) return false;
      if (_user!.showBioToFriendsOnly) return _isFriend;
      return true;
    }

    bool canShowClass() {
      if (isOwnProfile) return true;
      if (isPrivate) return false;
      if (_user!.showClassToFriendsOnly) return _isFriend;
      return true;
    }

    bool canShowBirthday() {
      if (isOwnProfile) return true;
      if (isPrivate) return false;
      if (_user!.showBirthdayToFriendsOnly) return _isFriend;
      return true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.fullName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header with Avatar (always visible)
              _buildProfileHeader(context, theme, l10n, _user!),
              const SizedBox(height: 30),
              // Position/Role Badge (always visible)
              _buildPositionBadge(context, theme, l10n, _user!),
              const SizedBox(height: 20),

              // Private profile indicator
              if (isPrivate) ...[
                _buildPrivateIndicator(context, theme, l10n),
                const SizedBox(height: 20),
              ],

              // Show stats if not fully private
              if (!isPrivate) ...[
                _buildStatsCard(
                  context,
                  theme,
                  l10n,
                  _user!,
                  showClass: canShowClass(),
                  showGpa: canShowGpa(),
                ),
                const SizedBox(height: 20),
              ],

              // Bio Section
              if (!isPrivate && canShowBio() && _user!.bio != null && _user!.bio!.isNotEmpty) ...[
                _buildBioCard(context, theme, l10n, _user!),
                const SizedBox(height: 20),
              ],

              // Friends List
              if (!isPrivate) ...[
                _buildFriendsListCard(context, theme, l10n, _user!.uid),
                const SizedBox(height: 20),
              ],

              // Friend actions
              if (currentUser != null && !isOwnProfile)
                _buildFriendActions(context, theme, l10n, currentUser.uid),
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
        if (user.username != null)
          Text(
            '@${user.username}',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.primary,
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
        style: const TextStyle(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _getPositionColor(user.position).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPositionColor(user.position),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPositionIcon(user.position),
            color: _getPositionColor(user.position),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getPositionLabel(l10n, user.position),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getPositionColor(user.position),
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
    UserModel user, {
    bool showClass = true,
    bool showGpa = true,
  }) {
    final List<Widget> stats = [];

    // Add class if allowed
    if (showClass) {
      stats.add(_buildStatItem(
        theme,
        l10n.classGrade,
        user.formattedClass,
        Icons.school,
      ));
    }

    // Add GPA if allowed
    if (showGpa) {
      if (stats.isNotEmpty) {
        stats.add(Container(
          width: 1,
          height: 40,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ));
      }
      stats.add(_buildStatItem(
        theme,
        l10n.gpa,
        user.gpa != null ? user.gpa!.toStringAsFixed(2) : '--',
        Icons.star,
      ));
    }

    // Always add friends count
    if (stats.isNotEmpty) {
      stats.add(Container(
        width: 1,
        height: 40,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      ));
    }
    stats.add(_buildStatItem(
      theme,
      l10n.friends,
      user.friendCount.toString(),
      Icons.people,
    ));

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
        children: stats,
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

  Widget _buildFriendsListCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String userId,
  ) {
    return StreamBuilder<List<String>>(
      stream: _friendsService.getFriendsList(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final friendIds = snapshot.data!;
        if (friendIds.isEmpty) {
          return const SizedBox.shrink();
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
                    Icons.people,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.friends,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${friendIds.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<UserModel>>(
                future: _friendsService.getFriendsData(friendIds.take(5).toList()),
                builder: (context, friendsSnapshot) {
                  if (!friendsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final friends = friendsSnapshot.data!;
                  return Column(
                    children: [
                      ...friends.map((friend) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendProfileScreen(userId: friend.uid),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                child: Text(
                                  friend.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  friend.fullName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      )),
                      if (friendIds.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${friendIds.length - 5} more',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivateIndicator(
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
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'This profile is private',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendActions(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String currentUid,
  ) {
    if (_isFriend) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.translate('remove_friend')),
                content: Text('Remove ${_user!.fullName} from friends?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.translate('cancel')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.translate('remove_friend')),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              try {
                await _friendsService.removeFriend(currentUid, widget.userId);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.person_remove),
          label: Text(l10n.translate('remove_friend')),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return FutureBuilder<bool>(
      future: _checkRequestSent(currentUid, widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requestSent = snapshot.data!;

        if (requestSent) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check),
              label: Text(l10n.translate('request_sent')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                await _friendsService.sendFriendRequest(currentUid, widget.userId);
                setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend request sent to ${_user!.fullName}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.person_add),
            label: Text(l10n.translate('add_friend')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkRequestSent(String fromUid, String toUid) async {
    final query = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUid)
        .where('toUserId', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .get();
    return query.docs.isNotEmpty;
  }
}
