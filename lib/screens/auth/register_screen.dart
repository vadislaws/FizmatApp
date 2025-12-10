import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/providers/locale_provider.dart';
import 'package:fizmat_app/widgets/language_switcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(l10n, theme),
                const SizedBox(height: 20),
                const LanguageSwitcher(),
                const SizedBox(height: 30),
                _buildForm(l10n, authProvider, theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n, ThemeData theme) {
    return Text(
      l10n.registerTitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildForm(
      AppLocalizations l10n, AuthProvider authProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildNameField(l10n, theme),
            const SizedBox(height: 16),
            _buildEmailField(l10n, theme),
            const SizedBox(height: 16),
            _buildPasswordField(l10n, theme),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(l10n, theme),
            const SizedBox(height: 20),
            _buildRegisterButton(l10n, authProvider),
            const SizedBox(height: 16),
            _buildLoginLink(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(AppLocalizations l10n, ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.fullName,
        prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.nameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(AppLocalizations l10n, ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.email,
        prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.emailRequired;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.invalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n, ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.password,
        prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.passwordRequired;
        }
        if (value.length < 6) {
          return l10n.passwordTooShort;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n, ThemeData theme) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.confirmPassword,
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.passwordRequired;
        }
        if (value != _passwordController.text) {
          return l10n.passwordsDontMatch;
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () => _handleRegister(authProvider, l10n),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.createAccount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.haveAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            l10n.signInLink,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister(
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get current language from LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final language = localeProvider.locale.languageCode;

    final success = await authProvider.createUserWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      language,
    );

    if (success && mounted) {
      // Show localized success message
      if (authProvider.successCode != null) {
        final successMessage = l10n.getSuccessMessage(authProvider.successCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Redirect to email verification screen
      Navigator.pushReplacementNamed(
        context,
        '/email_verification',
      );
    } else if (mounted && authProvider.errorCode != null) {
      // Show localized error message
      final errorMessage = l10n.getAuthErrorMessage(authProvider.errorCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
