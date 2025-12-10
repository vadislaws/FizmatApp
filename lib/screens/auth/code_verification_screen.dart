import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String email;

  const CodeVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _canResend = true;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _verificationCode {
    return _controllers.map((c) => c.text).join();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HeaderSection(l10n: l10n, email: widget.email),
                  const SizedBox(height: 50),
                  _CodeInputFields(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onCompleted: (code) =>
                        _handleVerifyCode(context, authProvider, l10n),
                  ),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    _VerifyButton(
                      l10n: l10n,
                      enabled: _verificationCode.length == 6,
                      onPressed: () =>
                          _handleVerifyCode(context, authProvider, l10n),
                    ),
                  const SizedBox(height: 20),
                  _ResendCodeButton(
                    l10n: l10n,
                    canResend: _canResend,
                    onPressed: () =>
                        _handleResendCode(context, authProvider, l10n),
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
    );
  }

  Future<void> _handleVerifyCode(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) async {
    if (_verificationCode.length != 6) {
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.verifyCode(_verificationCode);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verified),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/FizNavBar',
        (route) => false,
      );
    }
  }

  Future<void> _handleResendCode(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) async {
    setState(() => _canResend = false);

    final success = await authProvider.sendVerificationCode(widget.email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.codeSent),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 60), () {
        if (mounted) {
          setState(() => _canResend = true);
        }
      });
    } else {
      setState(() => _canResend = true);
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String email;

  const _HeaderSection({
    required this.l10n,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(25),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.verificationTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.verificationSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(178),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _CodeInputFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String) onCompleted;

  const _CodeInputFields({
    required this.controllers,
    required this.focusNodes,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => _CodeDigitField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              focusNodes[index + 1].requestFocus();
            }
            if (value.isEmpty && index > 0) {
              focusNodes[index - 1].requestFocus();
            }

            if (controllers.every((c) => c.text.isNotEmpty)) {
              final code = controllers.map((c) => c.text).join();
              onCompleted(code);
            }
          },
        ),
      ),
    );
  }
}

class _CodeDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _CodeDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withAlpha(25),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(76)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool enabled;
  final VoidCallback onPressed;

  const _VerifyButton({
    required this.l10n,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          l10n.verify,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ResendCodeButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool canResend;
  final VoidCallback onPressed;

  const _ResendCodeButton({
    required this.l10n,
    required this.canResend,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: canResend ? onPressed : null,
      child: Text(
        l10n.resendCode,
        style: TextStyle(
          color: canResend ? Colors.blue : Colors.grey,
          fontSize: 16,
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
