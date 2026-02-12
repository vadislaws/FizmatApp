import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/models/news_model.dart';
import 'package:fizmat_app/models/user_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all news ordered by creation date (newest first)
  Stream<List<NewsModel>> getAllNews() {
    return _firestore
        .collection('news')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get news filtered by category
  Stream<List<NewsModel>> getNewsByCategory(NewsCategory category) {
    return _firestore
        .collection('news')
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get news with limit
  Stream<List<NewsModel>> getNewsWithLimit(int limit) {
    return _firestore
        .collection('news')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create news with category and links
  Future<void> createNews({
    required String title,
    required String content,
    required String createdBy,
    required String createdByName,
    String? imageUrl,
    NewsCategory category = NewsCategory.general,
    List<String> links = const [],
    List<String> linkTitles = const [],
  }) async {
    await _firestore.collection('news').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'category': category.name,
      'links': links,
      'linkTitles': linkTitles,
    });
  }

  /// Delete news
  Future<void> deleteNews(String newsId) async {
    await _firestore.collection('news').doc(newsId).delete();
  }

  /// Check if user can delete news (creator or moderator)
  bool canDeleteNews(NewsModel news, UserModel user) {
    // Moderators can delete any news
    if (user.position == 'moderator' || user.position == 'admin') {
      return true;
    }
    // Creators can delete their own news
    return news.createdBy == user.uid;
  }

  /// Update news
  Future<void> updateNews({
    required String newsId,
    required String title,
    required String content,
    String? imageUrl,
    NewsCategory? category,
    List<String>? links,
    List<String>? linkTitles,
  }) async {
    await _firestore.collection('news').doc(newsId).update({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      if (category != null) 'category': category.name,
      if (links != null) 'links': links,
      if (linkTitles != null) 'linkTitles': linkTitles,
    });
  }
}
