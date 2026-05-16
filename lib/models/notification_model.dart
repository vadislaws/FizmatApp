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
  final Map<String, String> titles;
  final Map<String, String> messages;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;
  final String type;
  final String? iconName;
  final DateTime? expiresAt;

  // Targeting fields
  final NotificationTarget targetType;
  final int? targetGrade;
  final String? targetLetter;
  final String? targetUserId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    Map<String, String>? titles,
    Map<String, String>? messages,
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
  })  : titles = titles ?? {},
        messages = messages ?? {},
        expiresAt = expiresAt ?? createdAt.add(const Duration(days: 30));

  String getLocalizedTitle(String languageCode) {
    return titles[languageCode] ?? titles['ru'] ?? titles['en'] ?? title;
  }

  String getLocalizedMessage(String languageCode) {
    return messages[languageCode] ?? messages['ru'] ?? messages['en'] ?? message;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now();

    Map<String, String> parseTitles(dynamic raw) {
      if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
      return {};
    }

    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      titles: parseTitles(map['titles']),
      messages: parseTitles(map['messages']),
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
      if (titles.isNotEmpty) 'titles': titles,
      if (messages.isNotEmpty) 'messages': messages,
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
