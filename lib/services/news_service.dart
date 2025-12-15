import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/models/news_model.dart';

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

  /// Create news (admin only)
  Future<void> createNews({
    required String title,
    required String content,
    required String createdBy,
    required String createdByName,
    String? imageUrl,
  }) async {
    await _firestore.collection('news').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
    });
  }

  /// Delete news (admin only)
  Future<void> deleteNews(String newsId) async {
    await _firestore.collection('news').doc(newsId).delete();
  }

  /// Update news (admin only)
  Future<void> updateNews({
    required String newsId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    await _firestore.collection('news').doc(newsId).update({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    });
  }
}
