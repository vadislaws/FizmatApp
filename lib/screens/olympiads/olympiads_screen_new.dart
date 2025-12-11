import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/olympiad_models.dart';
import 'package:fizmat_app/services/olympiad_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OlympiadsScreenNew extends StatefulWidget {
  const OlympiadsScreenNew({super.key});

  @override
  State<OlympiadsScreenNew> createState() => _OlympiadsScreenNewState();
}

class _OlympiadsScreenNewState extends State<OlympiadsScreenNew> {
  List<OlympiadEvent> _allEvents = [];
  List<OlympiadEvent> _filteredEvents = [];
  String? _selectedSubject;
  OlympiadEventType? _selectedType;
  bool _showFilters = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await OlympiadService.fetchEvents();
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
        _sortEventsByDate();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _sortEventsByDate() {
    _filteredEvents.sort((a, b) => a.date.compareTo(b.date));
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        bool matchesSubject = _selectedSubject == null ||
            event.subjects.contains(_selectedSubject);
        bool matchesType = _selectedType == null || event.type == _selectedType;
        return matchesSubject && matchesType;
      }).toList();
      _sortEventsByDate();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedType = null;
      _filteredEvents = _allEvents;
      _sortEventsByDate();
    });
  }

  List<String> _getAllSubjects() {
    return _allEvents
        .expand((event) => event.subjects)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('olympiads')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (_selectedSubject != null || _selectedType != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('error'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: Text(l10n.translate('retry')),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filters
                    if (_showFilters) _buildFilters(theme, l10n),

                    // Header row
                    _buildHeaderRow(theme, l10n),

                    // Event rows
                    Expanded(
                      child: _filteredEvents.isEmpty
                          ? _buildEmptyState(theme, l10n)
                          : ListView.builder(
                              itemCount: _filteredEvents.length,
                              itemBuilder: (context, index) {
                                return _buildEventRow(_filteredEvents[index], theme, l10n);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilters(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Filter
          Text(
            l10n.translate('filter_by_subject'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getAllSubjects().map((subject) {
              final isSelected = _selectedSubject == subject;
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSubject = selected ? subject : null;
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Type Filter
          Text(
            l10n.translate('filter_by_type'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OlympiadEventType.values.map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(_getTypeName(type, l10n)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              l10n.translate('date'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              l10n.translate('event_name'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.translate('type'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.translate('status'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(OlympiadEvent event, ThemeData theme, AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM d, y');
    final isUpcoming = event.date.isAfter(DateTime.now());
    final isPast = event.date.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _showEventDetails(event, theme, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPast
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(event.date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (event.location != null)
                    Text(
                      event.location!,
                      style: TextStyle(
                        fontSize: 10,
                        color: isPast
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Event name
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: event.subjects.take(2).map((subject) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Type badge
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(event.type, theme).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getTypeColor(event.type, theme),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getTypeName(event.type, l10n),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(event.type, theme),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: Center(
                child: _buildStatusBadge(event, theme, l10n, isPast),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OlympiadEvent event, ThemeData theme, AppLocalizations l10n, bool isPast) {
    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.translate('ended'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (event.isRegistrationOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Text(
          l10n.translate('open'),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Text(
        l10n.translate('closed'),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showEventDetails(OlympiadEvent event, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Date & Location
              _buildDetailRow(Icons.calendar_today, DateFormat('MMMM d, y').format(event.date), theme),
              if (event.location != null)
                _buildDetailRow(Icons.location_on, event.location!, theme),

              const SizedBox(height: 16),

              // Type & Status
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(event.type, theme).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeName(event.type, l10n),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(event.type, theme),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: event.isRegistrationOpen
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.isRegistrationOpen
                            ? l10n.translate('registration_open')
                            : l10n.translate('registration_closed'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: event.isRegistrationOpen ? Colors.green : Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Subjects
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.subjects.map((subject) {
                  return Chip(
                    label: Text(subject),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Grades
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.grades.map((grade) {
                  return Chip(
                    label: Text('${l10n.translate('grade')} $grade'),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                l10n.translate('description'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),

              // URL button
              if (event.url != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(event.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: Text(l10n.translate('visit_website')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('no_events_found'),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(OlympiadEventType type, AppLocalizations l10n) {
    final locale = l10n.locale.languageCode;
    switch (locale) {
      case 'ru':
        return type.displayNameRu;
      case 'kk':
        return type.displayNameKk;
      default:
        return type.displayName;
    }
  }

  Color _getTypeColor(OlympiadEventType type, ThemeData theme) {
    switch (type) {
      case OlympiadEventType.international:
        return Colors.deepOrange;
      case OlympiadEventType.national:
        return Colors.blue;
      case OlympiadEventType.regional:
        return Colors.green;
      case OlympiadEventType.school:
        return Colors.purple;
      case OlympiadEventType.online:
        return Colors.cyan;
      case OlympiadEventType.workshop:
        return Colors.amber;
      case OlympiadEventType.universityFair:
        return Colors.orange;
      case OlympiadEventType.exhibition:
        return Colors.brown;
      case OlympiadEventType.conference:
        return Colors.blueGrey;
      case OlympiadEventType.other:
        return Colors.grey;
    }
  }
}
