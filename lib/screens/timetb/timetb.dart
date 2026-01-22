import 'package:fizmat_app/data/schedule_data.dart';
import 'package:fizmat_app/data/subject_translations.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/schedule_models.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FizTimetb extends StatefulWidget {
  const FizTimetb({super.key});

  @override
  State<FizTimetb> createState() => _FizTimetbState();
}

class _FizTimetbState extends State<FizTimetb> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedGradeNumber;
  String? _selectedGradeLetter;
  ClassSchedule? _currentSchedule;

  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<int> _grades = [7, 8, 9, 10, 11];
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Set current day
    final now = DateTime.now();
    if (now.weekday >= 1 && now.weekday <= 5) {
      _tabController.index = now.weekday - 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load user's class schedule by default
    if (_selectedGradeNumber == null && _selectedGradeLetter == null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;

      if (user != null && user.classGradeNumber != null && user.classLetter != null) {
        _selectedGradeNumber = user.classGradeNumber;
        _selectedGradeLetter = user.classLetter;
        _loadSchedule();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSchedule() {
    if (_selectedGradeNumber == null || _selectedGradeLetter == null) return;

    setState(() {
      _currentSchedule = ScheduleData.getScheduleForClass(_selectedGradeNumber!, _selectedGradeLetter!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('schedules')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _weekDays.map((day) {
            return Tab(text: l10n.translate(day.toLowerCase()));
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Class Selector
          _buildClassSelector(theme, l10n),
          const Divider(height: 1),
          // Schedule Content
          Expanded(
            child: _currentSchedule == null
                ? _buildEmptyState(theme, l10n)
                : TabBarView(
                    controller: _tabController,
                    children: _weekDays.map((day) {
                      final daySchedule = _currentSchedule!.weekSchedule[day];
                      return daySchedule == null
                          ? _buildNoLessonsState(theme, l10n)
                          : _buildDaySchedule(theme, l10n, daySchedule);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.translate('select_class'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Grade Number Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedGradeNumber,
                      hint: Text(l10n.translate('grade_number')),
                      isExpanded: true,
                      items: _grades.map((grade) {
                        return DropdownMenuItem<int>(
                          value: grade,
                          child: Text('$grade'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGradeNumber = value;
                          if (_selectedGradeLetter != null) {
                            _loadSchedule();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Letter Dropdown
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGradeLetter,
                      hint: Text(l10n.translate('letter')),
                      isExpanded: true,
                      items: _letters.map((letter) {
                        return DropdownMenuItem<String>(
                          value: letter,
                          child: Text(letter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGradeLetter = value;
                          if (_selectedGradeNumber != null) {
                            _loadSchedule();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate('select_class_to_view_schedule'),
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoLessonsState(ThemeData theme, AppLocalizations l10n) {
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
            l10n.translate('no_lessons_today'),
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(ThemeData theme, AppLocalizations l10n, DaySchedule daySchedule) {
    final slots = daySchedule.getAllSlots();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];

        if (slot is Lesson) {
          return _buildLessonCard(theme, l10n, slot);
        } else if (slot is TimeSlot && slot.isBreak) {
          return _buildBreakCard(theme, l10n, slot);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLessonCard(ThemeData theme, AppLocalizations l10n, Lesson lesson) {
    // Translate subject name based on current language
    final languageCode = Localizations.localeOf(context).languageCode;
    final translatedSubject = SubjectTranslations.translate(lesson.subject, languageCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson number badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${lesson.lessonNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Lesson details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translatedSubject,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.timeSlot.startTime} - ${lesson.timeSlot.endTime}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (lesson.room != null && lesson.room!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.door_front_door,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.translate('room')}: ${lesson.room}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakCard(ThemeData theme, AppLocalizations l10n, TimeSlot breakSlot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.free_breakfast,
              color: theme.colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.translate('break')} ${breakSlot.breakNumber ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakSlot.startTime} - ${breakSlot.endTime} (${breakSlot.duration})',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}