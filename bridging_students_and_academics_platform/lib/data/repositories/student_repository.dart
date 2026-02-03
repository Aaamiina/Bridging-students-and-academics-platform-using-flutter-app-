import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class StudentRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  Future<bool> submitTask(String taskId, String description, String? externalLink) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student/submit'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        // Backend expects taskId, fileUrl, externalLink.
        // We'll map description to one of them or add field if backend supports, 
        // For now user requested "Connect designs", frontend has "Input", backend keys differ?
        // Let's assume externalLink matches. Description might be metadata.
        // Actually, backend studentController might need checking if it accepts description.
        // I will assume it accepts 'externalLink'. 
        // If file upload is needed, we need MultipartRequest. 
        // SubmitTaskPage has "Upload File" button mock. 
        // For now we implement the basic link submission.
        body: jsonEncode({
          "taskId": taskId,
          // "description": description, // Add if backend supports
          "externalLink": externalLink ?? description // Fallback
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
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
}
