class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String createdBy; // Admin UID who created this
  final String createdByName; // Admin name for display
  final String type; // e.g., 'announcement', 'event', 'alert'
  final String? iconName; // Icon name for display

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    this.type = 'announcement',
    this.iconName,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Admin',
      type: map['type'] ?? 'announcement',
      iconName: map['iconName'],
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
    };
  }
}
