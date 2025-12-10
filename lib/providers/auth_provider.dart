import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/services/auth_service.dart';
import 'package:fizmat_app/services/email_verification_service.dart';
import 'package:fizmat_app/services/storage_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final EmailVerificationService _emailVerificationService =
      EmailVerificationService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;  // Store error code for localization
  String? _successMessage;
  String? _successCode;  // Store success code for localization

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;  // Getter for error code
  String? get successMessage => _successMessage;
  String? get successCode => _successCode;  // Getter for success code
  bool get isAuthenticated => _userModel != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _userModel = await _authService.getUserData(user.uid);
        notifyListeners();
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        _userModel = user;
        _setLoading(false);
        return true;
      }

      // If user is null but no exception was thrown, something went wrong
      _setError('Sign in failed. Please try again.', 'sign-in-failed');
      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      _setError(e.message, e.code);  // Pass error code for localization
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.', 'unknown-error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String language,
  ) async {
    try {
      _setLoading(true);
      _clearError();
      _clearSuccess();

      final result = await _authService.createUserWithEmailAndPassword(
        email,
        password,
        fullName,
        language,
      );

      if (result != null) {
        // User created but NOT in Firestore yet - needs verification
        _setSuccess('Verification email sent', code: 'verification-email-sent');
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      // Handle re-registration attempt
      if (e.code == 'email-not-verified-retry') {
        _setSuccess('Verification email sent', code: 'verification-email-sent');
        _setLoading(false);
        return true; // Redirect to verification screen
      }
      _setError(e.message, e.code);  // Pass error code for localization
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again', 'unknown-error');
      _setLoading(false);
      return false;
    }
  }

  /// Create Firestore document after email verification
  Future<bool> createVerifiedUserDocument() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      _userModel = await _authService.createVerifiedUserDocument(user.uid);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, e.code);  // Pass error code for localization
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      _clearSuccess();

      await _authService.sendEmailVerification();
      _setSuccess('Verification email sent', code: 'verification-email-sent');
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message, e.code);  // Pass error code for localization
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send verification email', 'send-email-failed');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      _clearSuccess();

      await _authService.sendPasswordResetEmail(email);
      _setSuccess('Password reset email sent', code: 'password-reset-sent');
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message, e.code);  // Pass error code for localization
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send password reset email', 'send-email-failed');
      _setLoading(false);
      return false;
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      if (_userModel != null) {
        _userModel = await _authService.getUserData(_userModel!.uid);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail
    }
  }

  // Legacy methods for fizmat email verification (backward compatibility)
  Future<bool> sendVerificationCode(String fizmatEmail) async {
    try {
      _setLoading(true);
      _clearError();

      if (_userModel == null) {
        _setError('User not logged in');
        _setLoading(false);
        return false;
      }

      await _emailVerificationService.sendVerificationCode(
        fizmatEmail,
        _userModel!.uid,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send verification code: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    try {
      _setLoading(true);
      _clearError();

      if (_userModel == null) {
        _setError('User not logged in');
        _setLoading(false);
        return false;
      }

      final isValid = await _emailVerificationService.verifyCode(
        _userModel!.uid,
        code,
      );

      if (isValid) {
        _userModel = await _authService.getUserData(_userModel!.uid);
        _setLoading(false);
        return true;
      }

      _setError('Invalid verification code');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to verify code: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    int? classGradeNumber,
    String? classLetter,
    bool? isPrivate,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      _clearSuccess();

      final user = _authService.currentUser;
      if (user == null) {
        _setError('User not logged in', 'user-not-found');
        _setLoading(false);
        return false;
      }

      final updatedUser = await _authService.updateUserProfile(
        uid: user.uid,
        fullName: fullName,
        username: username,
        bio: bio,
        classGradeNumber: classGradeNumber,
        classLetter: classLetter,
        isPrivate: isPrivate,
        avatarUrl: avatarUrl,
      );

      _userModel = updatedUser;
      _setSuccess('Profile updated', code: 'profile-updated');
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message, e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update profile', 'update-failed');
      _setLoading(false);
      return false;
    }
  }

  /// Check if username is available
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      return await _authService.isUsernameAvailable(username, user.uid);
    } catch (e) {
      return false;
    }
  }

  /// Validate username format
  bool validateUsername(String username) {
    return _authService.isUsernameValid(username);
  }

  /// Update Kundelik data
  Future<bool> updateKundelikData({
    required bool isConnected,
    double? gpa,
    DateTime? birthday,
    Map<String, dynamic>? kundelikData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _authService.currentUser;
      if (user == null) {
        _setError('User not logged in', 'user-not-found');
        _setLoading(false);
        return false;
      }

      await _authService.updateKundelikData(
        uid: user.uid,
        isConnected: isConnected,
        gpa: gpa,
        birthday: birthday,
        kundelikData: kundelikData,
      );

      // Reload user data
      _userModel = await _authService.getUserData(user.uid);
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update Kundelik data', 'update-failed');
      _setLoading(false);
      return false;
    }
  }

  /// Upload avatar
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      _setLoading(true);
      final storageService = StorageService();
      final url = await storageService.uploadAvatar(_userModel!.uid, imageFile);

      // Update user profile with new avatar URL
      await updateProfile(avatarUrl: url);

      _setLoading(false);
      return url;
    } catch (e) {
      _setLoading(false);
      return null;
    }
  }

  /// Search users (for friends/admin)
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _authService.searchUsers(query);
    } catch (e) {
      return [];
    }
  }

  /// Update user role (admin only)
  Future<bool> updateUserRole(String targetUid, String newRole) async {
    try {
      _setLoading(true);
      final user = _authService.currentUser;
      if (user == null) return false;

      await _authService.updateUserRole(
        adminUid: user.uid,
        targetUid: targetUid,
        newRole: newRole,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userModel = null;
      _clearError();
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message, e.code);  // Pass error code for localization
    } catch (e) {
      _setError('Failed to sign out.', 'sign-out-error');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message, [String? code]) {
    _errorMessage = message;
    _errorCode = code;  // Save error code for localization
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _errorCode = null;  // Also clear error code
  }

  void _setSuccess(String message, {String? code}) {
    _successMessage = message;
    _successCode = code;  // Save success code for localization
    notifyListeners();
  }

  void _clearSuccess() {
    _successMessage = null;
    _successCode = null;  // Also clear success code
  }
}
