import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Low-level API client for Kundelik
/// Handles authentication, token management, and network requests
class KundelikApiClient {
  static const String _baseUrl = 'https://api.kundelik.kz/v2';

  // Official Kundelik API credentials
  static const String _clientId = '387d44e3-e0c9-4265-a9e4-a4caaad5111c';
  static const String _clientSecret = '8a7d709c-fdbb-4047-b0ea-8947afe89d67';
  static const String _scope = 'Schools,Relatives,EduGroups,Lessons,marks,EduWorks,Avatar,EducationalInfo,CommonInfo,ContactInfo,FriendsAndRelatives,Files,Wall,Messages';

  // Storage keys
  static const String _tokenKey = 'kundelik_access_token';
  static const String _userIdKey = 'kundelik_user_id';

  /// Authenticate with username and password
  /// Returns access token on success, throws KundelikException on error
  Future<KundelikAuthResponse> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/authorizations/bycredentials'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'username': username,
          'password': password,
          'scope': _scope,
        }),
      );

      // Handle different response types
      if (response.statusCode == 200) {
        return _parseAuthResponse(response.body);
      } else if (response.statusCode == 503) {
        throw KundelikException(
          'api_maintenance',
          'Kundelik API is under maintenance. Please try again later.',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Invalid credentials';
          throw KundelikException('invalid_credentials', errorMessage);
        } catch (e) {
          throw KundelikException('invalid_credentials', 'Incorrect username or password');
        }
      } else {
        // Check if response is HTML (maintenance page)
        if (response.body.trim().startsWith('<')) {
          final errorMessage = _extractHtmlError(response.body);
          throw KundelikException('api_maintenance', errorMessage);
        }

        throw KundelikException(
          'api_error',
          'Failed to authenticate: ${response.statusCode}',
        );
      }
    } on KundelikException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        throw KundelikException('no_internet', 'No internet connection');
      }
      throw KundelikException('unknown_error', 'An unexpected error occurred: $e');
    }
  }

  /// Parse authentication response
  KundelikAuthResponse _parseAuthResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);

      if (data['accessToken'] == null) {
        throw KundelikException('invalid_response', 'No access token in response');
      }

      return KundelikAuthResponse(
        accessToken: data['accessToken'],
        userId: data['user']?['id'],
        personId: data['user']?['personId'],
        userName: data['user']?['name'],
        userSurname: data['user']?['surname'],
      );
    } catch (e) {
      if (e is KundelikException) rethrow;
      throw KundelikException('invalid_response', 'Failed to parse response: $e');
    }
  }

  /// Save token to local storage
  Future<void> saveToken(String token, int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
  }

  /// Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Clear saved token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Make authenticated GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await getToken();
    if (token == null) {
      throw KundelikException('not_authenticated', 'Not authenticated with Kundelik');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Access-Token': token,
          'Accept': 'application/json',
        },
      );

      return _handleResponse(response);
    } on KundelikException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw KundelikException('no_internet', 'No internet connection');
      }
      throw KundelikException('network_error', 'Network request failed: $e');
    }
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Check for HTML response (maintenance mode)
    if (response.body.trim().startsWith('<')) {
      final errorMessage = _extractHtmlError(response.body);
      throw KundelikException('api_maintenance', errorMessage);
    }

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw KundelikException('invalid_response', 'Invalid JSON response');
      }
    } else if (response.statusCode == 401) {
      throw KundelikException('invalid_token', 'Session expired. Please login again');
    } else if (response.statusCode == 503) {
      throw KundelikException('api_maintenance', 'API is under maintenance');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Request failed';
        throw KundelikException('api_error', errorMessage);
      } catch (e) {
        throw KundelikException('api_error', 'Request failed: ${response.statusCode}');
      }
    }
  }

  /// Extract error message from HTML response
  String _extractHtmlError(String htmlBody) {
    try {
      final document = html_parser.parse(htmlBody);
      final errorDiv = document.querySelector('.error__description');
      if (errorDiv != null) {
        return errorDiv.text.trim();
      }
      return 'API is temporarily unavailable';
    } catch (e) {
      return 'API is temporarily unavailable';
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>> getUserInfo() async {
    return await get('/users/me');
  }

  /// Get person schools
  Future<List<dynamic>> getPersonSchools() async {
    final data = await get('/schools/person-schools');
    return data['items'] ?? [];
  }

  /// Get person info (including birthday)
  Future<Map<String, dynamic>> getPersonInfo(int personId) async {
    return await get('/persons/$personId');
  }

  /// Get academic performance (marks)
  Future<Map<String, dynamic>> getStudentPerformance(int studentId) async {
    return await get('/students/$studentId/performance');
  }

  /// Calculate GPA from marks (numerical marks only)
  double calculateGPA(Map<String, dynamic> performanceData) {
    try {
      final marks = performanceData['marks'] as List?;
      if (marks == null || marks.isEmpty) return 0.0;

      final numericalMarks = <double>[];
      for (final mark in marks) {
        final value = mark['value'];
        if (value is num) {
          numericalMarks.add(value.toDouble());
        } else if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            numericalMarks.add(parsed);
          }
        }
      }

      if (numericalMarks.isEmpty) return 0.0;
      final sum = numericalMarks.reduce((a, b) => a + b);
      return sum / numericalMarks.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Parse birthday from person info
  DateTime? parseBirthday(Map<String, dynamic> personInfo) {
    try {
      final birthdayStr = personInfo['birthday'];
      if (birthdayStr != null) {
        return DateTime.parse(birthdayStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Authentication response model
class KundelikAuthResponse {
  final String accessToken;
  final int? userId;
  final int? personId;
  final String? userName;
  final String? userSurname;

  KundelikAuthResponse({
    required this.accessToken,
    this.userId,
    this.personId,
    this.userName,
    this.userSurname,
  });

  String get fullName => '${userName ?? ''} ${userSurname ?? ''}'.trim();
}

/// Kundelik-specific exception
class KundelikException implements Exception {
  final String code;
  final String message;

  KundelikException(this.code, this.message);

  @override
  String toString() => 'KundelikException($code): $message';
}
