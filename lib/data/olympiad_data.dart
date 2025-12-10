import 'package:fizmat_app/models/olympiad_models.dart';

/// Olympiad events data provider
///
/// NOTE: This contains sample data. Replace with real data from your Google Sheets/Docs.
/// Data sources mentioned by user:
/// - https://docs.google.com/spreadsheets/d/1_jJ_SLOoIP4engeiXVOTUJ8Hz3K2xY_si0cbD8vlA-s/edit?gid=872248261#gid=872248261
/// - https://docs.google.com/document/d/1W08eO_ctWnNP3CY4eTFjGp-Ln-FEO6AlCu0uzYiUPpE/edit?usp=sharing
class OlympiadData {
  /// Get all olympiad events
  ///
  /// TODO: Replace this with real data from Google Sheets/Docs
  static List<OlympiadEvent> getAllEvents() {
    return [
      // December 2025 events
      OlympiadEvent(
        title: 'International Mathematical Olympiad - Qualification Round',
        description: 'First round of IMO qualification. Solve challenging math problems to advance to the next stage.',
        date: DateTime(2025, 12, 15),
        location: 'Online',
        subjects: ['Mathematics'],
        grades: [9, 10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'National Physics Competition',
        description: 'Annual physics competition for high school students. Topics include mechanics, electromagnetism, and thermodynamics.',
        date: DateTime(2025, 12, 20),
        location: 'Almaty',
        subjects: ['Physics'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Chemistry Workshop - Laboratory Techniques',
        description: 'Hands-on workshop covering essential laboratory techniques and safety procedures.',
        date: DateTime(2025, 12, 22),
        location: 'School Laboratory',
        subjects: ['Chemistry'],
        grades: [8, 9, 10, 11],
        type: OlympiadEventType.workshop,
        isRegistrationOpen: true,
      ),

      // January 2026 events
      OlympiadEvent(
        title: 'Regional Programming Contest',
        description: 'Compete in algorithmic problem solving and coding challenges. Languages: C++, Java, Python.',
        date: DateTime(2026, 1, 10),
        location: 'Nur-Sultan',
        subjects: ['Computer Science'],
        grades: [9, 10, 11],
        type: OlympiadEventType.regional,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'School Mathematics Olympiad',
        description: 'Internal school mathematics olympiad for all grades. Winners advance to city-level competition.',
        date: DateTime(2026, 1, 15),
        location: 'School Auditorium',
        subjects: ['Mathematics'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.school,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Online English Language Competition',
        description: 'Test your English proficiency through reading, writing, and listening comprehension tasks.',
        date: DateTime(2026, 1, 20),
        location: 'Online',
        url: 'https://example.com/english-olympiad',
        subjects: ['English'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.online,
        isRegistrationOpen: true,
      ),

      // February 2026 events
      OlympiadEvent(
        title: 'International Physics Olympiad - First Round',
        description: 'First theoretical round of IPhO. Covers mechanics, thermodynamics, electricity, and modern physics.',
        date: DateTime(2026, 2, 5),
        location: 'Online',
        subjects: ['Physics'],
        grades: [10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'National Biology Olympiad',
        description: 'Comprehensive biology competition covering botany, zoology, genetics, and ecology.',
        date: DateTime(2026, 2, 12),
        location: 'Shymkent',
        subjects: ['Biology'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Chemistry Olympiad - Theory Round',
        description: 'Theoretical chemistry olympiad covering organic, inorganic, and physical chemistry.',
        date: DateTime(2026, 2, 18),
        location: 'Almaty',
        subjects: ['Chemistry'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Regional Geography Competition',
        description: 'Test your knowledge of world geography, climatology, and geopolitics.',
        date: DateTime(2026, 2, 25),
        location: 'Karaganda',
        subjects: ['Geography'],
        grades: [8, 9, 10, 11],
        type: OlympiadEventType.regional,
        isRegistrationOpen: false,
      ),

      // March 2026 events
      OlympiadEvent(
        title: 'International Chemistry Olympiad - Qualification',
        description: 'Qualification round for IChO. Solve complex chemistry problems to represent your country.',
        date: DateTime(2026, 3, 8),
        location: 'Online',
        subjects: ['Chemistry'],
        grades: [10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'Mathematics Workshop - Number Theory',
        description: 'Deep dive into number theory concepts including prime numbers, modular arithmetic, and Diophantine equations.',
        date: DateTime(2026, 3, 12),
        location: 'School',
        subjects: ['Mathematics'],
        grades: [9, 10, 11],
        type: OlympiadEventType.workshop,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'National Informatics Olympiad',
        description: 'National level programming competition. Algorithmic problem solving in competitive environment.',
        date: DateTime(2026, 3, 20),
        location: 'Nur-Sultan',
        subjects: ['Computer Science'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'School Science Fair',
        description: 'Showcase your science projects! All subjects welcome: physics, chemistry, biology, computer science.',
        date: DateTime(2026, 3, 25),
        location: 'School',
        subjects: ['Physics', 'Chemistry', 'Biology', 'Computer Science'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.school,
        isRegistrationOpen: true,
      ),

      // April 2026 events
      OlympiadEvent(
        title: 'International Linguistics Olympiad - First Round',
        description: 'Solve fascinating linguistic puzzles from languages around the world.',
        date: DateTime(2026, 4, 10),
        location: 'Online',
        subjects: ['Languages'],
        grades: [9, 10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'Regional Literature Competition',
        description: 'Creative writing, poetry, and literary analysis competition.',
        date: DateTime(2026, 4, 15),
        location: 'Almaty',
        subjects: ['Literature'],
        grades: [8, 9, 10, 11],
        type: OlympiadEventType.regional,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Physics Workshop - Experimental Methods',
        description: 'Learn experimental physics techniques including measurement, error analysis, and data interpretation.',
        date: DateTime(2026, 4, 22),
        location: 'School Laboratory',
        subjects: ['Physics'],
        grades: [9, 10, 11],
        type: OlympiadEventType.workshop,
        isRegistrationOpen: true,
      ),

      // May 2026 events
      OlympiadEvent(
        title: 'Online Mathematics Competition - Spring Edition',
        description: 'Spring mathematics competition with problems ranging from algebra to combinatorics.',
        date: DateTime(2026, 5, 5),
        location: 'Online',
        url: 'https://example.com/math-spring',
        subjects: ['Mathematics'],
        grades: [7, 8, 9, 10, 11],
        type: OlympiadEventType.online,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'National History Olympiad',
        description: 'Comprehensive history competition covering ancient, medieval, and modern history.',
        date: DateTime(2026, 5, 12),
        location: 'Almaty',
        subjects: ['History'],
        grades: [9, 10, 11],
        type: OlympiadEventType.national,
        isRegistrationOpen: false,
      ),
      OlympiadEvent(
        title: 'International Biology Olympiad - Qualification',
        description: 'Theoretical and practical rounds for IBO qualification. Topics include cell biology, genetics, and ecology.',
        date: DateTime(2026, 5, 20),
        location: 'Almaty',
        subjects: ['Biology'],
        grades: [10, 11],
        type: OlympiadEventType.international,
        isRegistrationOpen: false,
      ),

      // University Fairs and Other Events
      OlympiadEvent(
        title: 'Kazakhstan University Fair 2026',
        description: 'Meet representatives from top universities in Kazakhstan. Learn about programs, admission requirements, and scholarships.',
        date: DateTime(2026, 1, 25),
        location: 'Almaty Convention Center',
        url: 'https://example.com/university-fair',
        subjects: [],
        grades: [10, 11],
        type: OlympiadEventType.universityFair,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'International University Fair - Study Abroad',
        description: 'Explore opportunities to study at international universities. Representatives from USA, UK, Europe, and Asia.',
        date: DateTime(2026, 3, 15),
        location: 'Nur-Sultan Expo Center',
        url: 'https://example.com/intl-university-fair',
        subjects: [],
        grades: [10, 11],
        type: OlympiadEventType.universityFair,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'STEM Education Conference',
        description: 'Annual conference bringing together educators, students, and industry professionals to discuss STEM education innovations.',
        date: DateTime(2026, 2, 28),
        location: 'Almaty',
        subjects: ['Mathematics', 'Physics', 'Chemistry', 'Computer Science'],
        grades: [9, 10, 11],
        type: OlympiadEventType.conference,
        isRegistrationOpen: true,
      ),
      OlympiadEvent(
        title: 'Student Science Exhibition',
        description: 'Showcase your scientific research and innovative projects. Open to all students with completed research work.',
        date: DateTime(2026, 4, 5),
        location: 'National Science Museum',
        subjects: ['Physics', 'Chemistry', 'Biology', 'Computer Science'],
        grades: [8, 9, 10, 11],
        type: OlympiadEventType.exhibition,
        isRegistrationOpen: true,
      ),
    ];
  }

  /// Get events for a specific date
  static List<OlympiadEvent> getEventsForDate(DateTime date) {
    final allEvents = getAllEvents();
    return allEvents.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  /// Get events for a specific month
  static List<OlympiadEvent> getEventsForMonth(DateTime month) {
    final allEvents = getAllEvents();
    return allEvents.where((event) {
      return event.date.year == month.year && event.date.month == month.month;
    }).toList();
  }

  /// Get events for a specific grade
  static List<OlympiadEvent> getEventsForGrade(int grade) {
    final allEvents = getAllEvents();
    return allEvents.where((event) => event.isForGrade(grade)).toList();
  }

  /// Get events for a specific subject
  static List<OlympiadEvent> getEventsForSubject(String subject) {
    final allEvents = getAllEvents();
    return allEvents.where((event) => event.isForSubject(subject)).toList();
  }

  /// Get only open registration events
  static List<OlympiadEvent> getOpenRegistrationEvents() {
    final allEvents = getAllEvents();
    return allEvents.where((event) => event.isRegistrationOpen).toList();
  }
}
