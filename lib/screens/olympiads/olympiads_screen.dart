import 'package:fizmat_app/data/olympiad_data.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/olympiad_models.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class OlympiadsScreen extends StatefulWidget {
  const OlympiadsScreen({super.key});

  @override
  State<OlympiadsScreen> createState() => _OlympiadsScreenState();
}

class _OlympiadsScreenState extends State<OlympiadsScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<OlympiadEvent> _allEvents = OlympiadData.getAllEvents();
  List<OlympiadEvent> _filteredEvents = [];

  // Filter state
  String? _selectedSubject;
  OlympiadEventType? _selectedType;
  DateTimeRange? _selectedDateRange;
  OlympiadEvent? _selectedEvent; // For single event selection

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _filteredEvents = _allEvents;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('olympiads')),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: l10n.translate('filter'),
          ),
          if (_hasActiveFilters())
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllFilters,
              tooltip: l10n.translate('clear_filters'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          if (_showFilters) _buildFiltersSection(theme, l10n),

          // Calendar
          _buildCalendar(theme, l10n),

          const Divider(height: 1),

          // Events list header
          _buildEventsHeader(theme, l10n),

          // Events list
          Expanded(
            child: _buildEventsList(theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
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
            children: [
              ..._getAllSubjects().map((subject) {
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
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                );
              }),
            ],
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
            children: [
              ...OlympiadEventType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(_getEventTypeName(l10n, type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                      _applyFilters();
                    });
                  },
                  backgroundColor: theme.cardColor,
                  selectedColor: Color(int.parse(_getColorForType(type).replaceFirst('#', '0xFF')))
                      .withValues(alpha: 0.3),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range Filter
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange == null
                        ? l10n.translate('select_date_range')
                        : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              if (_selectedDateRange != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                      _applyFilters();
                    });
                  },
                  tooltip: l10n.translate('clear'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2025, 1, 1),
        lastDay: DateTime(2027, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          final events = _getEventsForDay(day);
          return events.isNotEmpty ? ['•'] : [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;

            final dayEvents = _getEventsForDay(date);
            if (dayEvents.isEmpty) return null;

            // Show up to 3 colored dots for different event types
            final uniqueTypes = dayEvents.map((e) => e.type).toSet().take(3).toList();

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: uniqueTypes.map((type) {
                  final color = Color(int.parse(_getColorForType(type).replaceFirst('#', '0xFF')));
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedEvent = null; // Clear single event selection
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.red.shade300),
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventsHeader(ThemeData theme, AppLocalizations l10n) {
    final eventsCount = _getEventsForSelectedDay().length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.cardColor,
      child: Row(
        children: [
          Icon(Icons.event, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            _selectedEvent != null
                ? _selectedEvent!.title
                : '${l10n.translate('events_on')} ${_formatDate(_selectedDay)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (eventsCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$eventsCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ThemeData theme, AppLocalizations l10n) {
    final eventsToShow = _selectedEvent != null
        ? [_selectedEvent!]
        : _getEventsForSelectedDay();

    if (eventsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('no_events_on_this_day'),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all),
                label: Text(l10n.translate('clear_filters')),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventsToShow.length,
      itemBuilder: (context, index) {
        final event = eventsToShow[index];
        return _buildEventCard(theme, l10n, event);
      },
    );
  }

  Widget _buildEventCard(ThemeData theme, AppLocalizations l10n, OlympiadEvent event) {
    final Color eventColor = Color(int.parse(event.colorHex.replaceFirst('#', '0xFF')));
    final isSelected = _selectedEvent == event;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? eventColor : eventColor.withValues(alpha: 0.5),
          width: isSelected ? 3 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(context, theme, l10n, event),
        onLongPress: () {
          setState(() {
            _selectedEvent = event == _selectedEvent ? null : event;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event type badge and registration status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: eventColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getEventTypeName(l10n, event.type),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: eventColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (event.isRegistrationOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.how_to_reg, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            l10n.translate('registration_open'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () => _showEventDetails(context, theme, l10n, event),
                    tooltip: l10n.translate('details'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Event title
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Date and location
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(event.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location ?? l10n.translate('location_tba'),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (event.subjects.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.subjects.take(3).map((subject) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, ThemeData theme, AppLocalizations l10n, OlympiadEvent event) {
    final Color eventColor = Color(int.parse(event.colorHex.replaceFirst('#', '0xFF')));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: eventColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getEventTypeName(l10n, event.type),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: eventColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (event.isRegistrationOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.how_to_reg, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.translate('registration_open'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Date
                    _buildDetailRow(
                      theme,
                      l10n,
                      Icons.calendar_today,
                      l10n.translate('date'),
                      _formatDate(event.date),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    _buildDetailRow(
                      theme,
                      l10n,
                      Icons.location_on,
                      l10n.translate('location'),
                      event.location ?? l10n.translate('location_tba'),
                    ),
                    const SizedBox(height: 12),
                    // Grades
                    _buildDetailRow(
                      theme,
                      l10n,
                      Icons.school,
                      l10n.translate('grades'),
                      event.grades.isEmpty
                          ? l10n.translate('all_grades')
                          : event.grades.join(', '),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    Text(
                      l10n.translate('description'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                    if (event.subjects.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.translate('subjects'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: event.subjects.map((subject) {
                          return Chip(
                            label: Text(subject),
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action buttons
                    if (event.url != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL(event.url!),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.translate('open_website')),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, AppLocalizations l10n, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  List<OlympiadEvent> _getEventsForDay(DateTime day) {
    return _filteredEvents.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  List<OlympiadEvent> _getEventsForSelectedDay() {
    return _getEventsForDay(_selectedDay);
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        bool matchesSubject = _selectedSubject == null || event.isForSubject(_selectedSubject!);
        bool matchesType = _selectedType == null || event.type == _selectedType;
        bool matchesDateRange = _selectedDateRange == null ||
            (event.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                event.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

        return matchesSubject && matchesType && matchesDateRange;
      }).toList();
    });
  }

  bool _hasActiveFilters() {
    return _selectedSubject != null ||
           _selectedType != null ||
           _selectedDateRange != null ||
           _selectedEvent != null;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedType = null;
      _selectedDateRange = null;
      _selectedEvent = null;
      _filteredEvents = _allEvents;
    });
  }

  List<String> _getAllSubjects() {
    final subjects = <String>{};
    for (final event in _allEvents) {
      subjects.addAll(event.subjects);
    }
    final sortedSubjects = subjects.toList()..sort();
    return sortedSubjects;
  }

  String _getEventTypeName(AppLocalizations l10n, OlympiadEventType type) {
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

  String _getColorForType(OlympiadEventType type) {
    // Temporary event to get color
    final tempEvent = OlympiadEvent(
      title: '',
      description: '',
      date: DateTime.now(),
      subjects: [],
      grades: [],
      type: type,
    );
    return tempEvent.colorHex;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
