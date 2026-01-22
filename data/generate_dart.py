import json

# Read the parsed schedule data
with open('c:/Users/PC/Desktop/FizmatApp/fizmat-app/data/complete_schedules.json', 'r', encoding='utf-8') as f:
    schedules = json.load(f)

# Group by grade
grades = {}
for class_name, class_data in schedules.items():
    grade = class_data['grade']
    if grade not in grades:
        grades[grade] = {}
    grades[grade][class_name] = class_data

# Generate Dart code
dart_code = '''import 'package:fizmat_app/models/schedule_models.dart';

/// Real schedule data from school website
class ScheduleData {
  /// Get schedule for a specific class
  static ClassSchedule? getScheduleForClass(int gradeNumber, String gradeLetter) {
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

'''

# Generate method for each grade
for grade in sorted(grades.keys()):
    method_name = f"_get{grade}thGradeSchedule" if grade != 11 else "_get11thGradeSchedule"

    dart_code += f'''  /// {grade}th grade schedule
  static ClassSchedule? {method_name}(String letter) {{
    final schedules = <String, ClassSchedule>{{\n'''

    # Generate schedules for each class in this grade
    for class_name in sorted(grades[grade].keys()):
        class_data = grades[grade][class_name]
        letter = class_data['letter']

        dart_code += f"      '{letter}': ClassSchedule(\n"
        dart_code += f"        className: '{class_name}',\n"
        dart_code += f"        gradeNumber: {grade},\n"
        dart_code += f"        gradeLetter: '{letter}',\n"
        dart_code += f"        weekSchedule: {{\n"

        # Generate week schedule
        for day, lessons in class_data['schedule'].items():
            dart_code += f"          '{day}': DaySchedule(\n"
            dart_code += f"            dayName: '{day}',\n"
            dart_code += f"            lessons: [\n"

            # Generate lessons
            for lesson in lessons:
                subj = lesson['subject'].strip()
                # Capitalize first letter
                if subj:
                    subj = subj[0].upper() + subj[1:] if len(subj) > 1 else subj.upper()
                subj = subj.replace("'", "\\'")
                room = lesson['room'].replace("'", "\\'")
                time = lesson['time']
                num = lesson['lesson_number']

                # Parse time
                time_parts = time.split('-') if '-' in time else ['00.00', '00.00']
                start_time = time_parts[0].strip() if len(time_parts) > 0 else '00.00'
                end_time = time_parts[1].strip() if len(time_parts) > 1 else '00.00'

                dart_code += f"              Lesson(\n"
                dart_code += f"                subject: '{subj}',\n"
                dart_code += f"                teacher: '',\n"
                dart_code += f"                room: '{room}',\n"
                dart_code += f"                timeSlot: TimeSlot(startTime: '{start_time}', endTime: '{end_time}', lessonNumber: {num}),\n"
                dart_code += f"                lessonNumber: {num},\n"
                dart_code += f"              ),\n"

            dart_code += f"            ],\n"
            dart_code += f"            breaks: [],\n"
            dart_code += f"          ),\n"

        dart_code += f"        }},\n"
        dart_code += f"      ),\n"

    dart_code += f"    }};\n"
    dart_code += f"    return schedules[letter];\n"
    dart_code += f"  }}\n\n"

# Add method to get all available classes
dart_code += '''  /// Get all available classes
  static List<String> getAvailableClasses() {
    final List<String> classes = [];
    for (int grade = 7; grade <= 11; grade++) {
      final letters = _getLettersForGrade(grade);
      for (final letter in letters) {
        classes.add('$grade$letter');
      }
    }
    return classes;
  }

  static List<String> _getLettersForGrade(int grade) {
    if (grade == 7) {
      return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'K', 'L'];
    } else if (grade == 8) {
      return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'K', 'L'];
    } else if (grade == 9 || grade == 10 || grade == 11) {
      return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'K'];
    }
    return [];
  }
}
'''

# Write Dart file
with open('c:/Users/PC/Desktop/FizmatApp/fizmat-app/lib/data/schedule_data_new.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)

print(f"Generated Dart code with {len(schedules)} class schedules")
print(f"Saved to lib/data/schedule_data_new.dart")
