class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final String language;
  final String? avatarUrl;
  final String? username;  // Unique username (@username)
  final String? bio;  // User bio
  final int? classGradeNumber;  // Class grade (7-11, null for Graduated)
  final String? classLetter;  // Class letter (A-K)
  final String position;  // Role: student, teacher, director, school_government, admin
  final bool isPrivate;  // Profile privacy
  final bool kundelikConnected;  // Is Kundelik connected
  final double? gpa;  // GPA from Kundelik
  final DateTime? birthday;  // Birthday from Kundelik
  final DateTime? lastKundelikSync;  // Last Kundelik sync time
  final int friendCount;  // Number of friends
  final Map<String, dynamic>? kundelikData;  // Additional Kundelik data

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.language,
    this.avatarUrl,
    this.username,
    this.bio,
    this.classGradeNumber,
    this.classLetter,
    this.position = 'student',  // Default role
    this.isPrivate = false,  // Default: public profile
    this.kundelikConnected = false,  // Default: not connected
    this.gpa,
    this.birthday,
    this.lastKundelikSync,
    this.friendCount = 0,
    this.kundelikData,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      language: map['language'] ?? 'en',
      avatarUrl: map['avatarUrl'],
      username: map['username'],
      bio: map['bio'],
      classGradeNumber: map['classGradeNumber'],
      classLetter: map['classLetter'],
      position: map['position'] ?? 'student',
      isPrivate: map['isPrivate'] ?? false,
      kundelikConnected: map['kundelikConnected'] ?? false,
      gpa: map['gpa']?.toDouble(),
      birthday: map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      lastKundelikSync: map['lastKundelikSync'] != null ? DateTime.parse(map['lastKundelikSync']) : null,
      friendCount: map['friendCount'] ?? 0,
      kundelikData: map['kundelikData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'language': language,
      'avatarUrl': avatarUrl,
      'username': username,
      'bio': bio,
      'classGradeNumber': classGradeNumber,
      'classLetter': classLetter,
      'position': position,
      'isPrivate': isPrivate,
      'kundelikConnected': kundelikConnected,
      'gpa': gpa,
      'birthday': birthday?.toIso8601String(),
      'lastKundelikSync': lastKundelikSync?.toIso8601String(),
      'friendCount': friendCount,
      'kundelikData': kundelikData,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    DateTime? createdAt,
    String? language,
    String? avatarUrl,
    String? username,
    String? bio,
    int? classGradeNumber,
    String? classLetter,
    String? position,
    bool? isPrivate,
    bool? kundelikConnected,
    double? gpa,
    DateTime? birthday,
    DateTime? lastKundelikSync,
    int? friendCount,
    Map<String, dynamic>? kundelikData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      classGradeNumber: classGradeNumber ?? this.classGradeNumber,
      classLetter: classLetter ?? this.classLetter,
      position: position ?? this.position,
      isPrivate: isPrivate ?? this.isPrivate,
      kundelikConnected: kundelikConnected ?? this.kundelikConnected,
      gpa: gpa ?? this.gpa,
      birthday: birthday ?? this.birthday,
      lastKundelikSync: lastKundelikSync ?? this.lastKundelikSync,
      friendCount: friendCount ?? this.friendCount,
      kundelikData: kundelikData ?? this.kundelikData,
    );
  }

  // Helper to get formatted class (e.g., "9A" or "Graduated")
  String get formattedClass {
    if (classGradeNumber == null) return 'Graduated';
    if (classLetter == null) return classGradeNumber.toString();
    return '$classGradeNumber$classLetter';
  }
}
