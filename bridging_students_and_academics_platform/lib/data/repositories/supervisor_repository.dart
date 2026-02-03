import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class SupervisorRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  // Helper to get the token; returns null if not found to handle auth errors better
  String? get _token => _storage.read('token');

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

  Future<bool> createTask({
    required String title,
    required String description,
    required String groupId,
    required String deadline,
  }) async {
    try {
      final token = _token;
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/supervisor/tasks'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "group_id": groupId, // Changed to snake_case to match common backend standards
          "deadline": deadline
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating task: $e");
      return false;
    }
  }

  // Future additions: 
  // Future<List<dynamic>> getSubmissions(String groupId) async { ... }
}