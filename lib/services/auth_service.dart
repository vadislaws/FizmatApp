import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fizmat_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  /// Throws AuthException with user-friendly message
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Check if email is verified
        if (!user.emailVerified) {
          // Send verification email automatically on login attempt
          try {
            await user.sendEmailVerification();
          } catch (_) {
            // Ignore if email sending fails (rate limit, etc.)
          }
          // DON'T sign out - keep user logged in so EmailVerificationScreen works
          // The user will be redirected to EmailVerificationScreen
          throw AuthException('email-not-verified-login');
        }

        // Try to get user data from Firestore
        // If user document doesn't exist, create it now
        // This handles cases where users completed email verification
        // but the document wasn't created properly
        return await getUserData(user.uid) ?? await _createUserDocumentFromAuth(user);
      }

      return null;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw AuthException('unknown-error');
    }
  }

  /// Create user document from Firebase Auth user data
  /// Used when user logs in but Firestore document doesn't exist
  Future<UserModel> _createUserDocumentFromAuth(User user) async {
    try {
      // Check if pending_users has data
      final pendingDoc = await _firestore.collection('pending_users').doc(user.uid).get();

      String fullName = user.displayName ?? 'User';
      String language = 'en';

      if (pendingDoc.exists && pendingDoc.data() != null) {
        final pendingData = pendingDoc.data()!;
        fullName = pendingData['fullName'] ?? user.displayName ?? 'User';
        language = pendingData['language'] ?? 'en';

        // Delete pending user document
        try {
          await _firestore.collection('pending_users').doc(user.uid).delete();
        } catch (_) {
          // Ignore deletion errors - document will be cleaned up later
        }
      }

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        fullName: fullName,
        email: user.email ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        language: language,
      );

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('firestore-error');
    } catch (e) {
      throw AuthException('user-document-creation-failed');
    }
  }

  /// Create new user with email and password
  /// Stores user data in pending_users until email is verified
  Future<Map<String, dynamic>?> createUserWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String language,
  ) async {
    User? user;
    try {
      // Step 1: Create Firebase Auth user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      if (user == null) {
        throw AuthException('user-creation-failed');
      }

      // Step 2: Update display name
      await user.updateDisplayName(fullName);

      // Step 3: Store in pending_users (NOT in users yet!)
      await _createPendingUser(user.uid, fullName, email, language);

      // Step 4: Send email verification
      await user.sendEmailVerification();

      return {
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'needsVerification': true,
      };
    } on AuthException {
      // If anything fails, delete the auth user
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {}
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      // Handle email-already-in-use specially
      if (e.code == 'email-already-in-use') {
        // Check if user exists but is not verified
        final existingUser = await _checkUnverifiedUser(email);
        if (existingUser != null) {
          throw AuthException('email-not-verified-retry');
        }
      }
      throw AuthException(e.code);
    } catch (e) {
      // If anything fails, clean up the auth user
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {}
      }
      throw AuthException('unknown-error');
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  /// Reload current user to update emailVerified status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      // Ignore reload errors
    }
  }

  /// Store pending user data (before email verification)
  Future<void> _createPendingUser(
    String uid,
    String fullName,
    String email,
    String language,
  ) async {
    try {
      await _firestore.collection('pending_users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'language': language,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('firestore-error');
    } catch (e) {
      throw AuthException('firestore-error');
    }
  }

  /// Create user document in Firestore (after email verification)
  Future<UserModel> createVerifiedUserDocument(String uid) async {
    try {
      // Get data from pending_users
      final pendingDoc = await _firestore.collection('pending_users').doc(uid).get();

      if (!pendingDoc.exists || pendingDoc.data() == null) {
        throw AuthException('pending-user-not-found');
      }

      final pendingData = pendingDoc.data()!;

      final userModel = UserModel(
        uid: uid,
        fullName: pendingData['fullName'] ?? '',
        email: pendingData['email'] ?? '',
        createdAt: DateTime.parse(pendingData['createdAt'] ?? DateTime.now().toIso8601String()),
        language: pendingData['language'] ?? 'en',
      );

      // Create user document
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      // Delete pending user
      await _firestore.collection('pending_users').doc(uid).delete();

      return userModel;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('firestore-error');
    } catch (e) {
      throw AuthException('firestore-error');
    }
  }

  /// Check if email belongs to unverified user
  Future<Map<String, dynamic>?> _checkUnverifiedUser(String email) async {
    try {
      final users = await _auth.fetchSignInMethodsForEmail(email);
      if (users.isNotEmpty) {
        // Email exists, check if verified
        final userList = await _firestore
            .collection('pending_users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userList.docs.isNotEmpty) {
          return userList.docs.first.data();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('sign-out-error');
    }
  }

  /// Check if username is available (unique)
  Future<bool> isUsernameAvailable(String username, String currentUserId) async {
    try {
      // Username must be lowercase and trimmed
      final normalizedUsername = username.toLowerCase().trim();

      // Query Firestore for existing username
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: normalizedUsername)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // Username is available
      }

      // Check if the username belongs to current user
      final existingDoc = querySnapshot.docs.first;
      return existingDoc.id == currentUserId;
    } catch (e) {
      throw AuthException('username-check-failed');
    }
  }

  /// Validate username format
  bool isUsernameValid(String username) {
    // Username must be 3-20 characters
    if (username.length < 3 || username.length > 20) {
      return false;
    }

    // Username can only contain letters, numbers, and underscores
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String uid,
    String? fullName,
    String? username,
    String? bio,
    int? classGradeNumber,
    String? classLetter,
    bool? isPrivate,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (fullName != null) updates['fullName'] = fullName;
      if (username != null) {
        // Validate username format
        if (!isUsernameValid(username)) {
          throw AuthException('username-invalid');
        }

        // Check username availability
        final isAvailable = await isUsernameAvailable(username, uid);
        if (!isAvailable) {
          throw AuthException('username-taken');
        }

        updates['username'] = username.toLowerCase().trim();
      }
      if (bio != null) updates['bio'] = bio;
      if (classGradeNumber != null) updates['classGradeNumber'] = classGradeNumber;
      if (classLetter != null) updates['classLetter'] = classLetter;
      if (isPrivate != null) updates['isPrivate'] = isPrivate;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

      // Update Firestore document
      await _firestore.collection('users').doc(uid).update(updates);

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw AuthException('user-not-found');
      }

      return updatedUser;
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('update-failed');
    } catch (e) {
      throw AuthException('update-failed');
    }
  }

  /// Update Kundelik connection status and data
  Future<void> updateKundelikData({
    required String uid,
    required bool isConnected,
    double? gpa,
    DateTime? birthday,
    Map<String, dynamic>? kundelikData,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'kundelikConnected': isConnected,
        'lastKundelikSync': DateTime.now().toIso8601String(),
      };

      if (gpa != null) updates['gpa'] = gpa;
      if (birthday != null) updates['birthday'] = birthday.toIso8601String();
      if (kundelikData != null) updates['kundelikData'] = kundelikData;

      await _firestore.collection('users').doc(uid).update(updates);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('update-failed');
    } catch (e) {
      throw AuthException('update-failed');
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole({
    required String adminUid,
    required String targetUid,
    required String newRole,
  }) async {
    try {
      // Check if admin is actually admin
      final adminDoc = await _firestore.collection('users').doc(adminUid).get();
      if (!adminDoc.exists || adminDoc.data()?['position'] != 'admin') {
        throw AuthException('permission-denied');
      }

      // Update target user's role
      await _firestore.collection('users').doc(targetUid).update({
        'position': newRole,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException('permission-denied');
      }
      throw AuthException('update-failed');
    } catch (e) {
      throw AuthException('update-failed');
    }
  }

  /// Search users by username (for admin panel and friend search)
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      final normalizedQuery = query.toLowerCase().trim();

      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: normalizedQuery)
          .where('username', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;

  AuthException(this.code);

  String get message {
    switch (code) {
      case 'user-not-found':
        return 'Account does not exist';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'network-request-failed':
        return 'No internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'email-not-verified':
        return 'Please verify your email before signing in';
      case 'email-not-verified-login':
        return 'Email not verified. We sent a verification email. Please check your inbox.';
      case 'email-not-verified-retry':
        return 'Email already registered but not verified. Please check your inbox';
      case 'pending-user-not-found':
        return 'Registration data not found. Please register again';
      case 'permission-denied':
        return 'Cannot save user data. Please try again later';
      case 'firestore-error':
        return 'Cannot save user data. Please try again later';
      case 'user-creation-failed':
        return 'Failed to create account. Please try again';
      case 'sign-out-error':
        return 'Failed to sign out. Please try again';
      case 'username-invalid':
        return 'Username can only contain letters, numbers, and underscores';
      case 'username-taken':
        return 'This username is already taken';
      case 'username-check-failed':
        return 'Failed to check username availability. Please try again';
      case 'update-failed':
        return 'Failed to update profile. Please try again';
      case 'user-document-creation-failed':
        return 'Failed to create user profile. Please try again';
      case 'unknown-error':
        return 'An unexpected error occurred. Please try again';
      default:
        return 'An error occurred: $code';
    }
  }

  @override
  String toString() => message;
}
