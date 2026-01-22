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
    DateTime? expiresAt,
  }) async {
    final now = DateTime.now();
    final expiry = expiresAt ?? now.add(const Duration(days: 30));

    await _firestore.collection('notifications').add({
      'title': title,
      'message': message,
      'createdAt': now.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'type': type,
      'iconName': iconName,
      'expiresAt': expiry.toIso8601String(),
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

  /// Get all users with birthday today
  Future<List<UserModel>> getUsersWithBirthdayToday() async {
    final now = DateTime.now();

    final allUsers = await _firestore.collection('users').get();

    final birthdayUsers = <UserModel>[];

    debugPrint('🎂 Checking birthdays for ${now.month}/${now.day}');
    debugPrint('📊 Total users: ${allUsers.docs.length}');

    for (final doc in allUsers.docs) {
      try {
        final user = UserModel.fromMap(doc.data());

        if (user.birthday != null) {
          debugPrint('👤 User ${user.fullName}: birthday ${user.birthday!.month}/${user.birthday!.day}');

          // Simply compare month and day, ignore year
          if (user.birthday!.month == now.month && user.birthday!.day == now.day) {
            debugPrint('🎉 Found birthday user: ${user.fullName} (${user.birthday})');
            birthdayUsers.add(user);
          }
        }
      } catch (e) {
        // Skip users with invalid data
        debugPrint('⚠️ Error parsing user: $e');
        continue;
      }
    }

    debugPrint('✅ Birthday users found: ${birthdayUsers.length}');
    return birthdayUsers;
  }

  /// Create birthday notifications for users with birthday today
  /// Should be called once per day (e.g., at midnight or app startup)
  Future<void> createBirthdayNotifications() async {
    debugPrint('🚀 Starting createBirthdayNotifications()');

    final birthdayUsers = await getUsersWithBirthdayToday();

    if (birthdayUsers.isEmpty) {
      debugPrint('ℹ️ No birthday users found today');
      return;
    }

    debugPrint('🎂 Found ${birthdayUsers.length} users with birthdays today');

    // Check if we already created birthday notifications today
    // Fetch all birthday-type notifications and filter in code to avoid complex Firestore queries
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    debugPrint('📅 Checking for existing notifications from ${todayStart.toIso8601String()}');

    try {
      final allBirthdayNotifications = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'birthday')
          .get();

      debugPrint('📊 Total birthday notifications in database: ${allBirthdayNotifications.docs.length}');

      // Filter for notifications created today
      final todayBirthdayNotifications = allBirthdayNotifications.docs.where((doc) {
        final data = doc.data();
        if (data['createdAt'] == null) return false;

        try {
          final createdAt = DateTime.parse(data['createdAt']);
          final isToday = createdAt.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
              createdAt.isBefore(todayEnd);

          if (isToday) {
            debugPrint('📋 Found existing notification created at ${createdAt.toIso8601String()}');
          }

          return isToday;
        } catch (e) {
          debugPrint('⚠️ Error parsing notification createdAt: $e');
          return false;
        }
      }).toList();

      debugPrint('📊 Birthday notifications created today: ${todayBirthdayNotifications.length}');

      // If we already created birthday notifications today, skip
      if (todayBirthdayNotifications.isNotEmpty) {
        debugPrint('⚠️ Birthday notifications already created today, skipping');
        return;
      }
    } catch (e) {
      debugPrint('❌ Error checking existing notifications: $e');
      // Continue anyway - better to potentially create duplicates than to skip
    }

    // Create birthday notifications for each user
    debugPrint('✍️ Creating birthday notifications for ${birthdayUsers.length} users...');
    int successCount = 0;

    for (final user in birthdayUsers) {
      const title = '🎉 День рождения!';
      final message = 'Сегодня день рождения у ${user.fullName}! Поздравьте их! 🎂';

      debugPrint('📝 Creating notification for ${user.fullName}');

      try {
        await createNotification(
          title: title,
          message: message,
          createdBy: 'system',
          createdByName: 'System',
          type: 'birthday',
          iconName: 'cake',
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        successCount++;
        debugPrint('✅ Notification created for ${user.fullName} (${successCount}/${birthdayUsers.length})');
      } catch (e) {
        debugPrint('❌ Error creating notification for ${user.fullName}: $e');
      }
    }

    debugPrint('🎉 Birthday notification creation complete! Created $successCount out of ${birthdayUsers.length}');
  }
}
