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
}
