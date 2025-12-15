import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SchoolInfoScreen extends StatelessWidget {
  const SchoolInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = l10n.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.translate('school_information'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(context, theme, languageCode),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, String languageCode) {
    final content = _getContentByLanguage(languageCode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            content['title']!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            content['description']!,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            content['principle']!,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Leadership
          Text(
            content['leadership']!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          _buildLeaderItem(theme, content['president']!),
          _buildLeaderItem(theme, content['vice_president']!),
          const SizedBox(height: 8),
          _buildLeaderItem(theme, content['prime_ministers']!),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Ministries
          Text(
            content['ministries']!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // StartUp House
          _buildMinistry(
            theme,
            '🎯',
            content['startup_house']!,
            content['startup_house_goal']!,
            content['startup_house_minister']!,
            content['startup_house_vice'],
          ),

          // Science House
          _buildMinistry(
            theme,
            '🔬',
            content['science_house']!,
            content['science_house_goal']!,
            content['science_house_minister']!,
            content['science_house_vice'],
          ),

          // Olympiad House
          _buildMinistry(
            theme,
            '🏆',
            content['olympiad_house']!,
            content['olympiad_house_goal']!,
            content['olympiad_house_minister']!,
            content['olympiad_house_vice'],
          ),

          // Art & Design
          _buildMinistry(
            theme,
            '🎨',
            content['ministry_art']!,
            content['ministry_art_goal']!,
            content['ministry_art_minister']!,
            content['ministry_art_vice'],
          ),

          // Communication
          _buildMinistry(
            theme,
            '👥',
            content['ministry_comm']!,
            content['ministry_comm_goal']!,
            content['ministry_comm_minister']!,
            null,
          ),

          // Media
          _buildMinistry(
            theme,
            '📸',
            content['ministry_media']!,
            content['ministry_media_goal']!,
            content['ministry_media_minister']!,
            content['ministry_media_vice'],
          ),

          // Culture
          _buildMinistry(
            theme,
            '🌏',
            content['ministry_culture']!,
            content['ministry_culture_goal']!,
            content['ministry_culture_minister']!,
            content['ministry_culture_vice'],
          ),

          // Sport
          _buildMinistry(
            theme,
            '🥇',
            content['ministry_sport']!,
            content['ministry_sport_goal']!,
            content['ministry_sport_minister']!,
            content['ministry_sport_vice'],
          ),

          // Ecology
          _buildMinistry(
            theme,
            '☘️',
            content['ministry_ecology']!,
            content['ministry_ecology_goal']!,
            content['ministry_ecology_minister']!,
            content['ministry_ecology_vice'],
          ),

          // Development
          _buildMinistry(
            theme,
            '🎡',
            content['ministry_dev']!,
            content['ministry_dev_goal']!,
            content['ministry_dev_minister']!,
            null,
          ),

          // Justice
          _buildMinistry(
            theme,
            '⚖️',
            content['ministry_justice']!,
            content['ministry_justice_goal']!,
            content['ministry_justice_minister']!,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildMinistry(
    ThemeData theme,
    String emoji,
    String title,
    String goal,
    String minister,
    String? viceMinister,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            minister,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          if (viceMinister != null) ...[
            const SizedBox(height: 4),
            Text(
              viceMinister,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, String> _getContentByLanguage(String languageCode) {
    if (languageCode == 'ru') {
      return {
        'title': 'Школьный совет',
        'description': 'Школьный совет — это орган ученического самоуправления, который объединяет активных учеников школы. Он помогает защищать интересы учащихся, организовывает школьные мероприятия, развивает инициативы и делает школьную жизнь более интересной и комфортной.',
        'principle': 'Школьный совет работает по принципу министерств. Каждое министерство отвечает за свое направление, а во главе стоят министры и их заместители (вице-министры).',
        'leadership': 'Руководство школьного совета',
        'president': 'Президент: Өмірзақ Саният (10G)',
        'vice_president': 'Вице-президент: Ербол Бекарыс (11C)',
        'prime_ministers': 'Премьер-министры:\n• Пернебаев Альтаир (11K)\n• Қарымсақ Хабиби (11A)',
        'ministries': 'Министерства',

        'ministry_art': 'Министерство Арта и Дизайна',
        'ministry_art_goal': 'Цель: оформление школы, создание декораций, афиш и креативных проектов.',
        'ministry_art_minister': 'Министр: Бауржан Алтынай (10D)',
        'ministry_art_vice': 'Вице-министры:\n• Тетенкова Адель (10F)\n• Заплавнова Дарья (11K)',

        'ministry_comm': 'Министерство Коммуникации',
        'ministry_comm_goal': 'Цель: связь между учениками, организация мероприятий, объявлений и информирование школьников через рассылки.',
        'ministry_comm_minister': 'Министры:\n• Сұлтан Шуақ (10G)\n• Грошева Александра (11E)\n• Тюлюова Сара (11E)',

        'ministry_media': 'Министерство Медии',
        'ministry_media_goal': 'Цель: фото- и видеосъёмка мероприятий, ведение соцсетей и медиа-контента.',
        'ministry_media_minister': 'Министр: Чукушева Томирис (11E)',
        'ministry_media_vice': 'Вице-министры:\n• Сварова Лейла (11F)\n• Алибеков Досым (11C)',

        'ministry_culture': 'Министерство Культуры',
        'ministry_culture_goal': 'Цель: развитие культурных ценностей, организация праздников и традиционных мероприятий.',
        'ministry_culture_minister': 'Министр: Самет Диас (10A)',
        'ministry_culture_vice': 'Вице-министры:\n• Магзум Алем (10G)\n• Оразбай Томирис (9H)',

        'ministry_sport': 'Министерство Спорта',
        'ministry_sport_goal': 'Цель: популяризация спорта, организация соревнований и спортивных мероприятий.',
        'ministry_sport_minister': 'Министр: Бауржанұлы Ералы (10G)',
        'ministry_sport_vice': 'Вице-министры:\n• Амиржанов Габиден (10H)\n• Асылханұлы Дәулет (10G)',

        'ministry_ecology': 'Министерство Экологии',
        'ministry_ecology_goal': 'Цель: забота об окружающей среде, экологические акции и проекты.',
        'ministry_ecology_minister': 'Министр: Кубышева Фахрие (11D)',
        'ministry_ecology_vice': 'Вице-министр:\n• Беремкулова Дайне (10D)',

        'ministry_dev': 'Министерство Развития',
        'ministry_dev_goal': 'Цель: развитие школьных инициатив (таких как - клубы), новых идей и проектов.',
        'ministry_dev_minister': 'Министр: Ағабек Жомарт (11G)',

        'ministry_justice': 'Министерство Юстиции',
        'ministry_justice_goal': 'Цель: соблюдение правил, школьной дисциплины и справедливости.',
        'ministry_justice_minister': 'Министр: Суннатов Заңғар (11G)',

        'science_house': 'Science House',
        'science_house_goal': 'Цель: развитие научной деятельности, исследовательских проектов и интереса к науке.',
        'science_house_minister': 'Министр: Ержанулы Жангир (11K)',
        'science_house_vice': 'Вице-министр:\n• Тохтахунов Тимур (10K)',

        'olympiad_house': 'Olympiad House',
        'olympiad_house_goal': 'Цель: подготовка учеников к олимпиадам и интеллектуальным конкурсам.',
        'olympiad_house_minister': 'Министр: Токарев Александр (10K)',
        'olympiad_house_vice': 'Вице-министр:\n• Кутырев Ратмир (10K)',

        'startup_house': 'StartUp House',
        'startup_house_goal': 'Цель: развитие предпринимательского мышления и стартап-проектов среди учеников.',
        'startup_house_minister': 'Министр: Ткаченко Владислав (11E)',
        'startup_house_vice': 'Вице-министры:\n• Лугма Арафат (11K)\n• Турлыбек Альнур (10K)',
      };
    } else if (languageCode == 'kk') {
      return {
        'title': 'Мектеп кеңесі',
        'description': 'Мектеп кеңесі — бұл мектептің белсенді оқушыларын біріктіретін оқушылардың өзін-өзі басқару органы. Ол оқушылардың мүдделерін қорғауға, мектептік іс-шараларды ұйымдастыруға, бастамаларды дамытуға және мектеп өмірін қызықтырақ әрі ыңғайлырақ етуге көмектеседі.',
        'principle': 'Мектеп кеңесі министрліктер принципі бойынша жұмыс істейді. Әр министрлік өз бағыты үшін жауапты, ал басында министрлер мен олардың орынбасарлары (вице-министрлер) тұрады.',
        'leadership': 'Мектеп кеңесінің басшылығы',
        'president': 'Президент: Өмірзақ Саният (10G)',
        'vice_president': 'Вице-президент: Ербол Бекарыс (11C)',
        'prime_ministers': 'Премьер-министрлер:\n• Пернебаев Альтаир (11K)\n• Қарымсақ Хабиби (11A)',
        'ministries': 'Министрліктер',

        'ministry_art': 'Өнер және Дизайн министрлігі',
        'ministry_art_goal': 'Мақсаты: мектепті безендіру, декорациялар, афишалар және креативті жобалар құру.',
        'ministry_art_minister': 'Министр: Бауржан Алтынай (10D)',
        'ministry_art_vice': 'Вице-министрлер:\n• Тетенкова Адель (10F)\n• Заплавнова Дарья (11K)',

        'ministry_comm': 'Коммуникация министрлігі',
        'ministry_comm_goal': 'Мақсаты: оқушылар арасындағы байланыс, іс-шараларды, хабарландыруларды ұйымдастыру және оқушыларға таратулар арқылы ақпарат беру.',
        'ministry_comm_minister': 'Министрлер:\n• Сұлтан Шуақ (10G)\n• Грошева Александра (11E)\n• Тюлюова Сара (11E)',

        'ministry_media': 'Медиа министрлігі',
        'ministry_media_goal': 'Мақсаты: іс-шаралардың фото және бейнетүсірілімі, әлеуметтік желілер мен медиа-контентті басқару.',
        'ministry_media_minister': 'Министр: Чукушева Томирис (11E)',
        'ministry_media_vice': 'Вице-министрлер:\n• Сварова Лейла (11F)\n• Алибеков Досым (11C)',

        'ministry_culture': 'Мәдениет министрлігі',
        'ministry_culture_goal': 'Мақсаты: мәдени құндылықтарды дамыту, мерекелер мен дәстүрлі іс-шараларды ұйымдастыру.',
        'ministry_culture_minister': 'Министр: Самет Диас (10A)',
        'ministry_culture_vice': 'Вице-министрлер:\n• Магзум Алем (10G)\n• Оразбай Томирис (9H)',

        'ministry_sport': 'Спорт министрлігі',
        'ministry_sport_goal': 'Мақсаты: спортты танымал ету, жарыстар мен спорттық іс-шараларды ұйымдастыру.',
        'ministry_sport_minister': 'Министр: Бауржанұлы Ералы (10G)',
        'ministry_sport_vice': 'Вице-министрлер:\n• Амиржанов Габиден (10H)\n• Асылханұлы Дәулет (10G)',

        'ministry_ecology': 'Экология министрлігі',
        'ministry_ecology_goal': 'Мақсаты: қоршаған ортаны қорғау, экологиялық акциялар мен жобалар.',
        'ministry_ecology_minister': 'Министр: Кубышева Фахрие (11D)',
        'ministry_ecology_vice': 'Вице-министр:\n• Беремкулова Дайне (10D)',

        'ministry_dev': 'Даму министрлігі',
        'ministry_dev_goal': 'Мақсаты: мектептік бастамаларды (мысалы, клубтар), жаңа идеялар мен жобаларды дамыту.',
        'ministry_dev_minister': 'Министр: Ағабек Жомарт (11G)',

        'ministry_justice': 'Әділет министрлігі',
        'ministry_justice_goal': 'Мақсаты: ережелерді, мектеп тәртібін және әділдікті сақтау.',
        'ministry_justice_minister': 'Министр: Суннатов Заңғар (11G)',

        'science_house': 'Science House',
        'science_house_goal': 'Мақсаты: ғылыми қызметті, зерттеу жобаларын және ғылымға деген қызығушылықты дамыту.',
        'science_house_minister': 'Министр: Ержанулы Жангир (11K)',
        'science_house_vice': 'Вице-министр:\n• Тохтахунов Тимур (10K)',

        'olympiad_house': 'Olympiad House',
        'olympiad_house_goal': 'Мақсаты: оқушыларды олимпиадаларға және интеллектуалды байқауларға дайындау.',
        'olympiad_house_minister': 'Министр: Токарев Александр (10K)',
        'olympiad_house_vice': 'Вице-министр:\n• Кутырев Ратмир (10K)',

        'startup_house': 'StartUp House',
        'startup_house_goal': 'Мақсаты: оқушылар арасында кәсіпкерлік ойлауды және стартап-жобаларды дамыту.',
        'startup_house_minister': 'Министр: Ткаченко Владислав (11E)',
        'startup_house_vice': 'Вице-министрлер:\n• Лугма Арафат (11K)\n• Турлыбек Альнур (10K)',
      };
    } else {
      // English
      return {
        'title': 'School Council',
        'description': 'The School Council is a student self-government body that unites active students of the school. It helps protect student interests, organizes school events, develops initiatives, and makes school life more interesting and comfortable.',
        'principle': 'The School Council operates on the principle of ministries. Each ministry is responsible for its own direction, and is headed by ministers and their deputies (vice-ministers).',
        'leadership': 'School Council Leadership',
        'president': 'President: Өmіrzaq Sanіyat (10G)',
        'vice_president': 'Vice President: Erbol Bekarys (11C)',
        'prime_ministers': 'Prime Ministers:\n• Pernebaev Altair (11K)\n• Qarymsaq Habibi (11A)',
        'ministries': 'Ministries',

        'ministry_art': 'Ministry of Art and Design',
        'ministry_art_goal': 'Goal: school decoration, creation of decorations, posters and creative projects.',
        'ministry_art_minister': 'Minister: Baurzhan Altynai (10D)',
        'ministry_art_vice': 'Vice-Ministers:\n• Tetenkova Adel (10F)\n• Zaplavnova Daria (11K)',

        'ministry_comm': 'Ministry of Communication',
        'ministry_comm_goal': 'Goal: communication between students, organization of events, announcements and informing students through newsletters.',
        'ministry_comm_minister': 'Ministers:\n• Sultan Shuaq (10G)\n• Grosheva Alexandra (11E)\n• Tyulyuova Sara (11E)',

        'ministry_media': 'Ministry of Media',
        'ministry_media_goal': 'Goal: photo and video shooting of events, social media and media content management.',
        'ministry_media_minister': 'Minister: Chukusheva Tomiris (11E)',
        'ministry_media_vice': 'Vice-Ministers:\n• Svarova Leila (11F)\n• Alibekov Dosym (11C)',

        'ministry_culture': 'Ministry of Culture',
        'ministry_culture_goal': 'Goal: development of cultural values, organization of holidays and traditional events.',
        'ministry_culture_minister': 'Minister: Samet Dias (10A)',
        'ministry_culture_vice': 'Vice-Ministers:\n• Magzum Alem (10G)\n• Orazbay Tomiris (9H)',

        'ministry_sport': 'Ministry of Sport',
        'ministry_sport_goal': 'Goal: popularization of sports, organization of competitions and sports events.',
        'ministry_sport_minister': 'Minister: Baurzhanuly Eraly (10G)',
        'ministry_sport_vice': 'Vice-Ministers:\n• Amirzhanov Gabiden (10H)\n• Asylkhanuly Daulet (10G)',

        'ministry_ecology': 'Ministry of Ecology',
        'ministry_ecology_goal': 'Goal: environmental protection, environmental actions and projects.',
        'ministry_ecology_minister': 'Minister: Kubysheva Fakhrie (11D)',
        'ministry_ecology_vice': 'Vice-Minister:\n• Beremkulova Daine (10D)',

        'ministry_dev': 'Ministry of Development',
        'ministry_dev_goal': 'Goal: development of school initiatives (such as clubs), new ideas and projects.',
        'ministry_dev_minister': 'Minister: Agabek Zhomart (11G)',

        'ministry_justice': 'Ministry of Justice',
        'ministry_justice_goal': 'Goal: compliance with rules, school discipline and justice.',
        'ministry_justice_minister': 'Minister: Sunnatov Zangar (11G)',

        'science_house': 'Science House',
        'science_house_goal': 'Goal: development of scientific activities, research projects and interest in science.',
        'science_house_minister': 'Minister: Yerzhanuly Zhangir (11K)',
        'science_house_vice': 'Vice-Minister:\n• Tokhtakhunov Timur (10K)',

        'olympiad_house': 'Olympiad House',
        'olympiad_house_goal': 'Goal: preparing students for olympiads and intellectual competitions.',
        'olympiad_house_minister': 'Minister: Tokarev Alexander (10K)',
        'olympiad_house_vice': 'Vice-Minister:\n• Kutyrev Ratmir (10K)',

        'startup_house': 'StartUp House',
        'startup_house_goal': 'Goal: development of entrepreneurial thinking and startup projects among students.',
        'startup_house_minister': 'Minister: Tkachenko Vladislav (11E)',
        'startup_house_vice': 'Vice-Ministers:\n• Lugma Arafat (11K)\n• Turlybek Alnur (10K)',
      };
    }
  }
}
