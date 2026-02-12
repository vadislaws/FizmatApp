/// Models for Formula Book

enum FormulaSubject {
  mathematics,
  physics,
  chemistry,
}

extension FormulaSubjectExtension on FormulaSubject {
  String get displayName {
    switch (this) {
      case FormulaSubject.mathematics:
        return 'Mathematics';
      case FormulaSubject.physics:
        return 'Physics';
      case FormulaSubject.chemistry:
        return 'Chemistry';
    }
  }

  String get displayNameRu {
    switch (this) {
      case FormulaSubject.mathematics:
        return 'Математика';
      case FormulaSubject.physics:
        return 'Физика';
      case FormulaSubject.chemistry:
        return 'Химия';
    }
  }

  String get displayNameKk {
    switch (this) {
      case FormulaSubject.mathematics:
        return 'Математика';
      case FormulaSubject.physics:
        return 'Физика';
      case FormulaSubject.chemistry:
        return 'Химия';
    }
  }
}

/// Topic translations map
const Map<String, Map<String, String>> _topicTranslations = {
  'Algebra': {'ru': 'Алгебра', 'kk': 'Алгебра'},
  'Geometry': {'ru': 'Геометрия', 'kk': 'Геометрия'},
  'Trigonometry': {'ru': 'Тригонометрия', 'kk': 'Тригонометрия'},
  'Sequences': {'ru': 'Прогрессии', 'kk': 'Прогрессиялар'},
  'Logarithms': {'ru': 'Логарифмы', 'kk': 'Логарифмдер'},
  'Calculus': {'ru': 'Мат. анализ', 'kk': 'Мат. талдау'},
  'Statistics': {'ru': 'Статистика', 'kk': 'Статистика'},
  'Probability': {'ru': 'Вероятность', 'kk': 'Ықтималдық'},
  'Mechanics': {'ru': 'Механика', 'kk': 'Механика'},
  'Electricity': {'ru': 'Электричество', 'kk': 'Электр'},
  'Thermodynamics': {'ru': 'Термодинамика', 'kk': 'Термодинамика'},
  'Circular Motion': {'ru': 'Круговое движение', 'kk': 'Дөңгелек қозғалыс'},
  'Gravitation': {'ru': 'Гравитация', 'kk': 'Гравитация'},
  'Waves': {'ru': 'Волны', 'kk': 'Толқындар'},
  'Optics': {'ru': 'Оптика', 'kk': 'Оптика'},
  'Magnetism': {'ru': 'Магнетизм', 'kk': 'Магнетизм'},
  'Modern Physics': {'ru': 'Совр. физика', 'kk': 'Қаз. физика'},
  'General': {'ru': 'Общая', 'kk': 'Жалпы'},
  'Stoichiometry': {'ru': 'Стехиометрия', 'kk': 'Стехиометрия'},
  'Acids and Bases': {'ru': 'Кислоты и основания', 'kk': 'Қышқылдар мен негіздер'},
  'Chemical Equilibrium': {'ru': 'Хим. равновесие', 'kk': 'Хим. тепе-теңдік'},
  'Solutions': {'ru': 'Растворы', 'kk': 'Ерітінділер'},
  'Gas Laws': {'ru': 'Газовые законы', 'kk': 'Газ заңдары'},
  'Kinetics': {'ru': 'Кинетика', 'kk': 'Кинетика'},
  'Electrochemistry': {'ru': 'Электрохимия', 'kk': 'Электрохимия'},
  'Thermochemistry': {'ru': 'Термохимия', 'kk': 'Термохимия'},
};

/// Get translated topic name
String getTopicTranslation(String topic, String languageCode) {
  if (languageCode == 'en') return topic;
  return _topicTranslations[topic]?[languageCode] ?? topic;
}

/// Get all unique topics with translations for a given language
Map<String, String> getAllTopicTranslations(String languageCode) {
  if (languageCode == 'en') {
    return {for (final key in _topicTranslations.keys) key: key};
  }
  return {
    for (final entry in _topicTranslations.entries)
      entry.key: entry.value[languageCode] ?? entry.key
  };
}

class Formula {
  final String nameEn;
  final String nameRu;
  final String nameKk;
  final String formulaLatex;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionKk;
  final FormulaSubject subject;
  final String topic; // English key for filtering

  Formula({
    required this.nameEn,
    required this.nameRu,
    required this.nameKk,
    required this.formulaLatex,
    this.descriptionEn,
    this.descriptionRu,
    this.descriptionKk,
    required this.subject,
    required this.topic,
  });

  String getName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return nameRu;
      case 'kk':
        return nameKk;
      default:
        return nameEn;
    }
  }

  String? getDescription(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return descriptionRu;
      case 'kk':
        return descriptionKk;
      default:
        return descriptionEn;
    }
  }

  /// Get translated topic name
  String getTopic(String languageCode) {
    return getTopicTranslation(topic, languageCode);
  }
}
