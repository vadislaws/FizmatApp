import 'package:fizmat_app/models/book.dart';

class BookData {
  static final List<Map<String, dynamic>> _booksJson = [
    {
      "name": "Алгебра",
      "group": "7",
      "image": "https://okulyk.kz/wp-content/books/1513/1513.jpg",
      "download_page": "https://okulyk.kz/algebra/1513/",
      "preview_page": "https://okulyk.kz/wp-content/books/1513/1513.jpg"
    },
  ];

  static List<BookInfo> getAllBooks() {
    return _booksJson.map((json) => BookInfo.fromJson(json)).toList();
  }

  static List<BookInfo> getBooksByGroup(String group) {
    return getAllBooks().where((book) => book.group == group).toList();
  }

  static List<String> getAllGroups() {
    final groups = getAllBooks().map((book) => book.group).toSet().toList();
    groups.sort((a, b) {
      // Put numeric grades first
      final aIsNum = int.tryParse(a) != null;
      final bIsNum = int.tryParse(b) != null;
      if (aIsNum && bIsNum) return int.parse(a).compareTo(int.parse(b));
      if (aIsNum) return -1;
      if (bIsNum) return 1;
      return a.compareTo(b);
    });
    return groups;
  }
}
