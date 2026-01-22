import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/screens/ap/ap_subject_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class APScreen extends StatelessWidget {
  const APScreen({super.key});

  List<Map<String, String>> _getAPSubjects(String languageCode) {
    if (languageCode == 'ru') {
      return [
        {'key': 'calculus_bc', 'name': 'AP Calculus BC'},
        {'key': 'statistics', 'name': 'AP Statistics'},
        {'key': 'precalculus', 'name': 'AP Precalculus'},
        {'key': 'physics_1', 'name': 'AP Physics 1'},
        {'key': 'physics_2', 'name': 'AP Physics 2'},
        {'key': 'physics_c_mechanics', 'name': 'AP Physics C: Mechanics'},
        {'key': 'physics_c_em', 'name': 'AP Physics C: E&M'},
        {'key': 'chemistry', 'name': 'AP Chemistry'},
        {'key': 'biology', 'name': 'AP Biology'},
        {'key': 'environmental_science', 'name': 'AP Environmental Science'},
        {'key': 'cs_a', 'name': 'AP Computer Science A'},
        {'key': 'cs_principles', 'name': 'AP Computer Science Principles'},
        {'key': 'english_lang', 'name': 'AP English Language'},
        {'key': 'english_lit', 'name': 'AP English Literature'},
        {'key': 'psychology', 'name': 'AP Psychology'},
        {'key': 'us_history', 'name': 'AP US History'},
        {'key': 'world_history', 'name': 'AP World History'},
        {'key': 'european_history', 'name': 'AP European History'},
        {'key': 'us_government', 'name': 'AP US Government'},
        {'key': 'comparative_government', 'name': 'AP Comparative Government'},
        {'key': 'macroeconomics', 'name': 'AP Macroeconomics'},
        {'key': 'microeconomics', 'name': 'AP Microeconomics'},
        {'key': 'human_geography', 'name': 'AP Human Geography'},
        {'key': 'art_history', 'name': 'AP Art History'},
        {'key': 'music_theory', 'name': 'AP Music Theory'},
        {'key': 'spanish_lang', 'name': 'AP Spanish Language'},
        {'key': 'spanish_lit', 'name': 'AP Spanish Literature'},
        {'key': 'french_lang', 'name': 'AP French Language'},
        {'key': 'german_lang', 'name': 'AP German Language'},
        {'key': 'chinese_lang', 'name': 'AP Chinese Language'},
        {'key': 'japanese_lang', 'name': 'AP Japanese Language'},
        {'key': 'italian_lang', 'name': 'AP Italian Language'},
        {'key': 'latin', 'name': 'AP Latin'},
        {'key': 'seminar', 'name': 'AP Seminar'},
        {'key': 'research', 'name': 'AP Research'},
      ];
    } else {
      return [
        {'key': 'calculus_bc', 'name': 'AP Calculus BC'},
        {'key': 'statistics', 'name': 'AP Statistics'},
        {'key': 'precalculus', 'name': 'AP Precalculus'},
        {'key': 'physics_1', 'name': 'AP Physics 1'},
        {'key': 'physics_2', 'name': 'AP Physics 2'},
        {'key': 'physics_c_mechanics', 'name': 'AP Physics C: Mechanics'},
        {'key': 'physics_c_em', 'name': 'AP Physics C: E&M'},
        {'key': 'chemistry', 'name': 'AP Chemistry'},
        {'key': 'biology', 'name': 'AP Biology'},
        {'key': 'environmental_science', 'name': 'AP Environmental Science'},
        {'key': 'cs_a', 'name': 'AP Computer Science A'},
        {'key': 'cs_principles', 'name': 'AP Computer Science Principles'},
        {'key': 'english_lang', 'name': 'AP English Language'},
        {'key': 'english_lit', 'name': 'AP English Literature'},
        {'key': 'psychology', 'name': 'AP Psychology'},
        {'key': 'us_history', 'name': 'AP US History'},
        {'key': 'world_history', 'name': 'AP World History'},
        {'key': 'european_history', 'name': 'AP European History'},
        {'key': 'us_government', 'name': 'AP US Government'},
        {'key': 'comparative_government', 'name': 'AP Comparative Government'},
        {'key': 'macroeconomics', 'name': 'AP Macroeconomics'},
        {'key': 'microeconomics', 'name': 'AP Microeconomics'},
        {'key': 'human_geography', 'name': 'AP Human Geography'},
        {'key': 'art_history', 'name': 'AP Art History'},
        {'key': 'music_theory', 'name': 'AP Music Theory'},
        {'key': 'spanish_lang', 'name': 'AP Spanish Language'},
        {'key': 'spanish_lit', 'name': 'AP Spanish Literature'},
        {'key': 'french_lang', 'name': 'AP French Language'},
        {'key': 'german_lang', 'name': 'AP German Language'},
        {'key': 'chinese_lang', 'name': 'AP Chinese Language'},
        {'key': 'japanese_lang', 'name': 'AP Japanese Language'},
        {'key': 'italian_lang', 'name': 'AP Italian Language'},
        {'key': 'latin', 'name': 'AP Latin'},
        {'key': 'seminar', 'name': 'AP Seminar'},
        {'key': 'research', 'name': 'AP Research'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = l10n.locale.languageCode;
    final subjects = _getAPSubjects(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageCode == 'ru' ? 'AP Экзамены 2025' :
                    languageCode == 'kk' ? 'AP Емтихандары 2025' :
                    'AP Exams 2025'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          _buildHeader(theme, languageCode),
          const SizedBox(height: 24),

          // Overview
          _buildSection(
            theme,
            languageCode,
            languageCode == 'ru' ? 'Обзор AP экзаменов 2025' :
            languageCode == 'kk' ? 'AP емтихандарына шолу 2025' :
            'AP Exams 2025 Overview',
            languageCode == 'ru' ?
              'Все экзамены Advanced Placement (AP) 2025 года проводятся в период с 5 по 16 мая (две недели).\n\nВремя начала по Алматы (GMT+6): 08:00 утра и 12:00 дня.\n\nРезервная сессия: 19-23 мая для учащихся, имеющих право на перенос экзамена.' :
            languageCode == 'kk' ?
              'Барлық Advanced Placement (AP) емтихандары 2025 жылы 5-16 мамыр аралығында (екі апта) өткізіледі.\n\nАлматы уақыты бойынша басталу уақыты (GMT+6): таңғы 08:00 және түскі 12:00.\n\nҚосымша сессия: 19-23 мамыр емтиханды ауыстыруға құқығы бар студенттер үшін.' :
              'All Advanced Placement (AP) exams for 2025 are held May 5-16 (two weeks).\n\nStart times in Almaty (GMT+6): 08:00 AM and 12:00 PM.\n\nLate Testing: May 19-23 for students eligible for exam rescheduling.',
          ),
          const SizedBox(height: 20),

          // Subjects by Category
          _buildSubjectsByCategory(theme, languageCode),
          const SizedBox(height: 20),

          // Schedule
          _buildScheduleSection(theme, languageCode),
          const SizedBox(height: 20),

          // Exam Formats
          _buildExamFormatsSection(theme, languageCode),
          const SizedBox(height: 24),

          // Preparation Section (Collapsible)
          _buildPreparationSection(theme, languageCode, subjects, context),
          const SizedBox(height: 24),

          // Official Link
          Text(
            languageCode == 'ru' ? 'Официальные ресурсы' :
            languageCode == 'kk' ? 'Ресми ресурстар' :
            'Official Resources',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildLinkCard(
            theme,
            languageCode,
            languageCode == 'ru' ? 'Официальный сайт AP' :
            languageCode == 'kk' ? 'AP ресми сайты' :
            'Official AP Website',
            'https://apcentral.collegeboard.org',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubjectsByCategory(ThemeData theme, String languageCode) {
    final categories = _getSubjectCategories(languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            languageCode == 'ru' ? 'Список предметов AP по категориям' :
            languageCode == 'kk' ? 'Санаттар бойынша AP пәндерінің тізімі' :
            'AP Subjects by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ...categories.map((category) => _buildCategoryCard(
          theme,
          category['icon'] as IconData,
          category['title'] as String,
          category['subjects'] as String,
          category['color'] as Color,
        )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  languageCode == 'ru' ?
                    'Примечание: Курсы AP 2-D/3-D Art and Design и AP Drawing оцениваются по портфолио (дедлайн: 9 мая 2025, 20:00 ET). AP Research не имеет майского экзамена.' :
                  languageCode == 'kk' ?
                    'Ескерту: AP 2-D/3-D Art and Design және AP Drawing курстары портфолио бойынша бағаланады (мерзімі: 9 мамыр 2025, 20:00 ET). AP Research-тің мамырдағы емтиханы жоқ.' :
                    'Note: AP 2-D/3-D Art and Design and AP Drawing courses are assessed via portfolio (deadline: May 9, 2025, 8:00 PM ET). AP Research has no May exam.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getSubjectCategories(String languageCode) {
    if (languageCode == 'ru') {
      return [
        {
          'icon': Icons.palette,
          'title': 'Искусство и дизайн',
          'subjects': 'AP 2-D Art and Design, AP 3-D Art and Design, AP Drawing, AP Art History, AP Music Theory',
          'color': Colors.purple,
        },
        {
          'icon': Icons.menu_book,
          'title': 'Английский язык',
          'subjects': 'AP English Language and Composition, AP English Literature and Composition',
          'color': Colors.blue,
        },
        {
          'icon': Icons.public,
          'title': 'История и обществознание',
          'subjects': 'AP African American Studies, AP Comparative Government, AP European History, AP Human Geography, AP Macroeconomics, AP Microeconomics, AP Psychology, AP US Government, AP US History, AP World History: Modern',
          'color': Colors.orange,
        },
        {
          'icon': Icons.calculate,
          'title': 'Математика и информатика',
          'subjects': 'AP Calculus AB, AP Calculus BC, AP Computer Science A, AP CS Principles, AP Precalculus, AP Statistics',
          'color': Colors.green,
        },
        {
          'icon': Icons.science,
          'title': 'Естественные науки',
          'subjects': 'AP Biology, AP Chemistry, AP Environmental Science, AP Physics 1, AP Physics 2, AP Physics C: E&M, AP Physics C: Mechanics',
          'color': Colors.teal,
        },
        {
          'icon': Icons.language,
          'title': 'Иностранные языки',
          'subjects': 'AP Chinese, AP French, AP German, AP Italian, AP Japanese, AP Latin, AP Spanish Language, AP Spanish Literature',
          'color': Colors.pink,
        },
        {
          'icon': Icons.school,
          'title': 'Capstone (междисциплинарные)',
          'subjects': 'AP Seminar, AP Research',
          'color': Colors.deepPurple,
        },
      ];
    } else if (languageCode == 'kk') {
      return [
        {
          'icon': Icons.palette,
          'title': 'Өнер және дизайн',
          'subjects': 'AP 2-D Art and Design, AP 3-D Art and Design, AP Drawing, AP Art History, AP Music Theory',
          'color': Colors.purple,
        },
        {
          'icon': Icons.menu_book,
          'title': 'Ағылшын тілі',
          'subjects': 'AP English Language and Composition, AP English Literature and Composition',
          'color': Colors.blue,
        },
        {
          'icon': Icons.public,
          'title': 'Тарих және қоғамтану',
          'subjects': 'AP African American Studies, AP Comparative Government, AP European History, AP Human Geography, AP Macroeconomics, AP Microeconomics, AP Psychology, AP US Government, AP US History, AP World History: Modern',
          'color': Colors.orange,
        },
        {
          'icon': Icons.calculate,
          'title': 'Математика және информатика',
          'subjects': 'AP Calculus AB, AP Calculus BC, AP Computer Science A, AP CS Principles, AP Precalculus, AP Statistics',
          'color': Colors.green,
        },
        {
          'icon': Icons.science,
          'title': 'Жаратылыстану',
          'subjects': 'AP Biology, AP Chemistry, AP Environmental Science, AP Physics 1, AP Physics 2, AP Physics C: E&M, AP Physics C: Mechanics',
          'color': Colors.teal,
        },
        {
          'icon': Icons.language,
          'title': 'Шет тілдері',
          'subjects': 'AP Chinese, AP French, AP German, AP Italian, AP Japanese, AP Latin, AP Spanish Language, AP Spanish Literature',
          'color': Colors.pink,
        },
        {
          'icon': Icons.school,
          'title': 'Capstone (пәнаралық)',
          'subjects': 'AP Seminar, AP Research',
          'color': Colors.deepPurple,
        },
      ];
    } else {
      return [
        {
          'icon': Icons.palette,
          'title': 'Arts and Design',
          'subjects': 'AP 2-D Art and Design, AP 3-D Art and Design, AP Drawing, AP Art History, AP Music Theory',
          'color': Colors.purple,
        },
        {
          'icon': Icons.menu_book,
          'title': 'English',
          'subjects': 'AP English Language and Composition, AP English Literature and Composition',
          'color': Colors.blue,
        },
        {
          'icon': Icons.public,
          'title': 'History and Social Sciences',
          'subjects': 'AP African American Studies, AP Comparative Government, AP European History, AP Human Geography, AP Macroeconomics, AP Microeconomics, AP Psychology, AP US Government, AP US History, AP World History: Modern',
          'color': Colors.orange,
        },
        {
          'icon': Icons.calculate,
          'title': 'Math and Computer Science',
          'subjects': 'AP Calculus AB, AP Calculus BC, AP Computer Science A, AP CS Principles, AP Precalculus, AP Statistics',
          'color': Colors.green,
        },
        {
          'icon': Icons.science,
          'title': 'Sciences',
          'subjects': 'AP Biology, AP Chemistry, AP Environmental Science, AP Physics 1, AP Physics 2, AP Physics C: E&M, AP Physics C: Mechanics',
          'color': Colors.teal,
        },
        {
          'icon': Icons.language,
          'title': 'World Languages',
          'subjects': 'AP Chinese, AP French, AP German, AP Italian, AP Japanese, AP Latin, AP Spanish Language, AP Spanish Literature',
          'color': Colors.pink,
        },
        {
          'icon': Icons.school,
          'title': 'Capstone',
          'subjects': 'AP Seminar, AP Research',
          'color': Colors.deepPurple,
        },
      ];
    }
  }

  Widget _buildCategoryCard(ThemeData theme, IconData icon, String title, String subjects, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subjects,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme, String languageCode) {
    final scheduleData = _getScheduleData(languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageCode == 'ru' ? 'Расписание экзаменов (май 2025)' :
          languageCode == 'kk' ? 'Емтихандар кестесі (мамыр 2025)' :
          'Exam Schedule (May 2025)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...scheduleData.map((week) => _buildWeekSchedule(theme, week, languageCode)),
      ],
    );
  }

  List<Map<String, dynamic>> _getScheduleData(String languageCode) {
    if (languageCode == 'ru') {
      return [
        {
          'title': 'Неделя 1 (5-9 мая)',
          'days': [
            {'date': '5 мая', 'morning': 'Biology, Latin', 'noon': 'European History, Microeconomics'},
            {'date': '6 мая', 'morning': 'Chemistry, Human Geography', 'noon': 'US Government and Politics'},
            {'date': '7 мая', 'morning': 'English Literature', 'noon': 'Comparative Government, Computer Science A'},
            {'date': '8 мая', 'morning': 'African American Studies, Statistics', 'noon': 'Japanese Language, World History: Modern'},
            {'date': '9 мая', 'morning': 'Italian Language', 'noon': 'US History, Chinese Language, Macroeconomics'},
          ],
        },
        {
          'title': 'Неделя 2 (12-16 мая)',
          'days': [
            {'date': '12 мая', 'morning': 'Calculus AB, Calculus BC', 'noon': 'Music Theory, Seminar'},
            {'date': '13 мая', 'morning': 'French Language, Precalculus', 'noon': 'Environmental Science, Physics 2'},
            {'date': '14 мая', 'morning': 'English Language', 'noon': 'German Language, Physics C: Mechanics'},
            {'date': '15 мая', 'morning': 'Art History, Spanish Language', 'noon': 'CS Principles, Physics C: E&M'},
            {'date': '16 мая', 'morning': 'Physics 1', 'noon': 'Spanish Literature, Psychology'},
          ],
        },
      ];
    } else {
      return [
        {
          'title': 'Week 1 (May 5-9)',
          'days': [
            {'date': 'May 5', 'morning': 'Biology, Latin', 'noon': 'European History, Microeconomics'},
            {'date': 'May 6', 'morning': 'Chemistry, Human Geography', 'noon': 'US Government and Politics'},
            {'date': 'May 7', 'morning': 'English Literature', 'noon': 'Comparative Government, Computer Science A'},
            {'date': 'May 8', 'morning': 'African American Studies, Statistics', 'noon': 'Japanese Language, World History: Modern'},
            {'date': 'May 9', 'morning': 'Italian Language', 'noon': 'US History, Chinese Language, Macroeconomics'},
          ],
        },
        {
          'title': 'Week 2 (May 12-16)',
          'days': [
            {'date': 'May 12', 'morning': 'Calculus AB, Calculus BC', 'noon': 'Music Theory, Seminar'},
            {'date': 'May 13', 'morning': 'French Language, Precalculus', 'noon': 'Environmental Science, Physics 2'},
            {'date': 'May 14', 'morning': 'English Language', 'noon': 'German Language, Physics C: Mechanics'},
            {'date': 'May 15', 'morning': 'Art History, Spanish Language', 'noon': 'CS Principles, Physics C: E&M'},
            {'date': 'May 16', 'morning': 'Physics 1', 'noon': 'Spanish Literature, Psychology'},
          ],
        },
      ];
    }
  }

  Widget _buildWeekSchedule(ThemeData theme, Map<String, dynamic> week, String languageCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                week['title'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(week['days'] as List).map((day) => _buildDaySchedule(theme, day, languageCode)),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(ThemeData theme, Map<String, String> day, String languageCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day['date']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '08:00',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day['morning']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '12:00',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day['noon']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamFormatsSection(ThemeData theme, String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageCode == 'ru' ? 'Формат и длительность экзаменов' :
          languageCode == 'kk' ? 'Емтихандардың форматы және ұзақтығы' :
          'Exam Format and Duration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // General info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  languageCode == 'ru' ?
                    'Каждый экзамен AP длится 2-3 часа:\n• Section I: Multiple Choice\n• Section II: Free Response' :
                    'Each AP exam lasts 2-3 hours:\n• Section I: Multiple Choice\n• Section II: Free Response',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Math and Sciences
        _buildFormatCategoryCard(
          theme,
          Icons.calculate,
          languageCode == 'ru' ? 'Математика и науки' : 'Math and Sciences',
          Colors.green,
          languageCode == 'ru' ? [
            'AP Calculus AB/BC: 3ч 15мин (45 MC + 6 FRQ), графический калькулятор',
            'AP Statistics: 3ч (40 MC + 6 FRQ), калькулятор разрешен',
            'AP Physics C: 90мин каждый (~35 MC + 3 FRQ), калькулятор',
            'AP Chemistry: 3ч 15мин (60 MC + 7 FRQ), калькулятор, таблицы',
            'AP Biology: 3ч (60 MC + 6 FRQ), калькулятор, справочник',
          ] : [
            'AP Calculus AB/BC: 3h 15min (45 MC + 6 FRQ), graphing calculator',
            'AP Statistics: 3h (40 MC + 6 FRQ), calculator allowed',
            'AP Physics C: 90min each (~35 MC + 3 FRQ), calculator',
            'AP Chemistry: 3h 15min (60 MC + 7 FRQ), calculator, tables',
            'AP Biology: 3h (60 MC + 6 FRQ), calculator, reference sheet',
          ],
        ),
        const SizedBox(height: 12),

        // English and Humanities
        _buildFormatCategoryCard(
          theme,
          Icons.menu_book,
          languageCode == 'ru' ? 'Английский и гуманитарные' : 'English and Humanities',
          Colors.blue,
          languageCode == 'ru' ? [
            'AP English Lang/Lit: 3ч 15мин (45-55 MC + 3 эссе), полностью цифровой',
            'AP Psychology: 2ч 40мин (75 MC + 2 FRQ), цифровой',
            'AP History: 3ч (55 MC + 4 FRQ), цифровой',
            'AP Economics: 2ч 10мин (60 MC + 3 FRQ), калькулятор',
          ] : [
            'AP English Lang/Lit: 3h 15min (45-55 MC + 3 essays), fully digital',
            'AP Psychology: 2h 40min (75 MC + 2 FRQ), digital',
            'AP History: 3h (55 MC + 4 FRQ), digital',
            'AP Economics: 2h 10min (60 MC + 3 FRQ), calculator',
          ],
        ),
        const SizedBox(height: 12),

        // Languages
        _buildFormatCategoryCard(
          theme,
          Icons.language,
          languageCode == 'ru' ? 'Иностранные языки' : 'Languages',
          Colors.pink,
          [languageCode == 'ru' ? '3 часа (аудирование, чтение, письмо, устная речь)' : '3 hours (listening, reading, writing, speaking)'],
        ),
        const SizedBox(height: 12),

        // Important note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.computer,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  languageCode == 'ru' ?
                    'Важно: Многие экзамены переходят на цифровой формат (Bluebook). Гибридные экзамены: MC на компьютере, FRQ на бумаге.' :
                    'Important: Many exams are transitioning to digital format (Bluebook). Hybrid exams: MC on computer, FRQ on paper.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatCategoryCard(ThemeData theme, IconData icon, String title, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPreparationSection(ThemeData theme, String languageCode, List<Map<String, String>> subjects, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          Icons.menu_book,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          languageCode == 'ru' ? 'Подготовка к экзаменам' :
          languageCode == 'kk' ? 'Емтихандарға дайындық' :
          'Exam Preparation',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          languageCode == 'ru' ? 'Выберите предмет для подготовки' :
          languageCode == 'kk' ? 'Дайындалу үшін пәнді таңдаңыз' :
          'Choose a subject to prepare',
          style: const TextStyle(fontSize: 12),
        ),
        children: subjects.map((subject) => _buildSubjectCard(
          theme,
          subject['name']!,
          subject['key']!,
          context,
        )).toList(),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String languageCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.school,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            languageCode == 'ru' ? 'Advanced Placement' :
            languageCode == 'kk' ? 'Advanced Placement' :
            'Advanced Placement',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            languageCode == 'ru' ? 'Подготовка к экзаменам AP' :
            languageCode == 'kk' ? 'AP емтихандарына дайындық' :
            'AP Exams Preparation',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String languageCode, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme, String name, String key, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.book,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => APSubjectDetailScreen(
                subjectKey: key,
                subjectName: name,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkCard(ThemeData theme, String languageCode, String title, String url) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.link,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text('apcentral.collegeboard.org'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
