import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/friend_request_model.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/screens/friends/friend_profile_screen.dart';
import 'package:fizmat_app/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendsService _friendsService = FriendsService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  List<UserModel> _recommendations = [];
  bool _isLoadingRecommendations = false;
  bool _showRecommendations = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) return;

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final recommendations = await _friendsService.getFriendRecommendations(
        uid: user.uid,
        userGrade: user.classGradeNumber,
        userLetter: user.classLetter,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query, String currentUid) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
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
        if (user.uid != currentUid) {
          usersMap[user.uid] = user;
        }
      }

      for (final doc in nameQuery.docs) {
        final user = UserModel.fromMap(doc.data());
        if (user.uid != currentUid) {
          usersMap[user.uid] = user;
        }
      }

      setState(() {
        _searchResults = usersMap.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('friends')),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('friends')),
            Tab(text: l10n.translate('friend_requests')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(context, theme, l10n, user.uid),
          _buildRequestsList(context, theme, l10n, user.uid),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context, ThemeData theme, AppLocalizations l10n, String uid) {
    // If searching, show search results
    if (_searchController.text.isNotEmpty) {
      return Column(
        children: [
          _buildSearchBar(context, theme, l10n, uid),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
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
                          return _buildSearchResultCard(context, theme, l10n, _searchResults[index], uid);
                        },
                      ),
          ),
        ],
      );
    }

    // Otherwise show friends list with recommendations
    return StreamBuilder<List<String>>(
      stream: _friendsService.getFriendsList(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final friendIds = snapshot.data ?? [];

        return Column(
          children: [
            _buildSearchBar(context, theme, l10n, uid),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Recommendations section
                  if (_showRecommendations && _recommendations.isNotEmpty) ...[
                    _buildRecommendationsSection(context, theme, l10n, uid),
                    const SizedBox(height: 16),
                  ],
                  // Friends list or empty state
                  if (friendIds.isEmpty)
                    _buildEmptyFriendsState(theme, l10n)
                  else
                    FutureBuilder<List<UserModel>>(
                      future: _friendsService.getFriendsData(friendIds),
                      builder: (context, friendsSnapshot) {
                        if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final friends = friendsSnapshot.data ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                '${l10n.translate('friends')} (${friends.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            ...friends.map((friend) => _buildFriendCard(context, theme, friend, uid)),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyFriendsState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('no_friends'),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('use_search_to_find_friends'),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, ThemeData theme, AppLocalizations l10n, String uid) {
    if (_isLoadingRecommendations) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('recommended_friends'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _loadRecommendations,
              child: Text(l10n.translate('refresh')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(context, theme, l10n, _recommendations[index], uid);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    UserModel user,
    String currentUid,
  ) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendProfileScreen(userId: user.uid),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.fullName.split(' ').first,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      user.formattedClass,
                      style: TextStyle(
                        fontSize: 8,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 26,
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await _friendsService.sendFriendRequest(currentUid, user.uid);
                        setState(() {
                          _recommendations.remove(user);
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.translate('request_sent'))),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l10n.translate('error')}: $e')),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.translate('add'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, AppLocalizations l10n, String uid) {
    return Padding(
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
                    setState(() {
                      _searchController.clear();
                      _searchResults = [];
                      _isSearching = false;
                    });
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
            _performSearch(value, uid);
          } else if (value.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildSearchResultCard(
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

  Widget _buildFriendCard(BuildContext context, ThemeData theme, UserModel friend, String currentUid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
          child: friend.avatarUrl == null
              ? Text(
                  friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          friend.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          friend.username != null ? '@${friend.username}' : friend.formattedClass,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showFriendOptions(context, friend, currentUid);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendProfileScreen(userId: friend.uid),
            ),
          );
        },
      ),
    );
  }

  void _showFriendOptions(BuildContext context, UserModel friend, String currentUid) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.translate('profile_title')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendProfileScreen(userId: friend.uid),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: Text(
                  l10n.translate('remove_friend'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.translate('remove_friend')),
                      content: Text('Remove ${friend.fullName} from friends?'),
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
                      await _friendsService.removeFriend(currentUid, friend.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed ${friend.fullName} from friends')),
                        );
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, ThemeData theme, AppLocalizations l10n, String uid) {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: _friendsService.getPendingRequests(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending requests',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return _buildRequestCard(context, theme, l10n, requests[index]);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, ThemeData theme, AppLocalizations l10n, FriendRequestModel request) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(request.fromUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: ListTile(
              leading: CircleAvatar(),
              title: Text('Loading...'),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return const SizedBox();

        final fromUser = UserModel.fromMap(userData);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: fromUser.avatarUrl != null ? NetworkImage(fromUser.avatarUrl!) : null,
              child: fromUser.avatarUrl == null
                  ? Text(
                      fromUser.fullName.isNotEmpty ? fromUser.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(
              fromUser.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              fromUser.username != null ? '@${fromUser.username}' : fromUser.formattedClass,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    try {
                      await _friendsService.acceptFriendRequest(
                        request.id,
                        request.fromUserId,
                        request.toUserId,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Friend request accepted')),
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
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    try {
                      await _friendsService.declineFriendRequest(request.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request declined')),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
