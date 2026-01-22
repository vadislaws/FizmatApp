import 'dart:convert';
import 'package:fizmat_app/models/book.dart';
import 'package:http/http.dart' as http;

class BookService {
  // GitHub raw JSON URL
  static const String _githubUrl =
      'https://raw.githubusercontent.com/vadislaws/FizmatApp/main/data/book_list.json';

  /// Fetch all books from GitHub
  /// Throws exception if network fails
  static Future<List<BookInfo>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(_githubUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load books: HTTP ${response.statusCode}');
      }

      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => BookInfo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  /// Get unique groups from books list
  static List<String> getUniqueGroups(List<BookInfo> books) {
    final groups = <String>{};

    for (final book in books) {
      final group = book.group;
      // Check if it's a grade (7-11)
      final gradeNumber = int.tryParse(group);
      if (gradeNumber != null && gradeNumber >= 7 && gradeNumber <= 11) {
        groups.add(group);
      } else {
        // Not a standard grade, add to "Others"
        groups.add('Others');
      }
    }

    final groupList = groups.toList();
    groupList.sort((a, b) {
      // Sort numbers first, then "Others" last
      if (a == 'Others') return 1;
      if (b == 'Others') return -1;

      final aNum = int.tryParse(a);
      final bNum = int.tryParse(b);

      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      }

      return a.compareTo(b);
    });

    return groupList;
  }

  /// Filter books by group
  static List<BookInfo> filterByGroup(
    List<BookInfo> books,
    String selectedGroup,
  ) {
    return books.where((book) {
      if (selectedGroup == 'Others') {
        final gradeNumber = int.tryParse(book.group);
        return gradeNumber == null || gradeNumber < 7 || gradeNumber > 11;
      } else {
        return book.group == selectedGroup;
      }
    }).toList();
  }
}
