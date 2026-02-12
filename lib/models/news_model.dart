/// News categories for filtering
enum NewsCategory {
  general,      // General news
  events,       // School events
  academic,     // Academic announcements
  sports,       // Sports news
  clubs,        // Club activities
  achievements, // Student/school achievements
  important,    // Important announcements
}

/// Get category translations
String getCategoryName(NewsCategory category, String languageCode) {
  const translations = {
    NewsCategory.general: {'en': 'General', 'ru': 'Общее', 'kk': 'Жалпы'},
    NewsCategory.events: {'en': 'Events', 'ru': 'Мероприятия', 'kk': 'Іс-шаралар'},
    NewsCategory.academic: {'en': 'Academic', 'ru': 'Учеба', 'kk': 'Оқу'},
    NewsCategory.sports: {'en': 'Sports', 'ru': 'Спорт', 'kk': 'Спорт'},
    NewsCategory.clubs: {'en': 'Clubs', 'ru': 'Кружки', 'kk': 'Үйірмелер'},
    NewsCategory.achievements: {'en': 'Achievements', 'ru': 'Достижения', 'kk': 'Жетістіктер'},
    NewsCategory.important: {'en': 'Important', 'ru': 'Важное', 'kk': 'Маңызды'},
  };
  return translations[category]?[languageCode] ?? translations[category]?['en'] ?? category.name;
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String createdBy; // Admin UID who created this
  final String createdByName; // Admin name for display
  final NewsCategory category;
  final List<String> links; // External links (Google Forms, etc.)
  final List<String> linkTitles; // Titles for links

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    this.category = NewsCategory.general,
    this.links = const [],
    this.linkTitles = const [],
  });

  factory NewsModel.fromMap(Map<String, dynamic> map, String id) {
    return NewsModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Admin',
      category: NewsCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => NewsCategory.general,
      ),
      links: List<String>.from(map['links'] ?? []),
      linkTitles: List<String>.from(map['linkTitles'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'category': category.name,
      'links': links,
      'linkTitles': linkTitles,
    };
  }

  /// Get formatted date string
  String getFormattedDate() {
    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
  }

  /// Get formatted time string
  String getFormattedTime() {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
