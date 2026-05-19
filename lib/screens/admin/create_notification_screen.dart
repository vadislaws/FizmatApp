import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/notification_model.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class CreateNotificationScreen extends StatefulWidget {
  final UserModel user;

  const CreateNotificationScreen({super.key, required this.user});

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleRu = TextEditingController();
  final _titleKk = TextEditingController();
  final _titleEn = TextEditingController();
  final _messageRu = TextEditingController();
  final _messageKk = TextEditingController();
  final _messageEn = TextEditingController();
  final _userSearchController = TextEditingController();

  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String _selectedType = 'announcement';
  NotificationTarget _targetType = NotificationTarget.all;
  int? _targetGrade;
  String? _targetLetter;
  UserModel? _targetUser;
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  final List<int> _grades = [7, 8, 9, 10, 11];
  final List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'
  ];

  @override
  void dispose() {
    _titleRu.dispose();
    _titleKk.dispose();
    _titleEn.dispose();
    _messageRu.dispose();
    _messageKk.dispose();
    _messageEn.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getNotificationTypes(AppLocalizations l10n) {
    return [
      {'value': 'announcement', 'label': l10n.translate('type_announcement'), 'icon': 'campaign'},
      {'value': 'event', 'label': l10n.translate('type_event'), 'icon': 'event'},
      {'value': 'alert', 'label': l10n.translate('type_alert'), 'icon': 'warning'},
      {'value': 'info', 'label': l10n.translate('type_info'), 'icon': 'info'},
    ];
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _notificationService.searchUsersForTarget(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _createNotification() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    if (_targetType == NotificationTarget.grade && _targetGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('select_grade'))),
      );
      return;
    }
    if (_targetType == NotificationTarget.gradeClass &&
        (_targetGrade == null || _targetLetter == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('select_class'))),
      );
      return;
    }
    if (_targetType == NotificationTarget.user && _targetUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('select_user'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notificationTypes = _getNotificationTypes(l10n);
      final selectedTypeData = notificationTypes.firstWhere(
        (t) => t['value'] == _selectedType,
        orElse: () => notificationTypes[0],
      );

      // Build translations map — only include non-empty entries
      final titles = <String, String>{
        'ru': _titleRu.text.trim(),
        if (_titleKk.text.trim().isNotEmpty) 'kk': _titleKk.text.trim(),
        if (_titleEn.text.trim().isNotEmpty) 'en': _titleEn.text.trim(),
      };
      final messages = <String, String>{
        'ru': _messageRu.text.trim(),
        if (_messageKk.text.trim().isNotEmpty) 'kk': _messageKk.text.trim(),
        if (_messageEn.text.trim().isNotEmpty) 'en': _messageEn.text.trim(),
      };

      // Fallback title/message in Russian (legacy field)
      await _notificationService.createNotification(
        title: _titleRu.text.trim(),
        message: _messageRu.text.trim(),
        titles: titles,
        messages: messages,
        createdBy: widget.user.uid,
        createdByName: widget.user.fullName,
        type: _selectedType,
        iconName: selectedTypeData['icon'],
        targetType: _targetType,
        targetGrade: _targetGrade,
        targetLetter: _targetLetter,
        targetUserId: _targetUser?.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('notification_created')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'campaign': return Icons.campaign;
      case 'event':    return Icons.event;
      case 'warning':  return Icons.warning;
      case 'info':     return Icons.info;
      default:         return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notificationTypes = _getNotificationTypes(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('create_notification')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notification type chips
            Text(
              l10n.translate('notification_type'),
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
              children: notificationTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconData(type['icon']),
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(type['label']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type['value']);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Target audience
            Text(
              l10n.translate('target_audience'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            _buildTargetSelector(theme, l10n),
            const SizedBox(height: 24),

            // Russian (required)
            _buildSectionLabel(l10n.translate('title'), theme, required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleRu,
              decoration: InputDecoration(
                hintText: 'Заголовок на русском',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                isDense: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.translate('required_field') : null,
            ),
            const SizedBox(height: 12),
            _buildSectionLabel(l10n.translate('message'), theme, required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageRu,
              decoration: InputDecoration(
                hintText: 'Текст на русском',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.translate('required_field') : null,
            ),
            const SizedBox(height: 20),

            // Optional translations
            _buildSectionLabel('Переводы (опционально)', theme),
            const SizedBox(height: 8),
            _buildOptionalLangBlock('KK', _titleKk, _messageKk, theme),
            const SizedBox(height: 12),
            _buildOptionalLangBlock('EN', _titleEn, _messageEn, theme),
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createNotification,
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
                        l10n.translate('create_notification'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text('*', style: TextStyle(color: theme.colorScheme.error, fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildOptionalLangBlock(
    String lang,
    TextEditingController titleCtrl,
    TextEditingController messageCtrl,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: titleCtrl,
            decoration: InputDecoration(
              hintText: 'Заголовок',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: messageCtrl,
            decoration: InputDecoration(
              hintText: 'Текст',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              alignLabelWithHint: true,
              isDense: true,
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.translate('target_all')),
              selected: _targetType == NotificationTarget.all,
              onSelected: (s) {
                if (s) setState(() {
                  _targetType = NotificationTarget.all;
                  _targetGrade = null;
                  _targetLetter = null;
                  _targetUser = null;
                });
              },
            ),
            ChoiceChip(
              label: Text(l10n.translate('target_grade')),
              selected: _targetType == NotificationTarget.grade,
              onSelected: (s) {
                if (s) setState(() {
                  _targetType = NotificationTarget.grade;
                  _targetLetter = null;
                  _targetUser = null;
                });
              },
            ),
            ChoiceChip(
              label: Text(l10n.translate('target_class')),
              selected: _targetType == NotificationTarget.gradeClass,
              onSelected: (s) {
                if (s) setState(() {
                  _targetType = NotificationTarget.gradeClass;
                  _targetUser = null;
                });
              },
            ),
            ChoiceChip(
              label: Text(l10n.translate('target_user')),
              selected: _targetType == NotificationTarget.user,
              onSelected: (s) {
                if (s) setState(() {
                  _targetType = NotificationTarget.user;
                  _targetGrade = null;
                  _targetLetter = null;
                });
              },
            ),
          ],
        ),

        if (_targetType == NotificationTarget.grade ||
            _targetType == NotificationTarget.gradeClass) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _targetGrade,
                  decoration: InputDecoration(
                    labelText: l10n.translate('grade'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  items: _grades.map((g) => DropdownMenuItem(
                    value: g,
                    child: Text('$g ${l10n.translate('grade_suffix')}'),
                  )).toList(),
                  onChanged: (v) => setState(() => _targetGrade = v),
                ),
              ),
              if (_targetType == NotificationTarget.gradeClass) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLetter,
                    decoration: InputDecoration(
                      labelText: l10n.translate('letter'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    items: _letters.map((l) => DropdownMenuItem(
                      value: l, child: Text(l),
                    )).toList(),
                    onChanged: (v) => setState(() => _targetLetter = v),
                  ),
                ),
              ],
            ],
          ),
        ],

        if (_targetType == NotificationTarget.user) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _userSearchController,
            decoration: InputDecoration(
              labelText: l10n.translate('search_user'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: _searchUsers,
          ),
          if (_targetUser != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(_targetUser!.fullName[0])),
                title: Text(_targetUser!.fullName),
                subtitle: Text(_targetUser!.formattedClass),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _targetUser = null;
                    _userSearchController.clear();
                  }),
                ),
              ),
            ),
          ],
          if (_searchResults.isNotEmpty && _targetUser == null) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (_, i) {
                  final u = _searchResults[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(u.fullName[0])),
                    title: Text(u.fullName),
                    subtitle: Text(u.formattedClass),
                    onTap: () => setState(() {
                      _targetUser = u;
                      _searchResults = [];
                      _userSearchController.text = u.fullName;
                    }),
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }
}
