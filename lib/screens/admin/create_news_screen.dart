import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/news_model.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/services/news_service.dart';
import 'package:flutter/material.dart';

class CreateNewsScreen extends StatefulWidget {
  final UserModel user;

  const CreateNewsScreen({super.key, required this.user});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final NewsService _newsService = NewsService();
  bool _isLoading = false;

  // Category selection
  NewsCategory _selectedCategory = NewsCategory.general;

  // Links management
  final List<Map<String, String>> _links = [];
  final _linkUrlController = TextEditingController();
  final _linkTitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _linkUrlController.dispose();
    _linkTitleController.dispose();
    super.dispose();
  }

  void _addLink() {
    final url = _linkUrlController.text.trim();
    final title = _linkTitleController.text.trim();

    if (url.isEmpty) return;

    setState(() {
      _links.add({
        'url': url,
        'title': title.isEmpty ? url : title,
      });
      _linkUrlController.clear();
      _linkTitleController.clear();
    });
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
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

  Widget _buildLinksSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('links'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),

        // Existing links
        if (_links.isNotEmpty) ...[
          ...List.generate(_links.length, (index) {
            final link = _links[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.link),
                title: Text(
                  link['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  link['url']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeLink(index),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // Add new link form
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextField(
                controller: _linkTitleController,
                decoration: InputDecoration(
                  labelText: l10n.translate('link_title'),
                  hintText: l10n.translate('link_title_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _linkUrlController,
                decoration: InputDecoration(
                  labelText: l10n.translate('link_url'),
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  isDense: true,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addLink,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.translate('add_link')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createNews() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Extract links and titles into separate lists
      final List<String> linkUrls = _links.map((l) => l['url']!).toList();
      final List<String> linkTitles = _links.map((l) => l['title']!).toList();

      await _newsService.createNews(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdBy: widget.user.uid,
        createdByName: widget.user.fullName,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        category: _selectedCategory,
        links: linkUrls,
        linkTitles: linkTitles,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('news_created')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('create_news')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category selection
            Text(
              l10n.translate('category'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NewsCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(getCategoryName(category, Localizations.localeOf(context).languageCode)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.translate('news_details'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.translate('title'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.translate('required_field');
                }
                return null;
              },
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: l10n.translate('content'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.translate('required_field');
                }
                return null;
              },
              maxLines: 8,
              maxLength: 1000,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: '${l10n.translate('image_url')} (${l10n.translate('optional')})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                hintText: 'https://example.com/image.jpg',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            // Links section
            _buildLinksSection(theme, l10n),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createNews,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.translate('create_news'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
