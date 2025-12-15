import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/friend_request_model.dart';
import 'package:fizmat_app/models/news_model.dart';
import 'package:fizmat_app/models/notification_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/screens/home/news_detail_screen.dart';
import 'package:fizmat_app/services/friends_service.dart';
import 'package:fizmat_app/services/news_service.dart';
import 'package:fizmat_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FizHome extends StatefulWidget {
  const FizHome({super.key});

  @override
  State<FizHome> createState() => _FizHomeState();
}

class _FizHomeState extends State<FizHome> {
  @override
  void initState() {
    super.initState();
    // Clean up notifications older than 30 days
    NotificationService().cleanupOldNotifications().catchError((e) {
      debugPrint('Error cleaning up old notifications: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildWelcomeSection(context, theme, l10n, user?.fullName),
                const SizedBox(height: 32),
                _buildSectionTitle(context, theme, l10n.translate('notifications'), Icons.notifications),
                const SizedBox(height: 16),
                _buildNotificationsList(context, theme, l10n, user?.uid),
                const SizedBox(height: 32),
                _buildSectionTitle(context, theme, l10n.translate('news'), Icons.article),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          _buildNewsList(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String? userName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(l10n),
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userName ?? l10n.translate('welcome'),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.translate('good_morning');
    } else if (hour < 18) {
      return l10n.translate('good_afternoon');
    } else {
      return l10n.translate('good_evening');
    }
  }

  Widget _buildSectionTitle(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String? userId,
  ) {
    if (userId == null) {
      return const SizedBox();
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().getAllNotifications(),
      builder: (context, notificationSnapshot) {
        return StreamBuilder<List<FriendRequestModel>>(
          stream: FriendsService().getPendingRequests(userId),
          builder: (context, friendRequestSnapshot) {
            final List<Widget> notificationWidgets = [];

            // Add friend requests first
            if (friendRequestSnapshot.hasData && friendRequestSnapshot.data!.isNotEmpty) {
              for (final request in friendRequestSnapshot.data!) {
                notificationWidgets.add(
                  FutureBuilder<String>(
                    future: _getSenderName(request.fromUserId),
                    builder: (context, senderSnapshot) {
                      final senderName = senderSnapshot.data ?? 'Someone';
                      return _buildNotificationCard(
                        context,
                        theme,
                        title: l10n.translate('friend_requests'),
                        subtitle: '$senderName has sent you an invite to be friends',
                        time: _getTimeAgo(request.createdAt, l10n),
                        icon: Icons.person_add,
                        color: Colors.purple,
                        isRead: false,
                        onTap: () {
                          Navigator.pushNamed(context, '/friends');
                        },
                      );
                    },
                  ),
                );
              }
            }

            // Add admin notifications
            if (notificationSnapshot.hasData && notificationSnapshot.data!.isNotEmpty) {
              for (final notification in notificationSnapshot.data!) {
                notificationWidgets.add(
                  _buildNotificationCard(
                    context,
                    theme,
                    title: notification.title,
                    subtitle: notification.message,
                    time: _getTimeAgo(notification.createdAt, l10n),
                    icon: _getIconFromName(notification.iconName),
                    color: _getColorFromType(notification.type),
                    isRead: false,
                  ),
                );
              }
            }

            if (notificationWidgets.isEmpty) {
              return _buildEmptyState(context, theme, l10n, l10n.translate('no_notifications'));
            }

            // Show up to 10 notifications on home screen
            final displayNotifications = notificationWidgets.take(10).toList();
            final hasMore = notificationWidgets.length > 10;

            return Column(
              children: [
                ...displayNotifications,
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllNotificationsScreen(userId: userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: Text(l10n.translate('show_all')),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'campaign':
        return Icons.campaign;
      case 'event':
        return Icons.event;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromType(String type) {
    switch (type) {
      case 'event':
        return Colors.blue;
      case 'alert':
        return Colors.red;
      case 'info':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ${l10n.translate('ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ${l10n.translate('ago')}';
    } else {
      return '${difference.inDays}d ${l10n.translate('ago')}';
    }
  }

  Future<String> _getSenderName(String userId) async {
    try {
      final user = await FriendsService().getUserById(userId);
      return user?.fullName ?? 'Someone';
    } catch (e) {
      return 'Someone';
    }
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isRead,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return StreamBuilder<List<NewsModel>>(
      stream: NewsService().getAllNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final newsList = snapshot.data ?? [];

        if (newsList.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(context, theme, l10n, l10n.translate('no_news')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildNewsCard(context, theme, l10n, newsList[index]);
              },
              childCount: newsList.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    NewsModel news,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailScreen(news: news),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(news.createdAt, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'By ${news.createdByName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AllNotificationsScreen extends StatelessWidget {
  final String userId;

  const AllNotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('notifications')),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService().getAllNotifications(),
        builder: (context, notificationSnapshot) {
          return StreamBuilder<List<FriendRequestModel>>(
            stream: FriendsService().getPendingRequests(userId),
            builder: (context, friendRequestSnapshot) {
              final List<Widget> notificationWidgets = [];

              // Add friend requests
              if (friendRequestSnapshot.hasData) {
                for (final request in friendRequestSnapshot.data!) {
                  notificationWidgets.add(
                    FutureBuilder<String>(
                      future: _getSenderName(request.fromUserId),
                      builder: (context, senderSnapshot) {
                        final senderName = senderSnapshot.data ?? 'Someone';
                        return _buildNotificationCard(
                          context,
                          theme,
                          l10n,
                          title: l10n.translate('friend_requests'),
                          subtitle: '$senderName has sent you an invite to be friends',
                          time: _getTimeAgo(request.createdAt, l10n),
                          icon: Icons.person_add,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, '/friends');
                          },
                        );
                      },
                    ),
                  );
                }
              }

              // Add admin notifications
              if (notificationSnapshot.hasData) {
                for (final notification in notificationSnapshot.data!) {
                  notificationWidgets.add(
                    _buildNotificationCard(
                      context,
                      theme,
                      l10n,
                      title: notification.title,
                      subtitle: notification.message,
                      time: _getTimeAgo(notification.createdAt, l10n),
                      icon: _getIconFromName(notification.iconName),
                      color: _getColorFromType(notification.type),
                    ),
                  );
                }
              }

              if (notificationWidgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('no_notifications'),
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
                itemCount: notificationWidgets.length,
                itemBuilder: (context, index) => notificationWidgets[index],
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'campaign':
        return Icons.campaign;
      case 'event':
        return Icons.event;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromType(String type) {
    switch (type) {
      case 'event':
        return Colors.blue;
      case 'alert':
        return Colors.red;
      case 'info':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ${l10n.translate('ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ${l10n.translate('ago')}';
    } else {
      return '${difference.inDays}d ${l10n.translate('ago')}';
    }
  }

  Future<String> _getSenderName(String userId) async {
    try {
      final user = await FriendsService().getUserById(userId);
      return user?.fullName ?? 'Someone';
    } catch (e) {
      return 'Someone';
    }
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
