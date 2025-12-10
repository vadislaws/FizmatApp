/// Models for School Clubs

enum ClubCategory {
  academic,
  sports,
  artsAndCulture,
  technology,
  social,
  hobbies,
  language,
  other,
}

extension ClubCategoryExtension on ClubCategory {
  String get displayNameEn {
    switch (this) {
      case ClubCategory.academic:
        return 'Academic';
      case ClubCategory.sports:
        return 'Sports & Fitness';
      case ClubCategory.artsAndCulture:
        return 'Arts & Culture';
      case ClubCategory.technology:
        return 'Technology';
      case ClubCategory.social:
        return 'Social & Leadership';
      case ClubCategory.hobbies:
        return 'Hobbies & Games';
      case ClubCategory.language:
        return 'Languages';
      case ClubCategory.other:
        return 'Other';
    }
  }

  String get displayNameRu {
    switch (this) {
      case ClubCategory.academic:
        return 'Академические';
      case ClubCategory.sports:
        return 'Спорт и фитнес';
      case ClubCategory.artsAndCulture:
        return 'Искусство и культура';
      case ClubCategory.technology:
        return 'Технологии';
      case ClubCategory.social:
        return 'Социальные и лидерство';
      case ClubCategory.hobbies:
        return 'Хобби и игры';
      case ClubCategory.language:
        return 'Языки';
      case ClubCategory.other:
        return 'Другое';
    }
  }

  String get displayNameKk {
    switch (this) {
      case ClubCategory.academic:
        return 'Академиялық';
      case ClubCategory.sports:
        return 'Спорт және фитнес';
      case ClubCategory.artsAndCulture:
        return 'Өнер және мәдениет';
      case ClubCategory.technology:
        return 'Технологиялар';
      case ClubCategory.social:
        return 'Әлеуметтік және көшбасшылық';
      case ClubCategory.hobbies:
        return 'Хобби және ойындар';
      case ClubCategory.language:
        return 'Тілдер';
      case ClubCategory.other:
        return 'Басқа';
    }
  }

  String getDisplayName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return displayNameRu;
      case 'kk':
        return displayNameKk;
      default:
        return displayNameEn;
    }
  }
}

class ClubLeader {
  final String firstName;
  final String lastName;
  final String phone;
  final String classGrade;

  ClubLeader({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.classGrade,
  });

  String get fullName => '$firstName $lastName';
}

class Club {
  final String name; // Club name stays in original language
  final String? description;
  final String? instagramHandle;
  final ClubLeader leader;
  final ClubCategory category;

  Club({
    required this.name,
    this.description,
    this.instagramHandle,
    required this.leader,
    required this.category,
  });

  String get instagramUrl {
    if (instagramHandle == null) return '';
    final handle = instagramHandle!.replaceAll('@', '');
    return 'https://instagram.com/$handle';
  }
}
