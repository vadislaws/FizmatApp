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

class Formula {
  final String nameEn;
  final String nameRu;
  final String nameKk;
  final String formulaLatex;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionKk;
  final FormulaSubject subject;
  final String topic;

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
}
