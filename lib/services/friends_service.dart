import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizmat_app/models/friend_request_model.dart';
import 'package:fizmat_app/models/user_model.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send friend request
  Future<void> sendFriendRequest(String fromUid, String toUid) async {
    // Check if already friends or request exists
    final existing = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUid)
        .where('toUserId', isEqualTo: toUid)
        .get();

    if (existing.docs.isNotEmpty) throw Exception('Request already sent');

    await _firestore.collection('friend_requests').add({
      'fromUserId': fromUid,
      'toUserId': toUid,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId, String fromUid, String toUid) async {
    final batch = _firestore.batch();

    // Update request status
    batch.update(_firestore.collection('friend_requests').doc(requestId), {
      'status': 'accepted',
    });

    // Add to friends subcollections
    batch.set(_firestore.collection('users').doc(fromUid).collection('friends').doc(toUid), {
      'uid': toUid,
      'addedAt': DateTime.now().toIso8601String(),
    });

    batch.set(_firestore.collection('users').doc(toUid).collection('friends').doc(fromUid), {
      'uid': fromUid,
      'addedAt': DateTime.now().toIso8601String(),
    });

    // Update friend counts
    batch.update(_firestore.collection('users').doc(fromUid), {
      'friendCount': FieldValue.increment(1),
    });
    batch.update(_firestore.collection('users').doc(toUid), {
      'friendCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'declined',
    });
  }

  /// Remove friend
  Future<void> removeFriend(String uid, String friendUid) async {
    final batch = _firestore.batch();

    batch.delete(_firestore.collection('users').doc(uid).collection('friends').doc(friendUid));
    batch.delete(_firestore.collection('users').doc(friendUid).collection('friends').doc(uid));

    batch.update(_firestore.collection('users').doc(uid), {
      'friendCount': FieldValue.increment(-1),
    });
    batch.update(_firestore.collection('users').doc(friendUid), {
      'friendCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Get pending friend requests for a user
  Stream<List<FriendRequestModel>> getPendingRequests(String uid) {
    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get friends list
  Stream<List<String>> getFriendsList(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Get friend user data
  Future<List<UserModel>> getFriendsData(List<String> friendIds) async {
    if (friendIds.isEmpty) return [];

    final docs = await Future.wait(
      friendIds.map((id) => _firestore.collection('users').doc(id).get()),
    );

    return docs
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromMap(doc.data()!))
        .toList();
  }

  /// Get a single user by ID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Get friend recommendations for a user
  /// Priority: 1) Friends of friends, 2) Classmates, 3) Parallel classes, 4) Others
  Future<List<UserModel>> getFriendRecommendations({
    required String uid,
    required int? userGrade,
    required String? userLetter,
    int limit = 20,
  }) async {
    // Get current friends list
    final friendsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();
    final currentFriendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();
    currentFriendIds.add(uid); // Exclude self

    // Get pending requests (both sent and received)
    final sentRequests = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    final receivedRequests = await _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final pendingUserIds = <String>{};
    for (final doc in sentRequests.docs) {
      pendingUserIds.add(doc.data()['toUserId'] as String);
    }
    for (final doc in receivedRequests.docs) {
      pendingUserIds.add(doc.data()['fromUserId'] as String);
    }

    final excludeIds = {...currentFriendIds, ...pendingUserIds};
    final recommendations = <UserModel>[];
    final addedIds = <String>{};

    // 1. Friends of friends
    for (final friendId in currentFriendIds) {
      if (friendId == uid) continue;

      final friendOfFriendsSnapshot = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .limit(10)
          .get();

      for (final doc in friendOfFriendsSnapshot.docs) {
        final fofId = doc.id;
        if (!excludeIds.contains(fofId) && !addedIds.contains(fofId)) {
          final userDoc = await _firestore.collection('users').doc(fofId).get();
          if (userDoc.exists) {
            recommendations.add(UserModel.fromMap(userDoc.data()!));
            addedIds.add(fofId);
            if (recommendations.length >= limit) break;
          }
        }
      }
      if (recommendations.length >= limit) break;
    }

    // 2. Classmates (same grade + same letter)
    if (recommendations.length < limit && userGrade != null && userLetter != null) {
      final classmatesSnapshot = await _firestore
          .collection('users')
          .where('classGradeNumber', isEqualTo: userGrade)
          .where('classLetter', isEqualTo: userLetter)
          .limit(limit - recommendations.length + 5)
          .get();

      for (final doc in classmatesSnapshot.docs) {
        final userId = doc.id;
        if (!excludeIds.contains(userId) && !addedIds.contains(userId)) {
          recommendations.add(UserModel.fromMap(doc.data()));
          addedIds.add(userId);
          if (recommendations.length >= limit) break;
        }
      }
    }

    // 3. Parallel classes (same grade, different letter)
    if (recommendations.length < limit && userGrade != null) {
      final parallelSnapshot = await _firestore
          .collection('users')
          .where('classGradeNumber', isEqualTo: userGrade)
          .limit(limit - recommendations.length + 10)
          .get();

      for (final doc in parallelSnapshot.docs) {
        final userId = doc.id;
        if (!excludeIds.contains(userId) && !addedIds.contains(userId)) {
          recommendations.add(UserModel.fromMap(doc.data()));
          addedIds.add(userId);
          if (recommendations.length >= limit) break;
        }
      }
    }

    // 4. Other users (if still need more)
    if (recommendations.length < limit) {
      final othersSnapshot = await _firestore
          .collection('users')
          .limit(limit - recommendations.length + 20)
          .get();

      for (final doc in othersSnapshot.docs) {
        final userId = doc.id;
        if (!excludeIds.contains(userId) && !addedIds.contains(userId)) {
          recommendations.add(UserModel.fromMap(doc.data()));
          addedIds.add(userId);
          if (recommendations.length >= limit) break;
        }
      }
    }

    return recommendations.take(limit).toList();
  }

  /// Check if a friend request is pending between two users
  Future<bool> hasPendingRequest(String fromUid, String toUid) async {
    final sent = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUid)
        .where('toUserId', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (sent.docs.isNotEmpty) return true;

    final received = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: toUid)
        .where('toUserId', isEqualTo: fromUid)
        .where('status', isEqualTo: 'pending')
        .get();

    return received.docs.isNotEmpty;
  }

  /// Check if two users are friends
  Future<bool> areFriends(String uid1, String uid2) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid1)
        .collection('friends')
        .doc(uid2)
        .get();
    return doc.exists;
  }
}
