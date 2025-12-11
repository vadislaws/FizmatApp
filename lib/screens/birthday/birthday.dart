import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FizBirthday extends StatefulWidget {
  const FizBirthday({super.key});

  @override
  State<FizBirthday> createState() => _FizBirthdayState();
}

class _FizBirthdayState extends State<FizBirthday> {
  final List<BirthdayPerson> _birthdays = [
    // Sample data - replace with real Firebase/API data
    BirthdayPerson(name: 'Student 1', grade: '10-A', date: DateTime.now()),
    BirthdayPerson(name: 'Student 2', grade: '9-B', date: DateTime.now()),
    BirthdayPerson(name: 'Student 3', grade: '11-C', date: DateTime.now().add(const Duration(days: 1))),
    BirthdayPerson(name: 'Student 4', grade: '8-A', date: DateTime.now().add(const Duration(days: 2))),
    BirthdayPerson(name: 'Student 5', grade: '10-B', date: DateTime.now().add(const Duration(days: 3))),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final today = DateTime.now();
    final todayBirthdays = _birthdays.where((b) =>
      b.date.day == today.day &&
      b.date.month == today.month &&
      b.date.year == today.year
    ).toList();

    final upcomingBirthdays = _birthdays.where((b) =>
      b.date.isAfter(today) &&
      b.date.isBefore(today.add(Duration(days: 7)))
    ).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('birthdays')),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Birthdays
              if (todayBirthdays.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.cake,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.translate('today_birthdays'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...todayBirthdays.map((person) => _buildBirthdayCard(person, theme, true)),
                const SizedBox(height: 32),
              ],

              // Upcoming Birthdays
              if (upcomingBirthdays.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.translate('upcoming_birthdays'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...upcomingBirthdays.map((person) => _buildBirthdayCard(person, theme, false)),
              ],

              // Empty state
              if (todayBirthdays.isEmpty && upcomingBirthdays.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 80,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('no_upcoming_birthdays'),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayCard(BirthdayPerson person, ThemeData theme, bool isToday) {
    final dateFormat = DateFormat('MMM d');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isToday ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
          ? BorderSide(color: theme.colorScheme.primary, width: 2)
          : BorderSide.none,
      ),
      child: Container(
        decoration: isToday ? BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isToday
                      ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                      : [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isToday ? Icons.celebration : Icons.person,
                  color: isToday ? Colors.white : theme.colorScheme.onPrimaryContainer,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          person.grade,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Date badge
              if (!isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dateFormat.format(person.date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),

              if (isToday)
                Icon(
                  Icons.stars,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BirthdayPerson {
  final String name;
  final String grade;
  final DateTime date;

  BirthdayPerson({
    required this.name,
    required this.grade,
    required this.date,
  });
}
