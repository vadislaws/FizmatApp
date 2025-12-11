class BookInfo {
  final String name;
  final String group;
  final String image;
  final String downloadPage;
  final String previewPage;

  BookInfo({
    required this.name,
    required this.group,
    required this.image,
    required this.downloadPage,
    required this.previewPage,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      name: json['name'] as String,
      group: json['group'] as String,
      image: json['image'] as String,
      downloadPage: json['download_page'] as String,
      previewPage: json['preview_page'] as String,
    );
  }
}
