/// Models for class schedule/timetable

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isBreak;
  final int? breakNumber; // For break time display
  final int? lessonNumber; // For lesson number display

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isBreak = false,
    this.breakNumber,
    this.lessonNumber,
  });

  String get duration {
    // Calculate duration for display
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    final diff = end.difference(start).inMinutes;
    return '$diff мин';
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }
}

class Lesson {
  final String subject;
  final String? teacher;
  final String? room;
  final TimeSlot timeSlot;
  final int lessonNumber;

  Lesson({
    required this.subject,
    this.teacher,
    this.room,
    required this.timeSlot,
    required this.lessonNumber,
  });
}

class DaySchedule {
  final String dayName;
  final List<Lesson> lessons;
  final List<TimeSlot> breaks;

  DaySchedule({
    required this.dayName,
    required this.lessons,
    required this.breaks,
  });

  /// Get all time slots (lessons + breaks) in order
  List<dynamic> getAllSlots() {
    final List<dynamic> slots = [];
    for (int i = 0; i < lessons.length; i++) {
      slots.add(lessons[i]);
      if (i < breaks.length) {
        slots.add(breaks[i]);
      }
    }
    return slots;
  }
}

class ClassSchedule {
  final String className;
  final int gradeNumber;
  final String gradeLetter;
  final Map<String, DaySchedule> weekSchedule;

  ClassSchedule({
    required this.className,
    required this.gradeNumber,
    required this.gradeLetter,
    required this.weekSchedule,
  });

  String get formattedClassName => '$gradeNumber$gradeLetter';
}
