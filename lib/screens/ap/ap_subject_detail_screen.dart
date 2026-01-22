import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class APSubjectDetailScreen extends StatelessWidget {
  final String subjectKey;
  final String subjectName;

  const APSubjectDetailScreen({
    super.key,
    required this.subjectKey,
    required this.subjectName,
  });

  Map<String, dynamic> _getSubjectContent(String key, String languageCode) {
    // Content will be added here for each subject
    final contentMap = {
      'calculus_bc': _getCalculusContent(languageCode),
      'physics_c_mechanics': _getPhysicsMechanicsContent(languageCode),
      'physics_c_em': _getPhysicsEMContent(languageCode),
      'chemistry': _getChemistryContent(languageCode),
      'biology': _getBiologyContent(languageCode),
      'statistics': _getStatisticsContent(languageCode),
      'cs_a': _getCSAContent(languageCode),
      'english_lang': _getEnglishLangContent(languageCode),
      'psychology': _getPsychologyContent(languageCode),
    };

    return contentMap[key] ?? {
      'exam_info': languageCode == 'ru' ? 'Информация скоро будет добавлена' :
                   languageCode == 'kk' ? 'Ақпарат жақын арада қосылады' :
                   'Information coming soon',
      'resources': [],
      'tips': [],
    };
  }

  Map<String, dynamic> _getCalculusContent(String lang) {
    if (lang == 'ru') {
      return {
        'exam_info': '''Длительность: 3 часа 15 минут

Формат экзамена:
• Section I: 45 вопросов Multiple Choice
  - Part A: 30 вопросов без калькулятора (60 мин)
  - Part B: 15 вопросов с калькулятором (45 мин)
• Section II: 6 задач Free Response (FRQ)
  - Part A: 2 задачи с калькулятором (30 мин)
  - Part B: 4 задачи без калькулятора (60 мин)

Требования:
• Графический калькулятор обязателен (проверьте разрешенные модели)
• Гибридный формат: тест в Bluebook, решения FRQ на бумаге
• Предоставляется справочный лист с формулами

Стоимость:
• \$99 в США/Канаде, \$129 за пределами
• В Казахстане: \$130-150 в зависимости от тест-центра
• Регистрация через школу (осень учебного года)

Где сдавать в Казахстане:
• Международные школы (Haileybury, Miras, NIS)
• Обратитесь в AP-центры в начале учебного года
• Экзамен проводится в мае, обычно в 8:00 по местному времени''',
        'key_topics': [
          'Unit 1: Пределы и непрерывность (Limits & Continuity)',
          'Unit 2: Производная - определение и базовые свойства (Power, Product, Quotient Rules)',
          'Unit 3: Сложные функции (Chain Rule), неявное дифференцирование, обратные функции',
          'Unit 4: Применение производной в задачах (Related Rates, L\'Hôpital\'s Rule)',
          'Unit 5: Анализ функций (экстремумы, MVT, оптимизация, выпуклость)',
          'Unit 6: Интегрирование (подстановка, по частям, несобственные интегралы)',
          'Unit 7: Дифференциальные уравнения (разделяющиеся, логистический рост, метод Эйлера)',
          'Unit 8: Применения интегралов (площади, объемы вращения, длина дуги)',
          'Unit 9: Параметрические уравнения, полярные координаты, векторные функции',
          'Unit 10: Бесконечные последовательности и ряды (геометрический, p-ряды, степенные ряды, Тейлор/Маклорен)',
        ],
        'resources': [
          'AP Central (College Board) - официальные FRQ прошлых лет с критериями оценивания',
          'Khan Academy - бесплатный полный курс AP Calculus BC с практическими заданиями',
          'Paul\'s Online Math Notes - подробные конспекты по всем темам с примерами',
          'MIT OpenCourseWare - лекции по Single Variable Calculus',
          'The Organic Chemistry Tutor (YouTube) - видеоуроки по всем юнитам',
          'Professor Leonard (YouTube) - детальные лекции по Application of Derivatives',
          '5 Steps to a 5: AP Calculus - сборник задач и практические тесты',
          'Barron\'s AP Calculus - дополнительный сборник для подготовки',
        ],
        'tips': [
          'ВСЕГДА добавляйте +C при неопределенном интегрировании (частая ошибка на экзамене)',
          'Проверяйте условия применения теорем (непрерывность для IVT, дифференцируемость для MVT)',
          'Не упрощайте алгебру там, где не требуется - это приводит к ошибкам',
          'В FRQ показывайте ВСЕ шаги вывода формул - частичные баллы важны',
          'Округляйте только окончательный ответ (до 3 десятичных знаков)',
          'Используйте графический калькулятор эффективно - знайте его функции заранее',
          'Рисуйте free-body diagrams для задач физики, графики для анализа функций',
          'Практикуйте полный экзамен хотя бы за месяц до AP - привыкайте к 3-часовому формату',
          'Составьте формульный справочник по всем юнитам для быстрого повторения',
          'Метод Помодоро (25 мин работы, 5 мин перерыв) помогает избежать выгорания',
          'Спите 7-8 часов - мозг обрабатывает информацию во сне',
          'Чередуйте типы заданий: теория → практика → разбор ошибок',
          'Начните подготовку в сентябре, закончите новый материал к началу апреля',
          'За неделю до экзамена - только повторение, никакого нового материала',
          'Учитесь в группе или с партнером - обсуждение задач помогает понять концепции',
        ],
      };
    } else if (lang == 'kk') {
      return {
        'exam_info': '''Ұзақтығы: 3 сағат 15 минут

Формат:
• Section I: 45 сұрақ (Part A: калькуляторсыз 30 - 60 мин, Part B: калькуляторлы 15 - 45 мин)
• Section II: 6 FRQ тапсырма (Part A: калькуляторлы 2 - 30 мин, Part B: калькуляторсыз 4 - 60 мин)

Маңызды:
• Графикалық калькулятор қажет
• Гибридті формат (Bluebook тест, қағазда шешім)
• Формулалармен анықтамалық парақ беріледі''',
        'key_topics': [
          'Шектер және үздіксіздік',
          'Туындылар (Power, Product, Quotient, Chain Rule)',
          'Туындыларды қолдану (экстремумдар, MVT, оңтайландыру)',
          'Интегралдау (әдістер: алмастыру, бөліктеп, тригонометриялық)',
          'Интегралдарды қолдану (аудандар, көлемдер, қисық ұзындығы)',
          'Дифференциалдық теңдеулер',
          'Қатарлар және тізбектер (геометриялық қатар, Тейлор/Маклорен қатарлары)',
          'Параметрлік және полярлық координаттар',
        ],
        'resources': [
          'AP Central (College Board) - ресми FRQ және критерийлер',
          'Khan Academy - тегін AP Calculus BC курсы',
          'Paul\'s Online Math Notes - толық конспектілер',
          'MIT OpenCourseWare - Single Variable Calculus',
        ],
        'tips': [
          'Анықталмаған интегралдауда +C қосуды ҰМЫТПАҢЫЗ',
          'Теоремаларды қолдану шарттарын тексеріңіз',
          'Қажет болмаса алгебраны жеңілдетпеңіз',
          'FRQ-да формулаларды шығару барлық қадамдарын көрсетіңіз',
          'Тек соңғы жауапты дөңгелектеңіз (3 таңбаға дейін)',
          'Графикалық калькуляторды тиімді пайдаланыңыз',
        ],
      };
    } else {
      return {
        'exam_info': '''Duration: 3 hours 15 minutes

Format:
• Section I: 45 questions (Part A: 30 without calculator - 60 min, Part B: 15 with calculator - 45 min)
• Section II: 6 FRQ tasks (Part A: 2 with calculator - 30 min, Part B: 4 without calculator - 60 min)

Important:
• Graphing calculator required
• Hybrid format (test in Bluebook, solutions on paper)
• Formula sheet provided''',
        'key_topics': [
          'Limits and continuity',
          'Derivatives (Power, Product, Quotient, Chain Rule)',
          'Applications of derivatives (extrema, MVT, optimization)',
          'Integration (methods: substitution, by parts, trigonometric)',
          'Applications of integrals (areas, volumes, arc length)',
          'Differential equations',
          'Series and sequences (geometric series, Taylor/Maclaurin series)',
          'Parametric and polar coordinates',
        ],
        'resources': [
          'AP Central (College Board) - official FRQs and rubrics',
          'Khan Academy - free AP Calculus BC course',
          'Paul\'s Online Math Notes - detailed notes',
          'MIT OpenCourseWare - Single Variable Calculus',
        ],
        'tips': [
          'ALWAYS add +C for indefinite integrals',
          'Check theorem conditions (continuity, differentiability)',
          'Don\'t simplify algebra unnecessarily - avoid errors',
          'Show all derivation steps in FRQs',
          'Round only final answer (to 3 decimal places)',
          'Use graphing calculator effectively',
        ],
      };
    }
  }

  Map<String, dynamic> _getPhysicsMechanicsContent(String lang) {
    if (lang == 'ru') {
      return {
        'exam_info': '''Длительность: 90 минут

Формат:
• Section I: ~35 вопросов MC (45 мин)
• Section II: 3 задачи FRQ (45 мин)

Важно:
• Калькулятор разрешен
• Таблица констант предоставляется
• Требуется знание Calculus''',
        'key_topics': [
          'Кинематика (уравнения движения, векторы)',
          'Динамика (законы Ньютона, силы)',
          'Работа и энергия (кинетическая, потенциальная)',
          'Импульс (столкновения, сохранение)',
          'Вращательное движение (момент инерции, крутящий момент)',
          'Гармонические колебания (пружина, маятник)',
          'Гравитация',
        ],
        'resources': [
          'MIT 8.01 Classical Mechanics',
          'AP Central - FRQ с решениями',
          'Khan Academy - Physics',
          'Flipping Physics - YouTube',
        ],
        'tips': [
          'Всегда рисуйте free-body diagram',
          'Не рисуйте центростремительную силу как отдельную',
          'Показывайте вывод от базовых законов (F=ma)',
          'Проверяйте размерность ответа',
          'Оценивайте разумность результата',
        ],
      };
    } else {
      return {
        'exam_info': '''Duration: 90 minutes

Format:
• Section I: ~35 MC questions (45 min)
• Section II: 3 FRQ problems (45 min)

Important:
• Calculator allowed
• Constants table provided
• Calculus knowledge required''',
        'key_topics': [
          'Kinematics (equations of motion, vectors)',
          'Dynamics (Newton\'s laws, forces)',
          'Work and energy (kinetic, potential)',
          'Momentum (collisions, conservation)',
          'Rotational motion (moment of inertia, torque)',
          'Harmonic oscillations (spring, pendulum)',
          'Gravitation',
        ],
        'resources': [
          'MIT 8.01 Classical Mechanics',
          'AP Central - FRQs with solutions',
          'Khan Academy - Physics',
          'Flipping Physics - YouTube',
        ],
        'tips': [
          'Always draw free-body diagram',
          'Don\'t draw centripetal force separately',
          'Show derivation from basic laws (F=ma)',
          'Check dimensional analysis',
          'Evaluate answer reasonableness',
        ],
      };
    }
  }

  Map<String, dynamic> _getPhysicsEMContent(String lang) {
    return _getPhysicsMechanicsContent(lang); // Simplified for now
  }

  Map<String, dynamic> _getChemistryContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: 3 часа 15 минут' : 'Duration: 3 hours 15 minutes',
      'key_topics': lang == 'ru' ? [
        'Атомная структура',
        'Стехиометрия',
        'Термодинамика',
        'Кинетика',
        'Равновесие',
        'Кислоты и основания',
        'Электрохимия',
      ] : [
        'Atomic structure',
        'Stoichiometry',
        'Thermodynamics',
        'Kinetics',
        'Equilibrium',
        'Acids and bases',
        'Electrochemistry',
      ],
      'resources': [
        'AP Central Chemistry',
        'Khan Academy',
        'OpenStax Chemistry',
      ],
      'tips': [],
    };
  }

  Map<String, dynamic> _getBiologyContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: ~3 часа' : 'Duration: ~3 hours',
      'key_topics': [],
      'resources': ['AP Central Biology', 'Khan Academy Biology'],
      'tips': [],
    };
  }

  Map<String, dynamic> _getStatisticsContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: 3 часа' : 'Duration: 3 hours',
      'key_topics': [],
      'resources': ['AP Central Statistics', 'Khan Academy Statistics'],
      'tips': [],
    };
  }

  Map<String, dynamic> _getCSAContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: ~3 часа' : 'Duration: ~3 hours',
      'key_topics': [],
      'resources': ['AP Central CS A', 'CodingBat Java'],
      'tips': [],
    };
  }

  Map<String, dynamic> _getEnglishLangContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: ~3 часа 15 минут' : 'Duration: ~3 hours 15 minutes',
      'key_topics': [],
      'resources': ['AP Central English Language'],
      'tips': [],
    };
  }

  Map<String, dynamic> _getPsychologyContent(String lang) {
    return {
      'exam_info': lang == 'ru' ? 'Длительность: ~2 часа 40 минут' : 'Duration: ~2 hours 40 minutes',
      'key_topics': [],
      'resources': ['AP Central Psychology', 'Khan Academy Psychology'],
      'tips': [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = l10n.locale.languageCode;
    final content = _getSubjectContent(subjectKey, languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          _buildHeader(theme, languageCode),
          const SizedBox(height: 24),

          // Exam Info
          _buildSection(
            theme,
            languageCode == 'ru' ? 'Информация об экзамене' :
            languageCode == 'kk' ? 'Емтихан туралы ақпарат' :
            'Exam Information',
            content['exam_info'] as String,
          ),
          const SizedBox(height: 20),

          // Key Topics
          if ((content['key_topics'] as List).isNotEmpty) ...[
            _buildTopicsSection(theme, languageCode, content['key_topics'] as List<String>),
            const SizedBox(height: 20),
          ],

          // Resources
          if ((content['resources'] as List).isNotEmpty) ...[
            _buildResourcesSection(theme, languageCode, content['resources'] as List<String>),
            const SizedBox(height: 20),
          ],

          // Tips
          if ((content['tips'] as List).isNotEmpty) ...[
            _buildTipsSection(theme, languageCode, content['tips'] as List<String>),
            const SizedBox(height: 20),
          ],

          // Official Link
          _buildLinkCard(theme, languageCode, 'https://apcentral.collegeboard.org'),
        ],
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
          Icon(
            Icons.school,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            subjectName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
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

  Widget _buildTopicsSection(ThemeData theme, String lang, List<String> topics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'ru' ? 'Ключевые темы' :
            lang == 'kk' ? 'Негізгі тақырыптар' :
            'Key Topics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...topics.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
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

  Widget _buildResourcesSection(ThemeData theme, String lang, List<String> resources) {
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
            lang == 'ru' ? 'Ресурсы для подготовки' :
            lang == 'kk' ? 'Дайындық ресурстары' :
            'Preparation Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...resources.map((resource) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.book,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
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

  Widget _buildTipsSection(ThemeData theme, String lang, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                lang == 'ru' ? 'Советы по подготовке' :
                lang == 'kk' ? 'Дайындық бойынша кеңестер' :
                'Preparation Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
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

  Widget _buildLinkCard(ThemeData theme, String lang, String url) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.link,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          lang == 'ru' ? 'Официальный сайт AP' :
          lang == 'kk' ? 'AP ресми сайты' :
          'Official AP Website',
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
