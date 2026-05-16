import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/models/notification_model.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:flutter/material.dart';

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

  /// Get notifications for a specific user (filtered by target)
  Stream<List<NotificationModel>> getNotificationsForUser({
    required String userId,
    int? userGrade,
    String? userLetter,
  }) {
    return getAllNotifications().map((notifications) {
      return notifications.where((notification) {
        return notification.shouldShowToUser(
          userId: userId,
          userGrade: userGrade,
          userLetter: userLetter,
        );
      }).toList();
    });
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

  /// Create notification with targeting support
  Future<void> createNotification({
    required String title,
    required String message,
    Map<String, String>? titles,
    Map<String, String>? messages,
    required String createdBy,
    required String createdByName,
    String type = 'announcement',
    String? iconName,
    DateTime? expiresAt,
    NotificationTarget targetType = NotificationTarget.all,
    int? targetGrade,
    String? targetLetter,
    String? targetUserId,
  }) async {
    final now = DateTime.now();
    final expiry = expiresAt ?? now.add(const Duration(days: 30));

    await _firestore.collection('notifications').add({
      'title': title,
      'message': message,
      if (titles != null && titles.isNotEmpty) 'titles': titles,
      if (messages != null && messages.isNotEmpty) 'messages': messages,
      'createdAt': now.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'type': type,
      'iconName': iconName,
      'expiresAt': expiry.toIso8601String(),
      'targetType': targetType.name,
      'targetGrade': targetGrade,
      'targetLetter': targetLetter,
      'targetUserId': targetUserId,
    });
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Check if user can delete notification (creator or moderator)
  bool canDeleteNotification(NotificationModel notification, UserModel user) {
    // Moderators can delete any notification
    if (user.position == 'moderator' || user.position == 'admin') {
      return true;
    }
    // Creators can delete their own notifications
    return notification.createdBy == user.uid;
  }

  /// Update notification
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

  /// Delete expired notifications (based on expiresAt field)
  Future<void> cleanupExpiredNotifications() async {
    final now = DateTime.now();

    final expiredNotifications = await _firestore
        .collection('notifications')
        .where('expiresAt', isLessThan: now.toIso8601String())
        .get();

    final batch = _firestore.batch();
    for (final doc in expiredNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Search users for targeting
  Future<List<UserModel>> searchUsersForTarget(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final results = await _firestore.collection('users').get();

    return results.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.fullName.toLowerCase().contains(queryLower))
        .take(10)
        .toList();
  }

  /// Get all users with birthday today
  Future<List<UserModel>> getUsersWithBirthdayToday() async {
    final now = DateTime.now();

    final allUsers = await _firestore.collection('users').get();

    final birthdayUsers = <UserModel>[];

    debugPrint('Checking birthdays for ${now.month}/${now.day}');
    debugPrint('Total users: ${allUsers.docs.length}');

    for (final doc in allUsers.docs) {
      try {
        final user = UserModel.fromMap(doc.data());

        if (user.birthday != null) {
          // Skip grade 12 / graduated students
          if (user.classGradeNumber == 12) continue;
          if (user.birthday!.month == now.month && user.birthday!.day == now.day) {
            debugPrint('Found birthday user: ${user.fullName} (${user.birthday})');
            birthdayUsers.add(user);
          }
        }
      } catch (e) {
        continue;
      }
    }

    debugPrint('Birthday users found: ${birthdayUsers.length}');
    return birthdayUsers;
  }

  /// Create birthday notifications for users with birthday today
  Future<void> createBirthdayNotifications() async {
    debugPrint('Starting createBirthdayNotifications()');

    final birthdayUsers = await getUsersWithBirthdayToday();

    if (birthdayUsers.isEmpty) {
      debugPrint('No birthday users found today');
      return;
    }

    debugPrint('Found ${birthdayUsers.length} users with birthdays today');

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    try {
      final allBirthdayNotifications = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'birthday')
          .get();

      final todayBirthdayNotifications = allBirthdayNotifications.docs.where((doc) {
        final data = doc.data();
        if (data['createdAt'] == null) return false;

        try {
          final createdAt = DateTime.parse(data['createdAt']);
          return createdAt.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
              createdAt.isBefore(todayEnd);
        } catch (e) {
          return false;
        }
      }).toList();

      if (todayBirthdayNotifications.isNotEmpty) {
        debugPrint('Birthday notifications already created today, skipping');
        return;
      }
    } catch (e) {
      debugPrint('Error checking existing notifications: $e');
    }

    debugPrint('Creating birthday notifications for ${birthdayUsers.length} users...');
    int successCount = 0;

    for (final user in birthdayUsers) {
      const title = 'День рождения!';
      final message = 'Сегодня день рождения у ${user.fullName}! Поздравьте их!';

      try {
        await createNotification(
          title: title,
          message: message,
          titles: {
            'ru': 'День рождения!',
            'kk': 'Туған күн!',
            'en': 'Birthday!',
          },
          messages: {
            'ru': 'Сегодня день рождения у ${user.fullName}! Поздравьте их!',
            'kk': 'Бүгін ${user.fullName} туған күні! Оларды құттықтаңыз!',
            'en': "Today is ${user.fullName}'s birthday! Wish them well!",
          },
          createdBy: 'system',
          createdByName: 'System',
          type: 'birthday',
          iconName: 'cake',
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        successCount++;
        debugPrint('Notification created for ${user.fullName} ($successCount/${birthdayUsers.length})');
      } catch (e) {
        debugPrint('Error creating notification for ${user.fullName}: $e');
      }
    }

    debugPrint('Birthday notification creation complete! Created $successCount out of ${birthdayUsers.length}');
  }
}
