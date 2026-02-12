/// Target audience type for notifications
enum NotificationTarget {
  all,        // All users
  grade,      // Specific grade (e.g., all 10th graders)
  gradeClass, // Specific class (e.g., 10A)
  user,       // Specific user
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String createdBy; // Admin UID who created this
  final String createdByName; // Admin name for display
  final String type; // e.g., 'announcement', 'event', 'alert', 'birthday'
  final String? iconName; // Icon name for display
  final DateTime? expiresAt; // When notification should be deleted (default: 30 days from creation)

  // Targeting fields
  final NotificationTarget targetType;
  final int? targetGrade;      // Grade number (7-11)
  final String? targetLetter;   // Class letter (A-K)
  final String? targetUserId;   // Specific user ID

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    this.type = 'announcement',
    this.iconName,
    DateTime? expiresAt,
    this.targetType = NotificationTarget.all,
    this.targetGrade,
    this.targetLetter,
    this.targetUserId,
  }) : expiresAt = expiresAt ?? createdAt.add(const Duration(days: 30));

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now();

    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: createdAt,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Admin',
      type: map['type'] ?? 'announcement',
      iconName: map['iconName'],
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : createdAt.add(const Duration(days: 30)),
      targetType: NotificationTarget.values.firstWhere(
        (e) => e.name == map['targetType'],
        orElse: () => NotificationTarget.all,
      ),
      targetGrade: map['targetGrade'],
      targetLetter: map['targetLetter'],
      targetUserId: map['targetUserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'type': type,
      'iconName': iconName,
      'expiresAt': expiresAt?.toIso8601String(),
      'targetType': targetType.name,
      'targetGrade': targetGrade,
      'targetLetter': targetLetter,
      'targetUserId': targetUserId,
    };
  }

  /// Check if notification should be shown to a specific user
  bool shouldShowToUser({
    required String userId,
    int? userGrade,
    String? userLetter,
  }) {
    switch (targetType) {
      case NotificationTarget.all:
        return true;
      case NotificationTarget.grade:
        return targetGrade != null && userGrade == targetGrade;
      case NotificationTarget.gradeClass:
        return targetGrade != null &&
               targetLetter != null &&
               userGrade == targetGrade &&
               userLetter == targetLetter;
      case NotificationTarget.user:
        return targetUserId == userId;
    }
  }
}
