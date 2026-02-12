import 'dart:convert';

import 'package:fizmat_app/providers/kundelik/kundelik_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Kundelik session persistence and auto-restore
class KundelikSessionManager {
  static const String _tokenKey = 'kundelik_access_token';
  static const String _usernameKey = 'kundelik_username';
  static const String _credentialsKey = 'kundelik_credentials';
  static const String _connectedKey = 'kundelik_connected';

  static KundelikSessionManager? _instance;
  KunAPI? _kunAPI;

  KundelikSessionManager._();

  static KundelikSessionManager get instance {
    _instance ??= KundelikSessionManager._();
    return _instance!;
  }

  /// Check if user has saved Kundelik credentials
  Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_connectedKey) == true &&
        prefs.getString(_usernameKey) != null &&
        prefs.getString(_credentialsKey) != null;
  }

  /// Get the current API instance (if authenticated)
  KunAPI? get api => _kunAPI;

  /// Check if currently authenticated
  bool get isAuthenticated => _kunAPI?.token != null;

  /// Restore session from saved credentials
  /// Returns true if session was restored successfully
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if connected flag is set
      if (prefs.getBool(_connectedKey) != true) {
        return false;
      }

      // First try to use existing token
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        _kunAPI = KunAPI(token: savedToken);

        // Verify token is still valid by making a test request
        try {
          await _kunAPI!.getInfo();
          return true;
        } catch (e) {
          // Token expired, try to re-authenticate
        }
      }

      // Re-authenticate with saved credentials
      final username = prefs.getString(_usernameKey);
      final encodedPassword = prefs.getString(_credentialsKey);

      if (username == null || encodedPassword == null) {
        return false;
      }

      // Decode password
      final password = utf8.decode(base64Decode(encodedPassword));

      // Authenticate
      _kunAPI = KunAPI(login: username, password: password);
      final token = await _kunAPI!.getToken(username, password);
      _kunAPI!.token = token;

      // Save new token
      await prefs.setString(_tokenKey, token);

      return true;
    } catch (e) {
      _kunAPI = null;
      return false;
    }
  }

  /// Sync GPA and return the data
  /// Returns null if sync fails
  Future<Map<String, dynamic>?> syncData() async {
    if (_kunAPI == null || _kunAPI!.token == null) {
      // Try to restore session first
      final restored = await restoreSession();
      if (!restored) {
        return null;
      }
    }

    try {
      return await _kunAPI!.syncFullData();
    } catch (e) {
      // If token expired, try to restore and retry
      final restored = await restoreSession();
      if (restored) {
        try {
          return await _kunAPI!.syncFullData();
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }

  /// Disconnect and clear saved session
  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_credentialsKey);
    await prefs.setBool(_connectedKey, false);
    _kunAPI = null;
  }

  /// Save session after successful login
  Future<void> saveSession({
    required String username,
    required String password,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    final encodedPassword = base64Encode(utf8.encode(password));
    await prefs.setString(_credentialsKey, encodedPassword);
    await prefs.setBool(_connectedKey, true);

    _kunAPI = KunAPI(token: token);
  }
}
