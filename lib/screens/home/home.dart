import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FizHome extends StatefulWidget {
  const FizHome({super.key});

  @override
  State<FizHome> createState() => _FizHomeState();
}

class _FizHomeState extends State<FizHome> {
  final ScrollController _scrollController = ScrollController();
  final List<_NewsItem> _newsItems = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadMoreNews();
      }
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final l10n = AppLocalizations.of(context);
    final newItems = List.generate(5, (index) {
      final itemNumber = (_currentPage - 1) * 5 + index + 1;
      return _NewsItem(
        title: '${l10n.translate('news_example_1')} #$itemNumber',
        description: '${l10n.translate('news_example_1_desc')} Page $_currentPage',
        date: '${l10n.translate('today')} • ${10 + index}:30',
      );
    });

    setState(() {
      _newsItems.addAll(newItems);
      _currentPage++;
      _isLoadingMore = false;
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
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildWelcomeSection(context, theme, l10n, user?.fullName),
                const SizedBox(height: 32),
                _buildSectionTitle(context, theme, l10n, l10n.translate('notifications'), Icons.notifications),
                const SizedBox(height: 16),
                _buildNotificationsList(context, theme, l10n),
                const SizedBox(height: 32),
                _buildSectionTitle(context, theme, l10n, l10n.translate('news'), Icons.article),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _newsItems.length) {
                    return _buildNewsCard(context, theme, _newsItems[index]);
                  } else {
                    return _isLoadingMore
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          )
                        : const SizedBox.shrink();
                  }
                },
                childCount: _newsItems.length + 1,
              ),
            ),
          ),
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
    AppLocalizations l10n,
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
  ) {
    // Placeholder notifications - replace with real data later
    final allNotifications = [
      _NotificationItem(
        title: l10n.translate('notification_example_1'),
        subtitle: l10n.translate('notification_example_1_desc'),
        time: '2h ${l10n.translate('ago')}',
        icon: Icons.event,
        color: Colors.blue,
        isRead: false,
      ),
      _NotificationItem(
        title: l10n.translate('notification_example_2'),
        subtitle: l10n.translate('notification_example_2_desc'),
        time: '5h ${l10n.translate('ago')}',
        icon: Icons.assignment,
        color: Colors.orange,
        isRead: false,
      ),
      _NotificationItem(
        title: l10n.translate('notification_example_3'),
        subtitle: l10n.translate('notification_example_3_desc'),
        time: '1d ${l10n.translate('ago')}',
        icon: Icons.star,
        color: Colors.green,
        isRead: true,
      ),
      _NotificationItem(
        title: 'Older notification 1',
        subtitle: 'This is an older notification',
        time: '2d ${l10n.translate('ago')}',
        icon: Icons.info,
        color: Colors.purple,
        isRead: true,
      ),
      _NotificationItem(
        title: 'Older notification 2',
        subtitle: 'Another older notification',
        time: '3d ${l10n.translate('ago')}',
        icon: Icons.notifications_active,
        color: Colors.teal,
        isRead: true,
      ),
    ];

    if (allNotifications.isEmpty) {
      return _buildEmptyState(context, theme, l10n, l10n.translate('no_notifications'));
    }

    final displayNotifications = allNotifications.take(3).toList();

    return Column(
      children: [
        ...displayNotifications.map((notification) {
          return _buildNotificationCard(context, theme, notification);
        }),
        if (allNotifications.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllNotificationsScreen(notifications: allNotifications),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: Text(l10n.translate('view_all_notifications')),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ThemeData theme,
    _NotificationItem notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Handle notification tap
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
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
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.time,
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

  Widget _buildNewsCard(
    BuildContext context,
    ThemeData theme,
    _NewsItem newsItem,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Handle news tap
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newsItem.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                newsItem.description,
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
                    newsItem.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class _NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}

class _NewsItem {
  final String title;
  final String description;
  final String date;

  _NewsItem({
    required this.title,
    required this.description,
    required this.date,
  });
}

class AllNotificationsScreen extends StatelessWidget {
  final List<_NotificationItem> notifications;

  const AllNotificationsScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('notifications')),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: notification.isRead ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Handle notification tap
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notification.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.color,
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
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
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
                            notification.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.time,
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
        },
      ),
    );
  }
}
