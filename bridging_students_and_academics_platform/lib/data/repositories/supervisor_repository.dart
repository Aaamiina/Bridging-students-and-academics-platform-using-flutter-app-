import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class SupervisorRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  // Helper to get the token; returns null if not found to handle auth errors better
  String? get _token => _storage.read('token');

  Map<String, String> _getHeaders() {
    return {
      "Authorization": "Bearer ${_token ?? ''}",
      "Content-Type": "application/json",
    };
  }

  Future<List<dynamic>> getMyGroups() async {
    try {
      final token = _token;
      if (token == null || token.isEmpty) {
        print("Error: No auth token found");
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/groups'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 10)); // Added timeout for better UX

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Network Error in getMyGroups: $e");
      return [];
    }
  }



  // Future additions: 
Future<List<dynamic>> getTasks() async {
    try {
      if (_token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/tasks'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

Future<bool> createTask({
    required String title,
    required String description,
    required String groupId,
    required String deadline,
  }) async {
    try {
      if (_token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/supervisor/tasks'),
        headers: _getHeaders(),
        body: jsonEncode({
          "title": title,
          "description": description,
          "group_id": groupId, // Matches your fixed backend controller
          "deadline": deadline
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating task: $e");
      return false;
    }
  }

  Future<bool> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      if (_token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/supervisor/tasks/$taskId'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      if (_token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/supervisor/tasks/$taskId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting task: $e");
      return false;
    }
  }

  // --- SUBMISSIONS ---

  Future<List<dynamic>> getSubmissionsByTask(String taskId) async {
    try {
      if (_token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/submissions/$taskId'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error getSubmissionsByTask: $e");
      return [];
    }
  }

  Future<List<dynamic>> getAllSubmissions() async {
    try {
      if (_token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/submissions'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error getAllSubmissions: $e");
      return [];
    }
  }

  Future<bool> gradeSubmission(String submissionId, int? marks, String feedback) async {
    try {
      if (_token == null) return false;
      final response = await http.put(
        Uri.parse('$baseUrl/supervisor/grade/$submissionId'),
        headers: _getHeaders(),
        body: jsonEncode({"marks": marks, "feedback": feedback}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error gradeSubmission: $e");
      return false;
    }
  }

  Future<List<dynamic>> getGroupMembers(String groupName) async {
    try {
      if (_token == null) return [];
      final encoded = Uri.encodeComponent(groupName);
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/groups/$encoded/members'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error getGroupMembers: $e");
      return [];
    }
  }
}