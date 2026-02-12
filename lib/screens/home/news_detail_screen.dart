import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/news_model.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteNews(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('delete_news')),
        content: Text(l10n.translate('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await NewsService().deleteNews(news.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('deleted_successfully')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.translate('error')}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final langCode = Localizations.localeOf(context).languageCode;

    // Check if user can delete this news
    final canDelete = user != null && NewsService().canDeleteNews(news, user);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('news')),
        centerTitle: true,
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteNews(context),
              tooltip: l10n.translate('delete_news'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null)
              Image.network(
                news.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getCategoryColor(news.category).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(news.category),
                          size: 16,
                          color: _getCategoryColor(news.category),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          getCategoryName(news.category, langCode),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(news.category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(news.createdAt, l10n),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.person,
                        size: 16,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.createdByName,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    news.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                  ),
                  // Links section
                  if (news.links.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.translate('links'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(news.links.length, (index) {
                      final url = news.links[index];
                      final title = index < news.linkTitles.length
                          ? news.linkTitles[index]
                          : url;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.link,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            trailing: Icon(
                              Icons.open_in_new,
                              color: theme.colorScheme.primary,
                            ),
                            onTap: () => _launchUrl(url),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(NewsCategory category) {
    switch (category) {
      case NewsCategory.general:
        return Colors.blue;
      case NewsCategory.events:
        return Colors.purple;
      case NewsCategory.academic:
        return Colors.green;
      case NewsCategory.sports:
        return Colors.orange;
      case NewsCategory.clubs:
        return Colors.teal;
      case NewsCategory.achievements:
        return Colors.amber;
      case NewsCategory.important:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(NewsCategory category) {
    switch (category) {
      case NewsCategory.general:
        return Icons.article;
      case NewsCategory.events:
        return Icons.event;
      case NewsCategory.academic:
        return Icons.school;
      case NewsCategory.sports:
        return Icons.sports;
      case NewsCategory.clubs:
        return Icons.groups;
      case NewsCategory.achievements:
        return Icons.emoji_events;
      case NewsCategory.important:
        return Icons.priority_high;
    }
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.translate('just_now');
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ${l10n.translate('ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ${l10n.translate('ago')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ${l10n.translate('ago')}';
    } else {
      return '${(difference.inDays / 7).floor()}w ${l10n.translate('ago')}';
    }
  }
}
