import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all notifications ordered by creation date (newest first)
  Stream<List<NotificationModel>> getAllNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get notifications with limit
  Stream<List<NotificationModel>> getNotificationsWithLimit(int limit) {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create notification (admin only)
  Future<void> createNotification({
    required String title,
    required String message,
    required String createdBy,
    required String createdByName,
    String type = 'announcement',
    String? iconName,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'type': type,
      'iconName': iconName,
    });
  }

  /// Delete notification (admin only)
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Update notification (admin only)
  Future<void> updateNotification({
    required String notificationId,
    required String title,
    required String message,
    String? type,
    String? iconName,
  }) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'title': title,
      'message': message,
      if (type != null) 'type': type,
      if (iconName != null) 'iconName': iconName,
    });
  }

  /// Delete notifications older than 30 days
  Future<void> cleanupOldNotifications() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final oldNotifications = await _firestore
        .collection('notifications')
        .where('createdAt', isLessThan: thirtyDaysAgo.toIso8601String())
        .get();

    final batch = _firestore.batch();
    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
