import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/providers/kundelik/kundelik_auth.dart';
import 'package:fizmat_app/services/kundelik_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KundelikConnectScreen extends StatefulWidget {
  const KundelikConnectScreen({super.key});

  @override
  State<KundelikConnectScreen> createState() => _KundelikConnectScreenState();
}

class _KundelikConnectScreenState extends State<KundelikConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.connectKundelik),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Icon
                Icon(
                  Icons.school,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  l10n.connectKundelik,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  l10n.translate('kundelik_login_description'),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('kundelik_username'),
                    hintText: l10n.translate('kundelik_username_hint'),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    hintText: l10n.translate('enter_kundelik_password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                // Connect button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleConnect,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.connect,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Create Kundelik API instance and authenticate
      final kunAPI = KunAPI(
        login: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get authentication token
      final accessToken = await kunAPI.getToken(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      kunAPI.token = accessToken;

      // Sync full data including GPA
      final fullData = await kunAPI.syncFullData();

      // Save session via session manager (also sets the in-memory _kunAPI)
      await KundelikSessionManager.instance.saveSession(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        token: accessToken,
      );

      // Extract GPA, birthday and class info
      final double? gpa = fullData['gpa']?.toDouble();
      final DateTime? birthday = fullData['birthday'];
      final int? classGradeNumber = fullData['classGradeNumber'] as int?;
      final String? classLetter = fullData['classLetter'] as String?;

      // Update user profile with Kundelik data
      await authProvider.updateKundelikData(
        isConnected: true,
        gpa: gpa,
        birthday: birthday,
        classGradeNumber: classGradeNumber,
        classLetter: classLetter,
        kundelikData: {
          'userInfo': fullData['userInfo'],
          'schoolInfo': fullData['schoolInfo'],
          'marksCount': fullData['marksCount'],
          'syncedAt': fullData['syncedAt'],
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success with GPA if available
        String message = l10n.kundelikConnected;
        if (gpa != null && gpa > 0) {
          message += ' | GPA: ${gpa.toStringAsFixed(2)}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on KunError catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage;
        final msg = e.message;
        if (msg == 'authorizationFailed' || msg.contains('authorizationFailed')) {
          errorMessage = l10n.translate('kundelik_error_invalid_credentials');
        } else if (msg.contains('maintenance') || msg.contains('HTML')) {
          errorMessage = l10n.translate('kundelik_error_maintenance');
        } else if (msg.contains('serverError:')) {
          errorMessage = l10n.translate('kundelik_error_api');
        } else {
          errorMessage = l10n.translate('kundelik_error_unknown');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage;
        final s = e.toString();
        if (s.contains('SocketException') || s.contains('NetworkException')) {
          errorMessage = l10n.translate('kundelik_error_no_internet');
        } else if (s.contains('TimeoutException')) {
          errorMessage = l10n.translate('kundelik_error_maintenance');
        } else {
          errorMessage = l10n.translate('kundelik_error_unknown');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
