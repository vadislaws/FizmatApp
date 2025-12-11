import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fizmat_app/models/olympiad_models.dart';

/// Service for fetching olympiad events from Google Sheets
class OlympiadService {
  // Google Sheets URL: https://docs.google.com/spreadsheets/d/1_jJ_SLOoIP4engeiXVOTUJ8Hz3K2xY_si0cbD8vlA-s/edit?gid=872248261
  static const String spreadsheetId = '1_jJ_SLOoIP4engeiXVOTUJ8Hz3K2xY_si0cbD8vlA-s';
  static const String gid = '872248261';

  /// Fetch olympiad events from Google Sheets
  ///
  /// For this to work, the spreadsheet must be publicly accessible.
  /// To make it public:
  /// 1. Open the spreadsheet
  /// 2. Click "Share" button (top right)
  /// 3. Click "Change to anyone with the link"
  /// 4. Set permission to "Viewer"
  /// 5. Click "Done"
  static Future<List<OlympiadEvent>> fetchEvents() async {
    try {
      final csvUrl = 'https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=csv&gid=$gid';

      final response = await http.get(Uri.parse(csvUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        // Parse CSV data
        return _parseCSV(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Sheet is not public - return sample data
        print('Google Sheet is not publicly accessible. Using sample data.');
        return _getSampleEvents();
      } else {
        throw Exception('Failed to load olympiad data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching olympiad data: $e');
      // Return sample data on error
      return _getSampleEvents();
    }
  }

  /// Parse CSV data into OlympiadEvent objects
  ///
  /// Expected CSV format (from Google Sheets):
  /// Date, Event Name, Type, Subject(s), Grade(s), Location, Registration Status, Description, URL
  static List<OlympiadEvent> _parseCSV(String csvData) {
    final events = <OlympiadEvent>[];
    final lines = const LineSplitter().convert(csvData);

    if (lines.isEmpty) return events;

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      try {
        final cells = _parseCSVLine(line);
        if (cells.length < 8) continue; // Skip incomplete rows

        // Parse date (assuming format: MM/DD/YYYY or DD.MM.YYYY)
        final dateStr = cells[0].trim();
        DateTime? date;
        try {
          final parts = dateStr.contains('/')
              ? dateStr.split('/')
              : dateStr.split('.');
          if (parts.length == 3) {
            // Try MM/DD/YYYY format
            if (dateStr.contains('/')) {
              date = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[0]), // month
                int.parse(parts[1]), // day
              );
            } else {
              // Try DD.MM.YYYY format
              date = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          }
        } catch (e) {
          print('Error parsing date "$dateStr": $e');
          continue;
        }

        if (date == null) continue;

        // Parse event name
        final eventName = cells[1].trim();
        if (eventName.isEmpty) continue;

        // Parse type
        final typeStr = cells[2].trim().toLowerCase();
        OlympiadEventType type = OlympiadEventType.other;
        if (typeStr.contains('international') || typeStr.contains('халықаралық') || typeStr.contains('международ')) {
          type = OlympiadEventType.international;
        } else if (typeStr.contains('national') || typeStr.contains('республик') || typeStr.contains('республиканск')) {
          type = OlympiadEventType.national;
        } else if (typeStr.contains('regional') || typeStr.contains('аймақ') || typeStr.contains('регион') || typeStr.contains('облыст')) {
          type = OlympiadEventType.regional;
        } else if (typeStr.contains('school') || typeStr.contains('мектеп') || typeStr.contains('школьн')) {
          type = OlympiadEventType.school;
        } else if (typeStr.contains('online') || typeStr.contains('онлайн')) {
          type = OlympiadEventType.online;
        }

        // Parse subjects (comma-separated)
        final subjectsStr = cells[3].trim();
        final subjects = subjectsStr.isEmpty
            ? <String>[]
            : subjectsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

        // Parse grades (comma-separated numbers)
        final gradesStr = cells[4].trim();
        final grades = <int>[];
        if (gradesStr.isNotEmpty) {
          for (final gradeStr in gradesStr.split(',')) {
            final grade = int.tryParse(gradeStr.trim());
            if (grade != null) grades.add(grade);
          }
        }

        // Parse location
        final location = cells[5].trim().isEmpty ? null : cells[5].trim();

        // Parse registration status
        final registrationStr = cells[6].trim().toLowerCase();
        final isRegistrationOpen = registrationStr.contains('open') ||
                                   registrationStr.contains('ашық') ||
                                   registrationStr.contains('откр');

        // Parse description
        final description = cells[7].trim();

        // Parse URL (if exists)
        final url = cells.length > 8 && cells[8].trim().isNotEmpty
            ? cells[8].trim()
            : null;

        events.add(OlympiadEvent(
          title: eventName,
          description: description.isEmpty ? eventName : description,
          date: date,
          location: location,
          url: url,
          subjects: subjects,
          grades: grades,
          type: type,
          isRegistrationOpen: isRegistrationOpen,
        ));
      } catch (e) {
        print('Error parsing CSV line $i: $e');
        continue;
      }
    }

    return events;
  }

  /// Parse a CSV line handling quoted fields
  static List<String> _parseCSVLine(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    cells.add(buffer.toString());
    return cells;
  }

  /// Get sample olympiad events for testing/fallback
  static List<OlympiadEvent> _getSampleEvents() {
    final now = DateTime.now();

    return [
      OlympiadEvent(
        title: 'International Mathematics Olympiad (IMO)',
        description: 'The most prestigious mathematics competition for high school students worldwide.',
        date: DateTime(now.year, 7, 15),
        location: 'Tokyo, Japan',
        url: 'https://www.imo-official.org/',
        subjects: ['Mathematics'],
        grades: [9, 10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'National Physics Olympiad',
        description: 'Kazakhstan National Physics Competition for students.',
        date: DateTime(now.year, now.month, now.day + 15),
        location: 'Almaty, Kazakhstan',
        url: null,
        subjects: ['Physics'],
        grades: [10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Regional Chemistry Competition',
        description: 'Chemistry competition for students in Almaty region.',
        date: DateTime(now.year, now.month, now.day + 30),
        location: 'Almaty',
        url: null,
        subjects: ['Chemistry'],
        grades: [9, 10, 11],
        type: OlympiadEventType.regional,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'School Science Fair',
        description: 'Annual science fair showcasing student projects.',
        date: DateTime(now.year, now.month, now.day + 45),
        location: 'Fizmat School',
        url: null,
        subjects: ['Physics', 'Chemistry', 'Biology', 'Mathematics'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.school,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'International Informatics Olympiad (IOI)',
        description: 'Programming and algorithms competition for high school students.',
        date: DateTime(now.year, 8, 20),
        location: 'Budapest, Hungary',
        url: 'https://ioinformatics.org/',
        subjects: ['Informatics', 'Computer Science'],
        grades: [9, 10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'National Biology Olympiad',
        description: 'Biology competition for Kazakhstan students.',
        date: DateTime(now.year, now.month + 1, 10),
        location: 'Nur-Sultan, Kazakhstan',
        url: null,
        subjects: ['Biology'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Online Math Competition',
        description: 'Online mathematics competition open to all students.',
        date: DateTime(now.year, now.month + 2, 5),
        location: null,
        url: 'https://example.com/math-competition',
        subjects: ['Mathematics'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.online,
        isRegistrationOpen: true,
      ),
    ];
  }
}
