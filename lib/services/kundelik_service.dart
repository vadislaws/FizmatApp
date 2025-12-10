import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for interacting with Kundelik/Dnevnik.ru API
/// Kundelik uses OAuth 2.0 for authentication
class KundelikService {
  // API endpoints
  static const String _baseUrl = 'https://api.kundelik.kz/v2';
  static const String _authUrl = 'https://login.kundelik.kz/oauth2';

  // OAuth credentials (these should be obtained from Kundelik developer portal)
  // For now, using placeholder values
  static const String _clientId = 'YOUR_CLIENT_ID';
  static const String _clientSecret = 'YOUR_CLIENT_SECRET';
  static const String _redirectUri = 'fizmatapp://oauth-callback';

  // Storage keys
  static const String _accessTokenKey = 'kundelik_access_token';
  static const String _refreshTokenKey = 'kundelik_refresh_token';
  static const String _tokenExpiryKey = 'kundelik_token_expiry';

  /// Get authorization URL for OAuth flow
  String getAuthorizationUrl() {
    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': 'Schools,Relatives,EduGroups,Lessons,marks,EducationalInfo',
    };

    final uri = Uri.parse(_authUrl).replace(queryParameters: params);
    return uri.toString();
  }

  /// Exchange authorization code for access token
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'redirect_uri': _redirectUri,
          'grant_type': 'authorization_code',
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(
          data['access_token'],
          data['refresh_token'],
          DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save tokens to local storage
  Future<void> _saveTokens(String accessToken, String refreshToken, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Get valid access token (refreshes if expired)
  Future<String?> _getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final expiryStr = prefs.getString(_tokenExpiryKey);

    if (accessToken == null || expiryStr == null) {
      return null;
    }

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isBefore(expiry)) {
      return accessToken;
    }

    // Token expired, refresh it
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null) {
      return null;
    }

    return await _refreshAccessToken(refreshToken);
  }

  /// Refresh access token using refresh token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(
          data['access_token'],
          data['refresh_token'],
          DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        return data['access_token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is connected to Kundelik
  Future<bool> isConnected() async {
    final token = await _getValidAccessToken();
    return token != null;
  }

  /// Disconnect from Kundelik (clear tokens)
  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Make authenticated API request
  Future<Map<String, dynamic>?> _makeRequest(String endpoint) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      throw Exception('Not authenticated with Kundelik');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>?> getUserInfo() async {
    return await _makeRequest('/users/me');
  }

  /// Get student context (school, class, etc.)
  Future<Map<String, dynamic>?> getContext() async {
    return await _makeRequest('/users/me/context');
  }

  /// Get student's person info (including birthday)
  Future<Map<String, dynamic>?> getPersonInfo() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    final personId = userInfo['personId'];
    return await _makeRequest('/persons/$personId');
  }

  /// Get student's academic performance (grades, GPA)
  Future<Map<String, dynamic>?> getAcademicPerformance() async {
    final context = await getContext();
    if (context == null) return null;

    final studentId = context['studentId'];
    return await _makeRequest('/students/$studentId/performance');
  }

  /// Calculate GPA from marks
  double _calculateGPA(List<dynamic> marks) {
    if (marks.isEmpty) return 0.0;

    final numericMarks = marks
        .map((m) => m['mark'])
        .where((mark) => mark != null && mark is num)
        .map((mark) => (mark as num).toDouble())
        .toList();

    if (numericMarks.isEmpty) return 0.0;

    final sum = numericMarks.reduce((a, b) => a + b);
    return sum / numericMarks.length;
  }

  /// Sync student data from Kundelik
  /// Returns map with: gpa, birthday, fullData
  Future<Map<String, dynamic>> syncStudentData() async {
    try {
      final personInfo = await getPersonInfo();
      final performance = await getAcademicPerformance();

      final result = <String, dynamic>{};

      // Extract birthday
      if (personInfo != null && personInfo['birthday'] != null) {
        result['birthday'] = DateTime.parse(personInfo['birthday']);
      }

      // Calculate GPA from performance
      if (performance != null && performance['marks'] != null) {
        final marks = performance['marks'] as List<dynamic>;
        result['gpa'] = _calculateGPA(marks);
      }

      // Store full data for future use
      result['fullData'] = {
        'personInfo': personInfo,
        'performance': performance,
        'syncedAt': DateTime.now().toIso8601String(),
      };

      return result;
    } catch (e) {
      throw Exception('Failed to sync Kundelik data: $e');
    }
  }

  /// Get recent marks/grades
  Future<List<Map<String, dynamic>>> getRecentMarks({int limit = 10}) async {
    try {
      final performance = await getAcademicPerformance();
      if (performance == null || performance['marks'] == null) {
        return [];
      }

      final marks = performance['marks'] as List<dynamic>;
      return marks
          .take(limit)
          .map((m) => {
                'subject': m['subject']?['name'] ?? 'Unknown',
                'mark': m['mark'],
                'date': m['date'],
                'comment': m['comment'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// Exception for Kundelik-specific errors
class KundelikException implements Exception {
  final String message;
  final String? code;

  KundelikException(this.message, {this.code});

  @override
  String toString() => 'KundelikException: $message${code != null ? " ($code)" : ""}';
}
