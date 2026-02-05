import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Fixes the Undefined name 'http' error

class ApiLogin {
  static const String baseUrl = AppConfig.baseUrl;
  static String? _token;

  // 1. LOGIN API (Reflecting Frame 56/54)
  // Connects to: POST /api/auth/login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token']; // Save token for future authorized calls
        return data; // Contains user role and group info
      }
      return null;
    } catch (e) {
      return null;
    }
  }

}