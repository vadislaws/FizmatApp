import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart' as app_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  Timer? _cooldownTimer;  // Separate timer for countdown
  bool _isResendingEmail = false;
  int _resendCooldown = 0;  // 30-second cooldown
  bool _isCreatingDocument = false;  // Prevent multiple Firestore creation attempts

  @override
  void initState() {
    super.initState();
    // Check email verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    if (_isCreatingDocument) return; // Debounce to prevent multiple attempts

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified && mounted) {
        _timer?.cancel();
        _isCreatingDocument = true;

        // IMPORTANT: Create Firestore document NOW (not during registration)
        final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
        final success = await authProvider.createVerifiedUserDocument();

        if (success && mounted) {
          // Successfully created Firestore document, navigate to home
          Navigator.pushReplacementNamed(context, '/FizNavBar');
        } else if (mounted) {
          // Failed to create Firestore document
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.verifyEmailCreateProfileFailed),
              backgroundColor: Colors.red,
            ),
          );
          await authProvider.signOut();
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResendingEmail) return;  // Debounce

    setState(() {
      _isResendingEmail = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.verifyEmailSentSuccess),
              backgroundColor: Colors.green,
            ),
          );

          // Start 30-second cooldown (not 60)
          setState(() {
            _resendCooldown = 30;
          });

          // Separate countdown timer
          _cooldownTimer?.cancel();
          _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_resendCooldown == 0 || !mounted) {
              timer.cancel();
            } else {
              setState(() {
                _resendCooldown--;
              });
            }
          });
        }
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage = l10n.verifyEmailSendFailed;
        if (e.code == 'too-many-requests') {
          errorMessage = l10n.verifyEmailTooManyRequests;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.verifyEmailSendError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.verifyEmailTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.verifyEmailSentTo,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.verifyEmailCheck,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.verifyEmailWaiting,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // IMPORTANT: Spam folder warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.verifyEmailSpamWarning,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.verifyEmailNoEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resendCooldown > 0 || _isResendingEmail
                        ? null
                        : _resendVerificationEmail,
                    child: _isResendingEmail
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _resendCooldown > 0
                                ? l10n.verifyEmailResendIn(_resendCooldown)
                                : l10n.verifyEmailResend,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final authProvider =
                        Provider.of<app_auth.AuthProvider>(context, listen: false);
                    await authProvider.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  child: Text(
                    l10n.verifyEmailBack,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
