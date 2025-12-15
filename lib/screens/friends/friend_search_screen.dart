import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/screens/friends/friend_profile_screen.dart';
import 'package:fizmat_app/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendsService _friendsService = FriendsService();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final queryLower = query.toLowerCase();

      // Search by username
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: queryLower)
          .where('username', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      // Search by full name
      final nameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      final usersMap = <String, UserModel>{};

      for (final doc in usernameQuery.docs) {
        final user = UserModel.fromMap(doc.data());
        usersMap[user.uid] = user;
      }

      for (final doc in nameQuery.docs) {
        final user = UserModel.fromMap(doc.data());
        usersMap[user.uid] = user;
      }

      setState(() {
        _searchResults = usersMap.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('search_users')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.translate('search_users'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  _performSearch('');
                }
              },
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for friends by name or username',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 80,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              if (user.uid == currentUser.uid) {
                                return const SizedBox(); // Don't show current user
                              }
                              return _buildUserCard(context, theme, l10n, user, currentUser.uid);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
    String currentUid,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user.username != null ? '@${user.username}' : user.formattedClass,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: FutureBuilder<bool>(
          future: _checkFriendStatus(currentUid, user.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            final isFriend = snapshot.data!;

            if (isFriend) {
              return Chip(
                label: Text(
                  l10n.translate('already_friends'),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
              );
            }

            return FutureBuilder<bool>(
              future: _checkRequestSent(currentUid, user.uid),
              builder: (context, requestSnapshot) {
                if (!requestSnapshot.hasData) {
                  return const SizedBox();
                }

                final requestSent = requestSnapshot.data!;

                if (requestSent) {
                  return Chip(
                    label: Text(
                      l10n.translate('request_sent'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.person_add),
                  color: theme.colorScheme.primary,
                  onPressed: () async {
                    try {
                      await _friendsService.sendFriendRequest(currentUid, user.uid);
                      setState(() {});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Friend request sent to ${user.fullName}')),
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
                );
              },
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendProfileScreen(userId: user.uid),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkFriendStatus(String currentUid, String targetUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(targetUid)
        .get();
    return doc.exists;
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
