class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'declined'

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.status,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return FriendRequestModel(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
