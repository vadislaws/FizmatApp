import 'dart:convert';
import 'package:http/http.dart' as http;

//r
//https://api.kundelik.kz/partners/swagger/ui/index/index.html

class KunError implements Exception {
  final String message;
  KunError(this.message);

  @override
  String toString() => message;
  //好厉害
}

class KunBase {
  final String host = "https://api.kundelik.kz/v2/";
  String? token;
  final http.Client client;

  KunBase({this.token, http.Client? client})
      : client = client ?? http.Client() {
    if (token == null) {
      
    }
  }


  Future<String> getToken(String login, String password) async {
    final response = await client
        .post(
          Uri.parse("https://api.kundelik.kz/v2/authorizations/bycredentials"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "client_id": "387d44e3-e0c9-4265-a9e4-a4caaad5111c",
            "client_secret": "8a7d709c-fdbb-4047-b0ea-8947afe89d67",
            "username": login,
            "password": password,
            "scope": "Schools,Relatives,EduGroups,Lessons,marks,EduWorks,Avatar,"
                "EducationalInfo,CommonInfo,ContactInfo,FriendsAndRelatives,"
                "Files,Wall,Messages",
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      final body = response.body;
      // Try to extract a meaningful error message
      try {
        final j = json.decode(body);
        if (j is Map) {
          final desc = j['description'] ?? j['message'] ?? j['error'];
          if (desc != null) throw KunError(desc.toString());
        }
      } catch (e) {
        if (e is KunError) rethrow;
      }
      throw KunError('Ошибка входа (${response.statusCode}). Проверь логин/пароль.');
    }

    final jsonResponse = json.decode(response.body);

    if (jsonResponse['type'] == 'authorizationFailed') {
      throw KunError(jsonResponse['description']?.toString() ?? 'Неверный логин или пароль');
    }

    final token = jsonResponse['accessToken'];
    if (token == null) throw KunError('Не удалось получить токен');
    return token as String;
  }

  dynamic _checkAndDecode(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      throw KunError('Сервер вернул HTML (обслуживание или ошибка)');
    }

    if (response.statusCode == 401) throw KunError('Сессия истекла, войдите снова');
    if (response.statusCode == 403) throw KunError('Доступ запрещён');
    if (response.statusCode >= 400) throw KunError('Ошибка сервера: ${response.statusCode}');

    if (response.body.isEmpty) return null;

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (_) {
      throw KunError('Неверный формат ответа сервера');
    }

    if (decoded is Map) {
      if (decoded['type'] == 'parameterInvalid') {
        throw KunError(decoded['description']?.toString() ?? 'Неверный параметр');
      } else if (decoded['type'] == 'apiServerError' || decoded['type'] == 'apiUnknownError') {
        throw KunError('Ошибка API Кунделика');
      }
    }
    return decoded;
  }

  Future<dynamic> getRaw(String method, {Map<String, String>? params}) async {
    final uri = Uri.parse(host + method).replace(queryParameters: params);
    final response = await client
        .get(uri, headers: {"Access-Token": token ?? ""})
        .timeout(const Duration(seconds: 20));
    return _checkAndDecode(response);
  }

  Future<Map<String, dynamic>> get(String method,
      {Map<String, String>? params}) async {
    final result = await getRaw(method, params: params);
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    throw KunError('Неожиданный формат ответа для $method');
  }

  Future<Map<String, dynamic>> post(String method,
      {Map<String, dynamic>? data}) async {
    final response = await client.post(
      Uri.parse(host + method),
      headers: {
        "Access-Token": token ?? "",
        "Content-Type": "application/json"
      },
      body: json.encode(data ?? {}),
    );
    final decoded = _checkAndDecode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<Map<String, dynamic>> delete(String method,
      {Map<String, String>? params}) async {
    final uri = Uri.parse(host + method).replace(queryParameters: params);
    final response =
        await client.delete(uri, headers: {"Access-Token": token ?? ""});
    final decoded = _checkAndDecode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<Map<String, dynamic>> put(String method,
      {Map<String, dynamic>? params}) async {
    final response = await client.put(
      Uri.parse(host + method),
      headers: {
        "Access-Token": token ?? "",
        "Content-Type": "application/json"
      },
      body: json.encode(params ?? {}),
    );
    final decoded = _checkAndDecode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }
}


class KunAPI extends KunBase {
  final String? login;
  final String? password;

  KunAPI({this.login, this.password, String? token}) : super(token: token);

  Future<Map<String, dynamic>> getSchool() async {
    final response = await get("schools/person-schools");
    return response;
  }

  Future<Map<String, dynamic>> getInfo() async {
    final response = await get("users/me");
    return response;
  }

  /// Get person info including birthday
  Future<Map<String, dynamic>> getPerson(int personId) async {
    final response = await get("persons/$personId");
    return response;
  }

  /// Get user's context (school, class, student info)
  Future<Map<String, dynamic>> getContext() async {
    final response = await get("users/me/context");
    return response;
  }

  /// Get student's edu groups (ALL years — /all endpoint includes history grades 7-11)
  Future<List<dynamic>> getEduGroups(int personId) async {
    try {
      // /all returns ALL historical edu-groups across all school years
      final raw = await getRaw("persons/$personId/edu-groups/all");
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      // Fallback to current-year only if /all is not available
      try {
        final raw = await getRaw("persons/$personId/edu-groups");
        if (raw is List) return raw;
        if (raw is Map) return (raw['items'] as List?) ?? [];
      } catch (_) {}
      return [];
    }
  }

  /// Reporting periods for an edu-group (Q1, Q2, Q3, Q4, year).
  Future<List<dynamic>> getReportingPeriods(int groupId) async {
    try {
      final raw = await getRaw("edu-groups/$groupId/reporting-periods");
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
    } catch (_) {}
    return [];
  }

  /// Quarterly marks for a person: fetches reporting periods for the group,
  /// then pulls marks per period. These are the official четвертные оценки (1–5).
  Future<List<dynamic>> getQuarterlyMarks(int groupId, int personId) async {
    final periods = await getReportingPeriods(groupId);
    if (periods.isEmpty) return [];

    final result = <dynamic>[];
    for (final period in periods) {
      final periodId = period['id'];
      if (periodId == null) continue;
      // Skip annual summary periods — keep only quarterly ones
      final name = (period['name'] ?? '').toString().toLowerCase();
      if (name.contains('год') || name.contains('year') || name.contains('жыл')) continue;

      try {
        final raw = await getRaw("persons/$personId/marks", params: {
          'reportingPeriodId': periodId.toString(),
        });
        List<dynamic> marks = [];
        if (raw is List) {
          marks = raw;
        } else if (raw is Map) {
          marks = (raw['items'] as List?) ?? [];
        }
        result.addAll(marks);
      } catch (_) {}
    }
    return result;
  }

  /// Fallback: get final-marks from the edu-groups endpoint (older API).
  Future<List<dynamic>> getFinalMarks(int groupId, int personId) async {
    final personStr = personId.toString();
    try {
      final raw = await getRaw("edu-groups/$groupId/final-marks");
      List<dynamic> all = [];
      if (raw is List) {
        all = raw;
      } else if (raw is Map) {
        all = (raw['items'] as List?) ?? [];
      }
      if (all.isNotEmpty) {
        final mine = all.where((m) {
          if (m is! Map) return false;
          final pid = (m['personId'] ?? m['person'] ?? m['studentId'])?.toString();
          return pid == null || pid == personStr;
        }).toList();
        return mine.isNotEmpty ? mine : all;
      }
    } catch (_) {}
    return [];
  }

  /// Get recent marks/grades
  Future<List<dynamic>> getRecentMarks(int personId, {int days = 30}) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(Duration(days: days));
      final raw = await getRaw("persons/$personId/marks", params: {
        'from': from.toIso8601String().split('T')[0],
        'to': now.toIso8601String().split('T')[0],
      });
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all marks for current academic year
  Future<List<dynamic>> getAllMarks(int personId) async {
    try {
      final now = DateTime.now();
      final yearStart = now.month >= 9
          ? DateTime(now.year, 9)
          : DateTime(now.year - 1, 9);
      final raw = await getRaw("persons/$personId/marks", params: {
        'from': yearStart.toIso8601String().substring(0, 10),
        'to': now.toIso8601String().substring(0, 10),
      });
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get ALL marks with no date filter and high limit — covers full school history.
  Future<List<dynamic>> getAllMarksNoFilter(int personId) async {
    try {
      final raw = await getRaw("persons/$personId/marks", params: {
        'limit': '1000',
      });
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Quarterly marks filtered by markType=Mark5 (5-point scale).
  Future<List<dynamic>> getMark5Marks(int personId) async {
    try {
      final raw = await getRaw("persons/$personId/marks", params: {
        'markType': 'Mark5',
        'limit': '1000',
      });
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Marks filtered by workType — tries quarterly/period workTypes.
  Future<List<dynamic>> getMarksByWorkType(int personId, String workType) async {
    try {
      final raw = await getRaw("persons/$personId/marks", params: {
        'workType': workType,
        'limit': '1000',
      });
      if (raw is List) return raw;
      if (raw is Map) return (raw['items'] as List?) ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Try edu-groups final-marks with personId param (some Kundelik versions need this).
  Future<List<dynamic>> getFinalMarksForPerson(int groupId, int personId) async {
    final personStr = personId.toString();
    for (final params in [
      {'personId': personStr},
      {'studentId': personStr},
      <String, String>{},
    ]) {
      try {
        final raw = await getRaw(
          "edu-groups/$groupId/final-marks",
          params: params.isEmpty ? null : params,
        );
        List<dynamic> all = [];
        if (raw is List) {
          all = raw;
        } else if (raw is Map) {
          for (final key in ['items', 'content', 'data', 'marks', 'rows', 'result']) {
            if (raw[key] is List) { all = raw[key] as List; break; }
          }
          if (all.isEmpty) all = [raw];
        }
        if (all.isEmpty) continue;
        final mine = all.where((m) {
          if (m is! Map) return false;
          final pid = (m['personId'] ?? m['studentId'] ?? m['pupilId'])?.toString();
          return pid == null || pid == personStr;
        }).toList();
        if (mine.isNotEmpty) return mine;
        if (all.isNotEmpty) return all;
      } catch (_) {}
    }
    return [];
  }

  /// Raw final-marks response for diagnostics.
  Future<dynamic> getRawFinalMarks(int groupId) async {
    try {
      return await getRaw("edu-groups/$groupId/final-marks");
    } catch (e) {
      return 'error: $e';
    }
  }

  /// PRIMARY endpoint for quarterly grades (четвертные оценки из 5).
  /// URL: persons/{person}/edu-groups/{group}/allfinalmarks
  /// Response is nested: [{ SubjectName, FinalMarks: [{ Period, FinalMarks: [{ Student, Mark: { Value } }] }] }]
  /// This method flattens the nesting and returns only marks for the given personId.
  Future<List<Map<String, dynamic>>> getAllFinalMarks(int personId, int groupId) async {
    final pidStr = personId.toString();
    try {
      final raw = await getRaw("persons/$personId/edu-groups/$groupId/allfinalmarks");

      List<dynamic> subjects = [];
      if (raw is List) {
        subjects = raw;
      } else if (raw is Map) {
        for (final key in ['items', 'content', 'data', 'result', 'rows']) {
          if (raw[key] is List) { subjects = raw[key] as List; break; }
        }
      }

      final result = <Map<String, dynamic>>[];
      for (final subj in subjects) {
        if (subj is! Map) continue;
        final subjectName = subj['SubjectName']?.toString() ?? '';

        // Each subject has FinalMarks per reporting period
        final periodEntries = subj['FinalMarks'] as List? ?? [];
        for (final pe in periodEntries) {
          if (pe is! Map) continue;
          final period = pe['Period'];
          final periodId = period is Map ? (period['Id']?.toString() ?? '') : '';
          final rawNum = period is Map
              ? (period['PeriodNumber'] is Map ? period['PeriodNumber']['RawNumber'] : null)
              : null;
          final periodName = rawNum != null ? 'Q$rawNum' : '';
          final dateStart = period is Map ? (period['DateStart']?.toString() ?? '') : '';

          final studentMarks = pe['FinalMarks'] as List? ?? [];
          for (final sm in studentMarks) {
            if (sm is! Map) continue;
            final student = sm['Student'];
            final pid = student is Map ? (student['PersonId']?.toString() ?? '') : '';
            if (pid.isNotEmpty && pid != pidStr) continue; // filter to this student

            final markObj = sm['Mark'];
            if (markObj == null) continue; // quarter not finalized
            final rawVal = markObj is Map ? markObj['Value'] : markObj;
            if (rawVal == null) continue;

            double? v;
            if (rawVal is num) {
              v = rawVal.toDouble();
            } else if (rawVal is String) {
              v = double.tryParse(rawVal.trim());
            }
            if (v == null) continue;

            result.add({
              'subjectName': subjectName,
              'reportingPeriodId': periodId,
              'reportingPeriodName': periodName,
              'date': dateStart.length >= 10 ? dateStart.substring(0, 10) : dateStart,
              'markType': 'FinalMark',
              '_source': 'allfinalmarks',
              '_value': v,
              'value': rawVal,
            });
          }
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  /// persons/{person}/edu-groups/{group}/final-marks — person-scoped final marks.
  Future<List<dynamic>> getPersonEduGroupFinalMarks(int personId, int groupId) async {
    try {
      final raw = await getRaw("persons/$personId/edu-groups/$groupId/final-marks");
      if (raw is List) return raw;
      if (raw is Map) {
        for (final key in ['items', 'content', 'data', 'marks', 'result', 'rows']) {
          if (raw[key] is List) return raw[key] as List;
        }
        if (raw.isNotEmpty) return [raw];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Criteria marks totals (light) — may include quarterly/period grades.
  /// URL: edu-group/{group}/person/{person}/criteria-marks-totals-light?getAllMarkType=true
  /// Note: singular "edu-group"
  Future<List<dynamic>> getCriteriaMarksTotalsLight(int groupId, int personId) async {
    try {
      final raw = await getRaw(
        "edu-group/$groupId/person/$personId/criteria-marks-totals-light",
        params: {'getAllMarkType': 'true'},
      );
      if (raw is List) return raw;
      if (raw is Map) {
        for (final key in ['items', 'content', 'data', 'marks', 'result', 'rows']) {
          if (raw[key] is List) return raw[key] as List;
        }
        if (raw.isNotEmpty) return [raw];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// edu-group/{group}/criteria-marks-totals — class-wide quarterly итоговые.
  /// NOTE: SINGULAR "edu-group" (not "edu-groups") — this is the correct Kundelik path.
  /// Returns итоговые grades (Mark5, 1–5) for ALL students across all subjects and periods.
  /// Filter by personId on the client side.
  Future<List<dynamic>> getCriteriaMarksTotals(int groupId) async {
    try {
      // SINGULAR "edu-group" is required — plural returns 404/empty
      final raw = await getRaw("edu-group/$groupId/criteria-marks-totals");
      if (raw is List) return raw;
      if (raw is Map) {
        for (final key in ['items', 'content', 'data', 'marks', 'result', 'rows']) {
          if (raw[key] is List) return raw[key] as List;
        }
        if (raw.isNotEmpty) return [raw];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// persons/{person}/reporting-periods/{period}/avg-mark — average итоговая for a period.
  Future<dynamic> getPersonPeriodAvgMark(int personId, int periodId) async {
    try {
      return await getRaw("persons/$personId/reporting-periods/$periodId/avg-mark");
    } catch (_) {
      return null;
    }
  }

  /// Collect quarterly итоговые (1–5) via criteria-marks-totals.
  /// Filters the class-wide response to the specific person, returns enriched marks.
  Future<List<Map<String, dynamic>>> getQuarterlyItogViaClassTotals(
    int groupId,
    int personId,
    String subjectName,
    String grade,
  ) async {
    final personStr = personId.toString();
    final all = await getCriteriaMarksTotals(groupId);
    if (all.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    for (final item in all) {
      if (item is! Map) continue;
      // Filter to this person
      final pid = (item['personId'] ?? item['studentId'] ?? item['pupilId'])?.toString();
      if (pid != null && pid != personStr) continue;
      if (item['isDeleted'] == true) continue;

      // Extract value — criteria-marks-totals uses 'mark', 'value', or 'textValue'
      final raw = item['mark'] ?? item['textValue'] ?? item['value'];
      if (raw == null) continue;
      double? v;
      if (raw is num) v = raw.toDouble();
      else if (raw is String) v = double.tryParse(raw.trim());
      if (v == null || v < 1 || v > 5) continue;

      final enriched = Map<String, dynamic>.from(item);
      enriched['_value'] = v;
      if ((enriched['subjectName'] ?? enriched['subject']) == null && subjectName.isNotEmpty) {
        enriched['subjectName'] = subjectName;
      }
      enriched['_grade'] = grade;
      result.add(enriched);
    }
    return result;
  }

  /// Raw response for any endpoint — used in diagnostics.
  Future<dynamic> getRawEndpoint(String path, {Map<String, String>? params}) async {
    try {
      return await getRaw(path, params: params);
    } catch (e) {
      return 'error: $e';
    }
  }

  /// Marks via edu-groups/{groupId}/marks endpoint (different from final-marks).
  Future<List<dynamic>> getGroupMarks(int groupId, int personId) async {
    final personStr = personId.toString();
    try {
      final raw = await getRaw("edu-groups/$groupId/marks", params: {
        'personId': personStr,
      });
      List<dynamic> marks = [];
      if (raw is List) {
        marks = raw;
      } else if (raw is Map) {
        marks = (raw['items'] as List?) ?? [];
      }
      if (marks.isNotEmpty) return marks;

      // fallback: no param, filter locally
      final raw2 = await getRaw("edu-groups/$groupId/marks");
      List<dynamic> all = [];
      if (raw2 is List) {
        all = raw2;
      } else if (raw2 is Map) {
        all = (raw2['items'] as List?) ?? [];
      }
      return all.where((m) {
        if (m is! Map) return false;
        final pid = (m['personId'] ?? m['person'])?.toString();
        return pid == null || pid == personStr;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get marks from the schedule endpoint (days[].marks[].textValue)
  /// This is the most reliable way to get actual lesson grades on Kundelik.
  Future<List<dynamic>> getMarksFromSchedule(int personId, int groupId) async {
    final now = DateTime.now();
    final yearStart = now.month >= 9
        ? DateTime(now.year, 9)
        : DateTime(now.year - 1, 9);
    final startDate = yearStart.toIso8601String().substring(0, 10);
    final endDate = now.toIso8601String().substring(0, 10);

    final raw = await getRaw(
      'persons/$personId/groups/$groupId/schedules',
      params: {'startDate': startDate, 'endDate': endDate},
    );

    final marks = <dynamic>[];
    if (raw is Map) {
      final days = raw['days'];
      if (days is List) {
        for (final day in days) {
          if (day is Map) {
            final dayMarks = day['marks'];
            if (dayMarks is List) marks.addAll(dayMarks);
          }
        }
      }
    }
    return marks;
  }

  /// GPA from quarterly marks only (четвертные оценки, 1–5 scale).
  /// Accepts any markType — criteria-based schools store quarterly итоговые
  /// as Mark10 with value 1–5. Rejects only obvious non-итоговые work types.
  double calculateQuarterlyGPA(List<dynamic> marks) {
    if (marks.isEmpty) return 0.0;
    // Skip only unambiguously non-итоговые work types (homework, classwork, etc.)
    // Do NOT skip mark10/mark100 — FizMat criteria schools store quarterly итоговые
    // with markType=Mark10 but value in 1–5 range.
    const skipTypes = {'homework', 'classwork', 'lessontask', 'exercise'};
    final values = <double>[];
    for (final mark in marks) {
      if (mark is! Map) continue;
      if (mark['isDeleted'] == true) continue;
      final mType = (mark['markType'] ?? mark['type'] ?? '').toString().toLowerCase();
      if (skipTypes.any((s) => mType.contains(s))) continue;
      final dynamic raw = mark['textValue'] ?? mark['value'] ?? mark['mark'] ?? mark['markValue'];
      if (raw == null) continue;
      double? v;
      if (raw is num) {
        v = raw.toDouble();
      } else if (raw is String) {
        v = double.tryParse(raw.trim());
      }
      // Accept only 1–5 range — rejects СОР/СОЧ values like 8, 9, 10 automatically
      if (v != null && v >= 1 && v <= 5) values.add(v);
    }
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// GPA from raw lesson marks — accepts any positive value up to 100.
  double calculateGPA(List<dynamic> marks) {
    if (marks.isEmpty) return 0.0;
    final values = <double>[];
    for (final mark in marks) {
      if (mark['isDeleted'] == true) continue;
      dynamic raw = mark['textValue'];
      if (raw == null || (raw is String && raw.trim().isEmpty)) {
        raw = mark['value'] ?? mark['mark'] ?? mark['grade'];
      }
      if (raw == null) continue;
      double? v;
      if (raw is num && raw > 0) {
        v = raw.toDouble();
      } else if (raw is String) {
        v = double.tryParse(raw.trim());
      }
      if (v != null && v > 0 && v <= 100) values.add(v);
    }
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Collect итоговые (quarterly final grades 1–5) from both itog endpoints.
  /// Uses allfinalmarks. Does NOT touch lesson marks.
  /// Returns enriched marks with '_value', 'subjectName', '_grade', '_source' fields.
  /// Collects quarterly итоговые for traditional (1-5) grading schools.
  /// Strategy: for each edu-group → get quarterly reporting periods →
  /// fetch persons/{pid}/marks?reportingPeriodId={id} → keep only marks
  /// where work.periodType == "Quarter" (итоговая) vs lesson marks.
  /// All group fetches run in parallel.
  Future<List<Map<String, dynamic>>> collectItogMarks(
    int personId,
    List<dynamic> eduGroups,
  ) async {
    String _groupSubject(Map g) =>
        (g['subject'] is Map ? g['subject']['name']?.toString() : null) ??
        g['subjectName']?.toString() ??
        g['name']?.toString() ??
        '';
    String _groupGrade(Map g) => g['classLevel']?.toString() ?? '';

    double? _extractValue(dynamic m) {
      if (m is! Map) return null;
      for (final key in ['value', 'mark', 'markValue', 'result', 'textValue']) {
        final raw = m[key];
        if (raw == null) continue;
        if (raw is num) return raw.toDouble();
        if (raw is String) return double.tryParse(raw.trim());
      }
      return null;
    }

    bool _isQuarterlyItog(Map m) {
      // Check nested work object
      final work = m['work'] ?? m['Work'];
      if (work is Map) {
        final pt = (work['periodType'] ?? work['PeriodType'])?.toString();
        if (pt == 'Quarter' || pt == 'Term' || pt == 'Half') return true;
      }
      // Check top-level periodType
      final pt = (m['periodType'] ?? m['PeriodType'])?.toString();
      if (pt == 'Quarter' || pt == 'Term') return true;
      // Check markType / workType
      final mt = (m['markType'] ?? m['workType'] ?? m['MarkType'])?.toString() ?? '';
      if (mt.toLowerCase().contains('final') || mt.toLowerCase().contains('quarter') ||
          mt.toLowerCase().contains('итог') || mt.toLowerCase().contains('term')) {
        return true;
      }
      return false;
    }

    // Deduplicate group IDs
    final seen = <int>{};
    final uniqueGroups = <dynamic>[];
    for (final g in eduGroups) {
      final gid = g['id'] is int
          ? g['id'] as int
          : int.tryParse(g['id']?.toString() ?? '');
      if (gid != null && seen.add(gid)) uniqueGroups.add(g);
    }

    // Fetch all groups in parallel
    final futures = uniqueGroups.map((group) async {
      final gid = group['id'] is int
          ? group['id'] as int
          : int.tryParse(group['id']?.toString() ?? '')!;
      final subjectName = _groupSubject(group as Map);
      final grade = _groupGrade(group);

      try {
        // Get quarterly reporting periods for this group
        final periods = await getReportingPeriods(gid);
        final quarterPeriods = periods.where((p) {
          final name = (p['name'] ?? '').toString().toLowerCase();
          return !name.contains('год') &&
              !name.contains('year') &&
              !name.contains('жыл') &&
              !name.contains('полу') &&
              !name.contains('semi');
        }).toList();

        if (quarterPeriods.isEmpty) return <Map<String, dynamic>>[];

        // Fetch marks per period in parallel
        final periodFutures = quarterPeriods.map((period) async {
          final periodId = period['id'];
          if (periodId == null) return <Map<String, dynamic>>[];
          final periodName = period['name']?.toString() ?? '';
          try {
            final raw = await getRaw("persons/$personId/marks",
                params: {'reportingPeriodId': periodId.toString()});
            List<dynamic> marks = [];
            if (raw is List) {
              marks = raw;
            } else if (raw is Map) {
              marks = (raw['items'] as List?) ?? [];
            }
            final result = <Map<String, dynamic>>[];
            for (final m in marks) {
              if (m is! Map) continue;
              if (!_isQuarterlyItog(m)) continue;
              final v = _extractValue(m);
              if (v == null) continue;
              result.add({
                ...Map<String, dynamic>.from(m),
                'subjectName': subjectName,
                '_grade': grade,
                'reportingPeriodId': periodId.toString(),
                'reportingPeriodName': periodName,
                '_source': 'marks-quarter',
                '_value': v,
              });
            }
            return result;
          } catch (_) {
            return <Map<String, dynamic>>[];
          }
        }).toList();

        final periodResults = await Future.wait(periodFutures);
        return periodResults.expand((l) => l).toList();
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }).toList();

    final results = await Future.wait(futures);
    return results.expand((list) => list).toList();
  }

  /// Sync all student data (info + итоговые quarterly grades).
  /// ONLY uses итоговые endpoints — never falls back to lesson marks.
  Future<Map<String, dynamic>> syncFullData() async {
    final result = <String, dynamic>{};

    final userInfo = await getInfo();
    result['userInfo'] = userInfo;

    final rawId = userInfo['personId'];
    final personId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    if (personId == null) throw KunError('Could not get person ID from profile');

    try {
      final personInfo = await getPerson(personId);
      result['personInfo'] = personInfo;
      if (personInfo['birthday'] != null) {
        result['birthday'] = DateTime.parse(personInfo['birthday'].toString());
      }
    } catch (_) {}

    try {
      result['schoolInfo'] = await getSchool();
    } catch (_) {}

    final eduGroups = await getEduGroups(personId);

    // Extract current class (highest classLevel group) from Kundelik
    int? classGradeNumber;
    String? classLetter;
    for (final g in eduGroups) {
      final level = int.tryParse(g['classLevel']?.toString() ?? '');
      if (level != null && (classGradeNumber == null || level > classGradeNumber)) {
        classGradeNumber = level;
        final name = (g['name'] ?? g['subjectName'] ?? '').toString();
        final match = RegExp(r'\d+([A-Za-zА-Яа-яЁё])').firstMatch(name);
        classLetter = match?.group(1)?.toUpperCase();
      }
    }
    result['classGradeNumber'] = classGradeNumber;
    result['classLetter'] = classLetter;

    // Collect quarterly итоговые from итоговые endpoints only
    final itogMarks = await collectItogMarks(personId, eduGroups);

    // GPA = average of marks with value in 1–5 range (quarterly итоговые scale)
    final gpaValues = itogMarks
        .where((m) => m['_value'] != null &&
            (m['_value'] as double) >= 1 &&
            (m['_value'] as double) <= 5)
        .map((m) => m['_value'] as double)
        .toList();

    result['gpa'] = gpaValues.isNotEmpty
        ? gpaValues.reduce((a, b) => a + b) / gpaValues.length
        : null;
    result['gpaScale'] = 5;
    result['marksCount'] = itogMarks.length;
    result['marks'] = itogMarks;
    result['syncedAt'] = DateTime.now().toIso8601String();
    return result;
  }
}
