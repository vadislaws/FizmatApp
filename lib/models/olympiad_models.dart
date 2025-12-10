/// Models for Olympiad events

class OlympiadEvent {
  final String title;
  final String description;
  final DateTime date;
  final String? location;
  final String? url;
  final List<String> subjects; // e.g., ['Mathematics', 'Physics']
  final List<int> grades; // e.g., [7, 8, 9]
  final OlympiadEventType type;
  final bool isRegistrationOpen;

  OlympiadEvent({
    required this.title,
    required this.description,
    required this.date,
    this.location,
    this.url,
    required this.subjects,
    required this.grades,
    required this.type,
    this.isRegistrationOpen = false,
  });

  /// Check if this event is for a specific grade
  bool isForGrade(int grade) {
    return grades.isEmpty || grades.contains(grade);
  }

  /// Check if this event is for a specific subject
  bool isForSubject(String subject) {
    return subjects.isEmpty || subjects.any((s) => s.toLowerCase() == subject.toLowerCase());
  }

  /// Get color for the event based on type
  String get colorHex {
    switch (type) {
      case OlympiadEventType.international:
        return '#FF5722'; // Deep Orange
      case OlympiadEventType.national:
        return '#2196F3'; // Blue
      case OlympiadEventType.regional:
        return '#4CAF50'; // Green
      case OlympiadEventType.school:
        return '#9C27B0'; // Purple
      case OlympiadEventType.online:
        return '#00BCD4'; // Cyan
      case OlympiadEventType.workshop:
        return '#FFC107'; // Amber
      case OlympiadEventType.universityFair:
        return '#FF9800'; // Orange
      case OlympiadEventType.exhibition:
        return '#795548'; // Brown
      case OlympiadEventType.conference:
        return '#607D8B'; // Blue Grey
      case OlympiadEventType.other:
        return '#9E9E9E'; // Grey
    }
  }
}

enum OlympiadEventType {
  international,
  national,
  regional,
  school,
  online,
  workshop,
  universityFair,
  exhibition,
  conference,
  other,
}

extension OlympiadEventTypeExtension on OlympiadEventType {
  String get displayName {
    switch (this) {
      case OlympiadEventType.international:
        return 'International';
      case OlympiadEventType.national:
        return 'National';
      case OlympiadEventType.regional:
        return 'Regional';
      case OlympiadEventType.school:
        return 'School';
      case OlympiadEventType.online:
        return 'Online';
      case OlympiadEventType.workshop:
        return 'Workshop';
      case OlympiadEventType.universityFair:
        return 'University Fair';
      case OlympiadEventType.exhibition:
        return 'Exhibition';
      case OlympiadEventType.conference:
        return 'Conference';
      case OlympiadEventType.other:
        return 'Other';
    }
  }

  String get displayNameRu {
    switch (this) {
      case OlympiadEventType.international:
        return 'Международная';
      case OlympiadEventType.national:
        return 'Республиканская';
      case OlympiadEventType.regional:
        return 'Региональная';
      case OlympiadEventType.school:
        return 'Школьная';
      case OlympiadEventType.online:
        return 'Онлайн';
      case OlympiadEventType.workshop:
        return 'Мастер-класс';
      case OlympiadEventType.universityFair:
        return 'Ярмарка вузов';
      case OlympiadEventType.exhibition:
        return 'Выставка';
      case OlympiadEventType.conference:
        return 'Конференция';
      case OlympiadEventType.other:
        return 'Другое';
    }
  }

  String get displayNameKk {
    switch (this) {
      case OlympiadEventType.international:
        return 'Халықаралық';
      case OlympiadEventType.national:
        return 'Республикалық';
      case OlympiadEventType.regional:
        return 'Аймақтық';
      case OlympiadEventType.school:
        return 'Мектептік';
      case OlympiadEventType.online:
        return 'Онлайн';
      case OlympiadEventType.workshop:
        return 'Шеберлік сыныбы';
      case OlympiadEventType.universityFair:
        return 'Университет жәрмеңкесі';
      case OlympiadEventType.exhibition:
        return 'Көрме';
      case OlympiadEventType.conference:
        return 'Конференция';
      case OlympiadEventType.other:
        return 'Басқа';
    }
  }
}
