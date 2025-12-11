import 'dart:convert';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FizBirthday extends StatefulWidget {
  const FizBirthday({super.key});

  @override
  State<FizBirthday> createState() => _FizBirthdayState();
}

class _FizBirthdayState extends State<FizBirthday> {
  List<BirthdayPerson> _todayBirthdays = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBirthdays();
  }

  Future<void> _fetchBirthdays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('https://raw.githubusercontent.com/vadislaws/FizmatApp/main/data/student-2024-2025.csv');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load birthday data');
      }

      final List<BirthdayPerson> birthdayList = [];
      final now = DateTime.now();
      final todayString = DateFormat('MM-dd').format(now);

      // Split by newline to get rows
      final lines = const LineSplitter().convert(response.body);

      for (var line in lines) {
        if (line.trim().isEmpty) continue;

        final parts = line.split(',');
        if (parts.length < 3) continue;

        final date = parts[0].trim();
        final encodedName = parts[1].trim();
        final className = parts[2].trim();

        // Filter for Today
        if (date == todayString) {
          try {
            // Decode Base64 -> UTF8
            final decodedName = utf8.decode(base64.decode(encodedName));

            // Add +1 to class number (e.g., 10E -> 11E)
            final updatedClass = _incrementClassName(className);

            birthdayList.add(BirthdayPerson(
              name: decodedName,
              grade: updatedClass,
              date: now,
            ));
          } catch (e) {
            print('Error decoding name for line: $line - $e');
          }
        }
      }

      setState(() {
        _todayBirthdays = birthdayList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _incrementClassName(String className) {
    // Extract number and letter from class name (e.g., "10E" -> 10, "E")
    final regex = RegExp(r'(\d+)([A-Za-z]?)');
    final match = regex.firstMatch(className);

    if (match != null) {
      final number = int.parse(match.group(1)!);
      final letter = match.group(2) ?? '';
      return '${number + 1}$letter';
    }

    return className; // Return original if pattern doesn't match
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('birthdays')),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchBirthdays,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
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
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchBirthdays,
                          child: Text(l10n.translate('retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: _todayBirthdays.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              ..._todayBirthdays.map((person) => _buildBirthdayCard(person, theme, true)),
                            ],
                          ),
                        ),
                ),
    );
  }

  Widget _buildBirthdayCard(BirthdayPerson person, ThemeData theme, bool isToday) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
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
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
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

              // Stars icon
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
