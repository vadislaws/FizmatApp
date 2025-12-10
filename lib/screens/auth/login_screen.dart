import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/widgets/language_switcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildLogo(theme, isDark),
                const SizedBox(height: 40),
                _buildTitle(l10n, theme),
                const SizedBox(height: 30),
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

  Widget _buildLogo(ThemeData theme, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          'F',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n, ThemeData theme) {
    return Text(
      l10n.loginTitle,
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
            _buildEmailField(l10n, theme),
            const SizedBox(height: 16),
            _buildPasswordField(l10n, theme),
            const SizedBox(height: 20),
            _buildSignInButton(l10n, authProvider, theme),
            const SizedBox(height: 16),
            _buildForgotPasswordButton(l10n, theme),
            const SizedBox(height: 20),
            _buildRegisterLink(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations l10n, ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.emailOrPhone,
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.emailRequired;
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
        return null;
      },
    );
  }

  Widget _buildSignInButton(
      AppLocalizations l10n, AuthProvider authProvider, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () => _handleSignIn(authProvider, l10n),
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
                l10n.signIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(AppLocalizations l10n, ThemeData theme) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/forgot_password');
      },
      child: Text(
        l10n.forgotPassword,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            l10n.register,
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

  Future<void> _handleSignIn(
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await authProvider.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Email verification check is done in auth_service
      // If we get here, user is verified and can access the app
      Navigator.pushReplacementNamed(context, '/FizNavBar');
    } else if (mounted) {
      // Check if email is not verified
      if (authProvider.errorCode == 'email-not-verified-login') {
        // Redirect to email verification screen
        Navigator.pushReplacementNamed(context, '/email_verification');
      } else if (authProvider.errorCode != null) {
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
}
