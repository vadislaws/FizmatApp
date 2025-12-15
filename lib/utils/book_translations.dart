class BookTranslations {
  static final Map<String, Map<String, String>> _translations = {
    // Kazakh Language
    'Қазақ тілі': {
      'en': 'Kazakh Language',
      'ru': 'Казахский язык',
      'kk': 'Қазақ тілі',
    },
    // Kazakh Literature
    'Қазақ әдебиеті': {
      'en': 'Kazakh Literature',
      'ru': 'Казахская литература',
      'kk': 'Қазақ әдебиеті',
    },
    // Russian Language and Literature
    'Орыс тілі және әдебиеті': {
      'en': 'Russian Language and Literature',
      'ru': 'Русский язык и литература',
      'kk': 'Орыс тілі және әдебиеті',
    },
    // Algebra
    'Алгебра': {
      'en': 'Algebra',
      'ru': 'Алгебра',
      'kk': 'Алгебра',
    },
    // Geometry
    'Геометрия': {
      'en': 'Geometry',
      'ru': 'Геометрия',
      'kk': 'Геометрия',
    },
    // Geography
    'География': {
      'en': 'Geography',
      'ru': 'География',
      'kk': 'География',
    },
    // Computer Science
    'Информатика': {
      'en': 'Computer Science',
      'ru': 'Информатика',
      'kk': 'Информатика',
    },
    // Physics
    'Физика': {
      'en': 'Physics',
      'ru': 'Физика',
      'kk': 'Физика',
    },
    // Chemistry
    'Химия': {
      'en': 'Chemistry',
      'ru': 'Химия',
      'kk': 'Химия',
    },
    // Biology
    'Биология': {
      'en': 'Biology',
      'ru': 'Биология',
      'kk': 'Биология',
    },
    // World History
    'Дүниежүзі тарихы': {
      'en': 'World History',
      'ru': 'Всемирная история',
      'kk': 'Дүниежүзі тарихы',
    },
    // Kazakhstan History
    'Қазақстан тарихы': {
      'en': 'Kazakhstan History',
      'ru': 'История Казахстана',
      'kk': 'Қазақстан тарихы',
    },
    // English Language
    'Ағылшын тілі': {
      'en': 'English Language',
      'ru': 'Английский язык',
      'kk': 'Ағылшын тілі',
    },
    // Natural Science
    'Жаратылыстану': {
      'en': 'Natural Science',
      'ru': 'Естествознание',
      'kk': 'Жаратылыстану',
    },
    // Basics of Law
    'Құқық негіздері': {
      'en': 'Basics of Law',
      'ru': 'Основы права',
      'kk': 'Құқық негіздері',
    },
    // Self-Knowledge
    'Өзін-өзі тану': {
      'en': 'Self-Knowledge',
      'ru': 'Самопознание',
      'kk': 'Өзін-өзі тану',
    },
    // Physical Culture
    'Дене шынықтыру': {
      'en': 'Physical Education',
      'ru': 'Физическая культура',
      'kk': 'Дене шынықтыру',
    },
  };

  /// Get translated book name based on language code
  static String getTranslatedName(String originalName, String languageCode) {
    // Check if we have a translation for this book name
    if (_translations.containsKey(originalName)) {
      return _translations[originalName]![languageCode] ?? originalName;
    }

    // If no translation found, return original name
    return originalName;
  }

  /// Get all translations for a book name
  static Map<String, String>? getAllTranslations(String originalName) {
    return _translations[originalName];
  }
}
