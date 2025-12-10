import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> sendVerificationCode(String email, String userId) async {
    try {
      if (!email.endsWith('@fizmat.kz')) {
        throw Exception('Only @fizmat.kz emails are allowed');
      }

      final code = _generateVerificationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      await _firestore.collection('verification_codes').doc(userId).set({
        'email': email,
        'code': code,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'used': false,
      });

      print('Verification code for $email: $code');
      print('Code expires at: $expiresAt');
    } catch (e) {
      print('Error sending verification code: $e');
      rethrow;
    }
  }

  Future<bool> verifyCode(String userId, String code) async {
    try {
      final docSnapshot =
          await _firestore.collection('verification_codes').doc(userId).get();

      if (!docSnapshot.exists) {
        return false;
      }

      final data = docSnapshot.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);
      final used = data['used'] as bool;

      if (used) {
        return false;
      }

      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      if (storedCode == code) {
        await _firestore.collection('verification_codes').doc(userId).update({
          'used': true,
        });
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  Future<String?> getStoredEmail(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('verification_codes').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['email'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting stored email: $e');
      return null;
    }
  }
}
