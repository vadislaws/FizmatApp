from bs4 import BeautifulSoup
import json
import re

# Day name mappings
day_mapping = {
    'Дүйсенбі': 'Monday',
    'Сейсенбі': 'Tuesday',
    'Сәрсенбі': 'Wednesday',
    'Бейсенбі': 'Thursday',
    'Жұма': 'Friday',
    'Сенбі': 'Saturday',
    'Понедельник': 'Monday',
    'Вторник': 'Tuesday',
    'Среда': 'Wednesday',
    'Четверг': 'Thursday',
    'Пятница': 'Friday',
    'Суббота': 'Saturday'
}

# Read HTML
with open('c:/Users/PC/Desktop/FizmatApp/fizmat-app/data/Текстовый документ.txt', 'r', encoding='utf-8') as f:
    html = f.read()

soup = BeautifulSoup(html, 'html.parser')
all_tables = soup.find_all('table')

# Process grade tables (indices 8-12 for grades 7-11)
grade_tables = all_tables[8:13]

all_schedules = {}

for grade_idx, table in enumerate(grade_tables):
    grade = 7 + grade_idx

    rows = table.find_all('tr')

    # First row has class names
    header_row = rows[0]
    header_cells = header_row.find_all('td')

    # Extract class names (every 2 cells after first 3: class name, then "кабинет")
    class_names = []

    for idx in range(3, len(header_cells), 2):  # Start from cell 3, skip "кабинет" cells
        if idx < len(header_cells):
            text = header_cells[idx].get_text(strip=True)
            # Match pattern like "7A", "7B", etc.
            if re.match(r'\d+[A-ZА-Я]+', text):
                class_names.append(text)

    print(f"Grade {grade}: {len(class_names)} classes - {class_names}")

    # Initialize schedule structure
    for class_name in class_names:
        all_schedules[class_name] = {
            'grade': grade,
            'letter': class_name.replace(str(grade), ''),
            'schedule': {}
        }

    # Process lesson rows
    current_day_en = None

    for row_idx, row in enumerate(rows[1:], 1):
        cells = row.find_all('td')

        if not cells:
            continue

        # First cell might be a day name (with rowspan) or lesson number
        first_cell = cells[0]
        first_text = first_cell.get_text(strip=True)

        # Check if this cell has a day name
        for day_name, day_en in day_mapping.items():
            if day_name in first_text:
                current_day_en = day_en
                break

        # Determine cell offset based on whether first cell is a day
        is_day_row = any(day in first_text for day in day_mapping.keys())

        if is_day_row:
            # This row has: [day], [lesson#], [time], [class1 subj], [class1 room], ...
            if len(cells) < 3:
                continue

            lesson_num_cell = cells[1]
            time_cell = cells[2]
            lesson_cells_start = 3

        else:
            # This row has: [lesson#], [time], [class1 subj], [class1 room], ...
            # (day is in rowspan from previous row)
            if len(cells) < 2:
                continue

            lesson_num_cell = cells[0]
            time_cell = cells[1]
            lesson_cells_start = 2

        if not current_day_en:
            continue

        lesson_num = lesson_num_cell.get_text(strip=True)
        time = time_cell.get_text(strip=True)

        # Parse lesson number
        try:
            lesson_number = int(lesson_num)
        except:
            continue

        # Skip lesson 0
        if lesson_number == 0:
            continue

        # Process lessons for each class
        lesson_cells = cells[lesson_cells_start:]

        for class_idx, class_name in enumerate(class_names):
            # Each class has 2 cells: subject and room
            cell_offset = class_idx * 2

            if cell_offset >= len(lesson_cells):
                continue

            subject_cell = lesson_cells[cell_offset]
            room_cell = lesson_cells[cell_offset + 1] if (cell_offset + 1) < len(lesson_cells) else None

            subject = subject_cell.get_text(strip=True)
            room = room_cell.get_text(strip=True) if room_cell else ""

            # Skip empty lessons
            if not subject:
                continue

            # Initialize day schedule if needed
            if current_day_en not in all_schedules[class_name]['schedule']:
                all_schedules[class_name]['schedule'][current_day_en] = []

            # Add lesson
            all_schedules[class_name]['schedule'][current_day_en].append({
                'lesson_number': lesson_number,
                'time': time,
                'subject': subject,
                'room': room
            })

# Save to JSON
output_file = 'c:/Users/PC/Desktop/FizmatApp/fizmat-app/data/complete_schedules.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(all_schedules, f, ensure_ascii=False, indent=2)

print(f"\nTotal classes parsed: {len(all_schedules)}")
print(f"Saved to {output_file}")

# Print sample
sample_class = list(all_schedules.keys())[0]
print(f"\nSample schedule for {sample_class}:")
if all_schedules[sample_class]['schedule']:
    for day, lessons in all_schedules[sample_class]['schedule'].items():
        print(f"  {day}: {len(lessons)} lessons")
else:
    print("  No lessons found!")
