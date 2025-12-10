import 'package:fizmat_app/services/kundelik_service.dart';
import 'package:flutter/material.dart';

class KundelikProvider with ChangeNotifier {
  final KundelikService _kundelikService = KundelikService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isConnected = false;
  Map<String, dynamic>? _studentData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;
  Map<String, dynamic>? get studentData => _studentData;

  KundelikProvider() {
    _checkConnection();
  }

  /// Check if user is connected to Kundelik
  Future<void> _checkConnection() async {
    _isConnected = await _kundelikService.isConnected();
    notifyListeners();
  }

  /// Get authorization URL for OAuth
  String getAuthorizationUrl() {
    return _kundelikService.getAuthorizationUrl();
  }

  /// Handle OAuth callback with authorization code
  Future<bool> handleAuthCallback(String code) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _kundelikService.exchangeCodeForToken(code);
      if (success) {
        _isConnected = true;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setError('Failed to connect to Kundelik');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Connection error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Sync student data from Kundelik
  Future<Map<String, dynamic>?> syncData() async {
    try {
      _setLoading(true);
      _clearError();

      final data = await _kundelikService.syncStudentData();
      _studentData = data;
      _setLoading(false);
      notifyListeners();
      return data;
    } catch (e) {
      _setError('Failed to sync data: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// Get recent marks/grades
  Future<List<Map<String, dynamic>>> getRecentMarks({int limit = 10}) async {
    try {
      return await _kundelikService.getRecentMarks(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Disconnect from Kundelik
  Future<void> disconnect() async {
    try {
      _setLoading(true);
      await _kundelikService.disconnect();
      _isConnected = false;
      _studentData = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect: ${e.toString()}');
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
