import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';

class FizmatEmailInputScreen extends StatefulWidget {
  const FizmatEmailInputScreen({Key? key}) : super(key: key);

  @override
  State<FizmatEmailInputScreen> createState() => _FizmatEmailInputScreenState();
}

class _FizmatEmailInputScreenState extends State<FizmatEmailInputScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderSection(l10n: l10n),
                    const SizedBox(height: 40),
                    _InfoCard(l10n: l10n),
                    const SizedBox(height: 30),
                    _EmailInputField(
                      controller: _emailController,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else
                      _SendCodeButton(
                        l10n: l10n,
                        onPressed: () => _handleSendCode(context, authProvider, l10n),
                      ),
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _ErrorMessage(message: authProvider.errorMessage!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendCode(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final success = await authProvider.sendVerificationCode(email);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.codeSent),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        '/code_verification',
        arguments: email,
      );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _HeaderSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.email_outlined,
          size: 80,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        Text(
          l10n.enterFizmatEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _InfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(76),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.fizmatEmailRequired,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _EmailInputField({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: l10n.fizmatEmailHint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
        prefixIcon: const Icon(Icons.alternate_email, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.emailRequired;
        }
        if (!value.endsWith('@fizmat.kz')) {
          return 'Email must end with @fizmat.kz';
        }
        if (!RegExp(r'^[\w-\.]+@fizmat\.kz$').hasMatch(value)) {
          return l10n.invalidEmail;
        }
        return null;
      },
    );
  }
}

class _SendCodeButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const _SendCodeButton({
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        l10n.sendCode,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withAlpha(128),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
