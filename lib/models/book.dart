class BookInfo {
  final Map<String, String> names; // Multilingual support
  final String group;
  final String image;
  final String pdfUrl; // URL to the PDF file
  final String previewPage;
  final bool isWebView; // true = open in webview, false = direct PDF

  BookInfo({
    required this.names,
    required this.group,
    required this.image,
    required this.pdfUrl,
    required this.previewPage,
    this.isWebView = true, // Default to webview for compatibility
  });

  // Get name for specific language, fallback to English
  String getName(String languageCode) {
    return names[languageCode] ?? names['en'] ?? names.values.first;
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    // Handle both old format (single name string) and new format (multilingual names)
    Map<String, String> nameMap;
    if (json['names'] is Map) {
      nameMap = Map<String, String>.from(json['names'] as Map);
    } else if (json['name'] is String) {
      // Fallback for old format - use same name for all languages
      nameMap = {
        'en': json['name'] as String,
        'ru': json['name'] as String,
        'kk': json['name'] as String,
      };
    } else {
      nameMap = {'en': 'Unknown', 'ru': 'Неизвестно', 'kk': 'Белгісіз'};
    }

    // Handle both old format (download_page) and new format (pdf_url)
    final pdfUrl = (json['pdf_url'] as String?) ??
                   (json['download_page'] as String?) ?? '';

    return BookInfo(
      names: nameMap,
      group: json['group']?.toString() ?? 'Other',
      image: (json['image'] as String?) ?? '',
      pdfUrl: pdfUrl,
      previewPage: (json['preview_page'] as String?) ?? '',
      isWebView: (json['is_web_view'] as bool?) ?? true, // Default true
    );
  }
}
