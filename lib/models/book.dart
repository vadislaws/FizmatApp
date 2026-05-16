class BookInfo {
  final Map<String, String> names;
  final String group;
  final String image;
  final String pdfUrl;
  final String previewPage;
  final String language;

  BookInfo({
    required this.names,
    required this.group,
    required this.image,
    required this.pdfUrl,
    required this.previewPage,
    this.language = 'kk',
  });

  String getName(String languageCode) {
    return names[languageCode] ?? names['ru'] ?? names['en'] ?? names.values.first;
  }

  /// CDN image URL from books.okulyk.kz, works for both old and new image field formats
  String get s3ImageUrl {
    final match = RegExp(r'okulyk\.kz/(?:wp-content/books/)?(\d+)/').firstMatch(image);
    if (match != null) {
      final id = match.group(1);
      return 'https://books.okulyk.kz/$id/$id.jpg';
    }
    return '';
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    Map<String, String> nameMap;
    if (json['names'] is Map) {
      nameMap = Map<String, String>.from(json['names'] as Map);
    } else if (json['name'] is String) {
      final n = json['name'] as String;
      nameMap = {'en': n, 'ru': n, 'kk': n};
    } else {
      nameMap = {'en': 'Unknown', 'ru': 'Неизвестно', 'kk': 'Белгісіз'};
    }

    final pdfUrl = (json['pdf_url'] as String?) ??
                   (json['download_page'] as String?) ?? '';

    return BookInfo(
      names: nameMap,
      group: json['group']?.toString() ?? 'Other',
      image: (json['image'] as String?) ?? '',
      pdfUrl: pdfUrl,
      previewPage: (json['preview_page'] as String?) ?? '',
      language: (json['language'] as String?) ?? 'kk',
    );
  }
}
