import 'dart:convert';
import 'package:fizmat_app/models/book.dart';
import 'package:flutter/services.dart';

class BookService {
  /// Fetch all books from bundled asset
  static Future<List<BookInfo>> fetchBooks() async {
    try {
      final jsonString = await rootBundle.loadString('assets/book_list.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((j) => BookInfo.fromJson(j)).toList();
    } catch (e) {
      throw Exception('Error loading books: $e');
    }
  }

  /// Get unique grade groups (7–11) from books list
  static List<String> getUniqueGroups(List<BookInfo> books) {
    final groups = <String>{};
    for (final book in books) {
      final gradeNumber = int.tryParse(book.group);
      if (gradeNumber != null && gradeNumber >= 7 && gradeNumber <= 11) {
        groups.add(book.group);
      }
    }
    final groupList = groups.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    return groupList;
  }
}
