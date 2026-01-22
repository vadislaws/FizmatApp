/// Subject name translations for schedule
class SubjectTranslations {
  static String translate(String subject, String languageCode) {
    // Capitalize first letter
    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    final key = subject.trim().toLowerCase();

    final translations = <String, Map<String, String>>{
      // Mathematics
      'алгебра': {'ru': 'Алгебра', 'en': 'Algebra', 'kk': 'Алгебра'},
      'алгебра ж/е аб': {'ru': 'Алгебра и начала анализа', 'en': 'Algebra and Analysis', 'kk': 'Алгебра және талдау бастамалары'},
      'алгебра и на': {'ru': 'Алгебра и начала анализа', 'en': 'Algebra and Analysis', 'kk': 'Алгебра және талдау бастамалары'},
      'геометрия': {'ru': 'Геометрия', 'en': 'Geometry', 'kk': 'Геометрия'},

      // Sciences
      'физика': {'ru': 'Физика', 'en': 'Physics', 'kk': 'Физика'},
      'химия': {'ru': 'Химия', 'en': 'Chemistry', 'kk': 'Химия'},
      'биология': {'ru': 'Биология', 'en': 'Biology', 'kk': 'Биология'},
      'информатика': {'ru': 'Информатика', 'en': 'Computer Science', 'kk': 'Информатика'},

      // Languages
      'англ язык': {'ru': 'Английский язык', 'en': 'English Language', 'kk': 'Ағылшын тілі'},
      'англ язык (ф)': {'ru': 'Английский язык (физмат)', 'en': 'English (STEM)', 'kk': 'Ағылшын тілі (физмат)'},
      'англ. язык': {'ru': 'Английский язык', 'en': 'English Language', 'kk': 'Ағылшын тілі'},
      'англ. язык (ф)': {'ru': 'Английский язык (физмат)', 'en': 'English (STEM)', 'kk': 'Ағылшын тілі (физмат)'},
      'английский яз.': {'ru': 'Английский язык', 'en': 'English Language', 'kk': 'Ағылшын тілі'},
      'ағылшын т.': {'ru': 'Английский язык', 'en': 'English Language', 'kk': 'Ағылшын тілі'},
      'ағылшын т. (ф)': {'ru': 'Английский язык (физмат)', 'en': 'English (STEM)', 'kk': 'Ағылшын тілі (физмат)'},
      'ағылшын т.(ф)': {'ru': 'Английский язык (физмат)', 'en': 'English (STEM)', 'kk': 'Ағылшын тілі (физмат)'},
      'ағылшын тілі': {'ru': 'Английский язык', 'en': 'English Language', 'kk': 'Ағылшын тілі'},

      'рус. язык': {'ru': 'Русский язык', 'en': 'Russian Language', 'kk': 'Орыс тілі'},
      'рус. лит-ра': {'ru': 'Русская литература', 'en': 'Russian Literature', 'kk': 'Орыс әдебиеті'},
      'русс. лит-ра': {'ru': 'Русская литература', 'en': 'Russian Literature', 'kk': 'Орыс әдебиеті'},
      'орыс т/ә': {'ru': 'Русский язык/литература', 'en': 'Russian Language/Literature', 'kk': 'Орыс тілі/әдебиеті'},
      'орыс тілі': {'ru': 'Русский язык', 'en': 'Russian Language', 'kk': 'Орыс тілі'},

      'каз. яз и лит-а': {'ru': 'Казахский язык и литература', 'en': 'Kazakh Language and Literature', 'kk': 'Қазақ тілі мен әдебиеті'},
      'каз. яз и лит-ра': {'ru': 'Казахский язык и литература', 'en': 'Kazakh Language and Literature', 'kk': 'Қазақ тілі мен әдебиеті'},
      'каз. яз. и лит.': {'ru': 'Казахский язык и литература', 'en': 'Kazakh Language and Literature', 'kk': 'Қазақ тілі мен әдебиеті'},
      'каз. язык и лит.': {'ru': 'Казахский язык и литература', 'en': 'Kazakh Language and Literature', 'kk': 'Қазақ тілі мен әдебиеті'},
      'каз.яз и лит-а': {'ru': 'Казахский язык и литература', 'en': 'Kazakh Language and Literature', 'kk': 'Қазақ тілі мен әдебиеті'},
      'қазақ тілі': {'ru': 'Казахский язык', 'en': 'Kazakh Language', 'kk': 'Қазақ тілі'},
      'қазақ әдебиеті': {'ru': 'Казахская литература', 'en': 'Kazakh Literature', 'kk': 'Қазақ әдебиеті'},

      // History & Geography
      'ист. казахстана': {'ru': 'История Казахстана', 'en': 'History of Kazakhstan', 'kk': 'Қазақстан тарихы'},
      'қаз. тарихы': {'ru': 'История Казахстана', 'en': 'History of Kazakhstan', 'kk': 'Қазақстан тарихы'},
      'всем. история': {'ru': 'Всемирная история', 'en': 'World History', 'kk': 'Дүниежүзілік тарих'},
      'всемир. история': {'ru': 'Всемирная история', 'en': 'World History', 'kk': 'Дүниежүзілік тарих'},
      'дүн тарихы': {'ru': 'Всемирная история', 'en': 'World History', 'kk': 'Дүниежүзілік тарих'},
      'дүн. ж. тарихы': {'ru': 'Всемирная история', 'en': 'World History', 'kk': 'Дүниежүзілік тарих'},
      'дүн. тарихы': {'ru': 'Всемирная история', 'en': 'World History', 'kk': 'Дүниежүзілік тарих'},
      'география': {'ru': 'География', 'en': 'Geography', 'kk': 'География'},

      // Other subjects
      'глоб. комп.': {'ru': 'Глобальные компетенции', 'en': 'Global Competencies', 'kk': 'Жаһандық құзыреттіліктер'},
      'жаһанд. құз.': {'ru': 'Глобальные компетенции', 'en': 'Global Competencies', 'kk': 'Жаһандық құзыреттіліктер'},
      'основы права': {'ru': 'Основы права', 'en': 'Basics of Law', 'kk': 'Құқық негіздері'},
      'құқық негіз.': {'ru': 'Основы права', 'en': 'Basics of Law', 'kk': 'Құқық негіздері'},
      'құқық негіздері': {'ru': 'Основы права', 'en': 'Basics of Law', 'kk': 'Құқық негіздері'},

      // Physical Education & Arts
      'дене ш.': {'ru': 'Физкультура', 'en': 'Physical Education', 'kk': 'Дене шынықтыру'},
      'физ-ра': {'ru': 'Физкультура', 'en': 'Physical Education', 'kk': 'Дене шынықтыру'},
      'худ. труд': {'ru': 'Художественный труд', 'en': 'Art and Crafts', 'kk': 'Көркем еңбек'},
      'көркем еңбек': {'ru': 'Художественный труд', 'en': 'Art and Crafts', 'kk': 'Көркем еңбек'},

      // Class hour
      'класс. час': {'ru': 'Классный час', 'en': 'Class Hour', 'kk': 'Сынып сағаты'},
      'сынып сағ.': {'ru': 'Классный час', 'en': 'Class Hour', 'kk': 'Сынып сағаты'},
      'сынып сағаты': {'ru': 'Классный час', 'en': 'Class Hour', 'kk': 'Сынып сағаты'},

      // Military training
      'нвп': {'ru': 'НВП', 'en': 'Military Training', 'kk': 'ҰБД'},

      // AP Courses
      'ap cs': {'ru': 'AP Computer Science', 'en': 'AP Computer Science', 'kk': 'AP Computer Science'},
      'ap calc': {'ru': 'AP Calculus', 'en': 'AP Calculus', 'kk': 'AP Calculus'},
      'ap calculus': {'ru': 'AP Calculus', 'en': 'AP Calculus', 'kk': 'AP Calculus'},
      'ap engl': {'ru': 'AP English', 'en': 'AP English', 'kk': 'AP English'},
      'ap phys': {'ru': 'AP Physics', 'en': 'AP Physics', 'kk': 'AP Physics'},
      'ap physics': {'ru': 'AP Physics', 'en': 'AP Physics', 'kk': 'AP Physics'},

      // Preparation courses
      'ешп алгебра': {'ru': 'ЕШП Алгебра', 'en': 'UNT Algebra', 'kk': 'БТА Алгебра'},
      'ешп физика': {'ru': 'ЕШП Физика', 'en': 'UNT Physics', 'kk': 'БТА Физика'},
      'прз алгебра': {'ru': 'ПРЗ Алгебра', 'en': 'Lesson Consolidation Algebra', 'kk': 'ПРЗ Алгебра'},
      'прз физика': {'ru': 'ПРЗ Физика', 'en': 'Lesson Consolidation Physics', 'kk': 'ПРЗ Физика'},
      'подг. к ielts': {'ru': 'Подготовка к IELTS', 'en': 'IELTS Preparation', 'kk': 'IELTS-қа дайындық'},
      'ielts-қа д.': {'ru': 'Подготовка к IELTS', 'en': 'IELTS Preparation', 'kk': 'IELTS-қа дайындық'},
    };

    final lowerKey = key.toLowerCase();
    if (translations.containsKey(lowerKey)) {
      return translations[lowerKey]![languageCode] ?? capitalize(subject);
    }

    // If no translation found, return capitalized original
    return capitalize(subject);
  }
}
