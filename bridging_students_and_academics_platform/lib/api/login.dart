import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiLogin {
  // Replace with your server's IP (use 10.0.2.2 for Android Emulator)
  static const String baseUrl = "http://172.22.115.99:5000/api";
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