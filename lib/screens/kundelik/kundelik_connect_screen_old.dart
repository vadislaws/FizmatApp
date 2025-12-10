import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/providers/kundelik_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class KundelikConnectScreen extends StatefulWidget {
  const KundelikConnectScreen({super.key});

  @override
  State<KundelikConnectScreen> createState() => _KundelikConnectScreenState();
}

class _KundelikConnectScreenState extends State<KundelikConnectScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final kundelikProvider = Provider.of<KundelikProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.connectKundelik),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(kundelikProvider.getAuthorizationUrl()),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });

              // Check if this is the callback URL
              if (url != null && url.toString().startsWith('fizmatapp://oauth-callback')) {
                _handleCallback(url.toString(), kundelikProvider, authProvider);
              }
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.error}: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCallback(
    String url,
    KundelikProvider kundelikProvider,
    AuthProvider authProvider,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Extract authorization code from URL
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];

    if (code == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Exchange code for token
    final success = await kundelikProvider.handleAuthCallback(code);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kundelikProvider.errorMessage ?? l10n.error),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Sync data from Kundelik
    final data = await kundelikProvider.syncData();

    if (data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kundelikProvider.errorMessage ?? l10n.error),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Update user profile with Kundelik data
    await authProvider.updateKundelikData(
      isConnected: true,
      gpa: data['gpa'],
      birthday: data['birthday'],
      kundelikData: data['fullData'],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kundelikConnected),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
