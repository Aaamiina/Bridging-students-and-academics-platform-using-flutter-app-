import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class StudentRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  /// Returns null on success, or an error message string on failure.
  Future<String?> submitTask(
    String taskId,
    String description,
    String? externalLink, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/student/submit'));
      request.headers['Authorization'] = 'Bearer $_token';
      request.fields['taskId'] = taskId;
      request.fields['description'] = description;
      request.fields['externalLink'] = externalLink ?? '';
      if (fileBytes != null && fileName != null && fileName.isNotEmpty) {
        final mimeType = _mimeTypeFor(fileName);
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      final body = response.body;
      if (body.isNotEmpty) {
        try {
          final json = jsonDecode(body);
          if (json is Map && json['error'] != null) return json['error'].toString();
          if (json is Map && json['msg'] != null) return json['msg'].toString();
        } catch (_) {}
        return body.length > 200 ? '${body.substring(0, 200)}...' : body;
      }
      return 'Server error (${response.statusCode})';
    } catch (e) {
      return e.toString();
    }
  }

  static String? _mimeTypeFor(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    const map = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt': 'text/plain',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };
    return map[ext];
  }
  
  // Method to fetch tasks will be needed for the List Page
   Future<List<dynamic>> getMyTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/tasks'),
        headers: {"Authorization": "Bearer $_token"},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> getFeedback() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/feedback'),
        headers: {"Authorization": "Bearer $_token"},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  /// Fetches the logged-in student's profile (name, group) from the database.
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/profile'),
        headers: {"Authorization": "Bearer $_token"},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Supervisor assigned to the student's group (for messaging).
  Future<Map<String, dynamic>?> getMySupervisor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/my-supervisor'),
        headers: {"Authorization": "Bearer $_token"},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
