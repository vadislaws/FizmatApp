import 'package:fizmat_app/models/schedule_models.dart';

/// Schedule data provider for all classes
class ScheduleData {
  /// Standard time slots for all classes
  static final List<TimeSlot> standardLessonTimes = [
    TimeSlot(startTime: '08:30', endTime: '09:15', lessonNumber: 1),
    TimeSlot(startTime: '09:25', endTime: '10:10', lessonNumber: 2),
    TimeSlot(startTime: '10:30', endTime: '11:15', lessonNumber: 3),
    TimeSlot(startTime: '11:35', endTime: '12:20', lessonNumber: 4),
    TimeSlot(startTime: '12:30', endTime: '13:15', lessonNumber: 5),
    TimeSlot(startTime: '13:25', endTime: '14:10', lessonNumber: 6),
    TimeSlot(startTime: '14:20', endTime: '15:05', lessonNumber: 7),
  ];

  /// Standard breaks between lessons
  static final List<TimeSlot> standardBreaks = [
    TimeSlot(startTime: '09:15', endTime: '09:25', isBreak: true, breakNumber: 1),
    TimeSlot(startTime: '10:10', endTime: '10:30', isBreak: true, breakNumber: 2),
    TimeSlot(startTime: '11:15', endTime: '11:35', isBreak: true, breakNumber: 3),
    TimeSlot(startTime: '12:20', endTime: '12:30', isBreak: true, breakNumber: 4),
    TimeSlot(startTime: '13:15', endTime: '13:25', isBreak: true, breakNumber: 5),
    TimeSlot(startTime: '14:10', endTime: '14:20', isBreak: true, breakNumber: 6),
  ];

  /// Get schedule for a specific class
  static ClassSchedule? getScheduleForClass(int gradeNumber, String gradeLetter) {
    // Sample schedule data for different classes
    // In a real app, this would be loaded from a database or API

    if (gradeNumber == 7) {
      return _get7thGradeSchedule(gradeLetter);
    } else if (gradeNumber == 8) {
      return _get8thGradeSchedule(gradeLetter);
    } else if (gradeNumber == 9) {
      return _get9thGradeSchedule(gradeLetter);
    } else if (gradeNumber == 10) {
      return _get10thGradeSchedule(gradeLetter);
    } else if (gradeNumber == 11) {
      return _get11thGradeSchedule(gradeLetter);
    }

    return null;
  }

  /// 7th grade schedule
  static ClassSchedule _get7thGradeSchedule(String letter) {
    return ClassSchedule(
      className: '7$letter',
      gradeNumber: 7,
      gradeLetter: letter,
      weekSchedule: {
        'Monday': DaySchedule(
          dayName: 'Monday',
          lessons: [
            Lesson(subject: 'Mathematics', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'History', teacher: 'Sidorov S.S.', room: '210', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Physical Education', teacher: 'Orlov O.O.', room: 'Gym', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Tuesday': DaySchedule(
          dayName: 'Tuesday',
          lessons: [
            Lesson(subject: 'Kazakh Language', teacher: 'Aitova A.A.', room: '302', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Mathematics', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Biology', teacher: 'Volkova V.V.', room: '115', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Geography', teacher: 'Morozov M.M.', room: '308', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Arts', teacher: 'Belov B.B.', room: '405', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Wednesday': DaySchedule(
          dayName: 'Wednesday',
          lessons: [
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Mathematics', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Chemistry', teacher: 'Lebedeva L.L.', room: '112', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'History', teacher: 'Sidorov S.S.', room: '210', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Music', teacher: 'Solovyov S.S.', room: '401', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Thursday': DaySchedule(
          dayName: 'Thursday',
          lessons: [
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Kazakh Language', teacher: 'Aitova A.A.', room: '302', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Mathematics', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Biology', teacher: 'Volkova V.V.', room: '115', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Geography', teacher: 'Morozov M.M.', room: '308', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Physical Education', teacher: 'Orlov O.O.', room: 'Gym', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Friday': DaySchedule(
          dayName: 'Friday',
          lessons: [
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'History', teacher: 'Sidorov S.S.', room: '210', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Mathematics', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Computer Science', teacher: 'Novikov N.N.', room: '501', timeSlot: standardLessonTimes[4], lessonNumber: 5),
          ],
          breaks: standardBreaks.sublist(0, 4),
        ),
      },
    );
  }

  /// 8th grade schedule (similar structure)
  static ClassSchedule _get8thGradeSchedule(String letter) {
    return ClassSchedule(
      className: '8$letter',
      gradeNumber: 8,
      gradeLetter: letter,
      weekSchedule: {
        'Monday': DaySchedule(
          dayName: 'Monday',
          lessons: [
            Lesson(subject: 'Algebra', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Geometry', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Physical Education', teacher: 'Orlov O.O.', room: 'Gym', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Tuesday': DaySchedule(
          dayName: 'Tuesday',
          lessons: [
            Lesson(subject: 'Kazakh Language', teacher: 'Aitova A.A.', room: '302', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Algebra', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Chemistry', teacher: 'Lebedeva L.L.', room: '112', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Geography', teacher: 'Morozov M.M.', room: '308', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'History', teacher: 'Sidorov S.S.', room: '210', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Wednesday': DaySchedule(
          dayName: 'Wednesday',
          lessons: [
            Lesson(subject: 'Biology', teacher: 'Volkova V.V.', room: '115', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Geometry', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Computer Science', teacher: 'Novikov N.N.', room: '501', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'Physical Education', teacher: 'Orlov O.O.', room: 'Gym', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Thursday': DaySchedule(
          dayName: 'Thursday',
          lessons: [
            Lesson(subject: 'English', teacher: 'Smirnova S.S.', room: '412', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Kazakh Language', teacher: 'Aitova A.A.', room: '302', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Algebra', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Chemistry', teacher: 'Lebedeva L.L.', room: '112', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Geography', teacher: 'Morozov M.M.', room: '308', timeSlot: standardLessonTimes[4], lessonNumber: 5),
            Lesson(subject: 'History', teacher: 'Sidorov S.S.', room: '210', timeSlot: standardLessonTimes[5], lessonNumber: 6),
          ],
          breaks: standardBreaks.sublist(0, 5),
        ),
        'Friday': DaySchedule(
          dayName: 'Friday',
          lessons: [
            Lesson(subject: 'Physics', teacher: 'Kuznetsov K.K.', room: '108', timeSlot: standardLessonTimes[0], lessonNumber: 1),
            Lesson(subject: 'Biology', teacher: 'Volkova V.V.', room: '115', timeSlot: standardLessonTimes[1], lessonNumber: 2),
            Lesson(subject: 'Geometry', teacher: 'Ivanov I.I.', room: '201', timeSlot: standardLessonTimes[2], lessonNumber: 3),
            Lesson(subject: 'Russian Language', teacher: 'Petrova P.P.', room: '305', timeSlot: standardLessonTimes[3], lessonNumber: 4),
            Lesson(subject: 'Arts', teacher: 'Belov B.B.', room: '405', timeSlot: standardLessonTimes[4], lessonNumber: 5),
          ],
          breaks: standardBreaks.sublist(0, 4),
        ),
      },
    );
  }

  /// Similar methods for grades 9, 10, 11 (abbreviated for brevity)
  static ClassSchedule _get9thGradeSchedule(String letter) {
    // For simplicity, use same schedule template as 8th grade
    final baseSchedule = _get8thGradeSchedule(letter);
    return ClassSchedule(
      className: '9$letter',
      gradeNumber: 9,
      gradeLetter: letter,
      weekSchedule: baseSchedule.weekSchedule,
    );
  }

  static ClassSchedule _get10thGradeSchedule(String letter) {
    // For simplicity, use same schedule template as 8th grade
    final baseSchedule = _get8thGradeSchedule(letter);
    return ClassSchedule(
      className: '10$letter',
      gradeNumber: 10,
      gradeLetter: letter,
      weekSchedule: baseSchedule.weekSchedule,
    );
  }

  static ClassSchedule _get11thGradeSchedule(String letter) {
    // For simplicity, use same schedule template as 8th grade
    final baseSchedule = _get8thGradeSchedule(letter);
    return ClassSchedule(
      className: '11$letter',
      gradeNumber: 11,
      gradeLetter: letter,
      weekSchedule: baseSchedule.weekSchedule,
    );
  }

  /// Get all available classes
  static List<String> getAvailableClasses() {
    final List<String> classes = [];
    for (int grade = 7; grade <= 11; grade++) {
      for (final letter in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']) {
        classes.add('$grade$letter');
      }
    }
    return classes;
  }
}
