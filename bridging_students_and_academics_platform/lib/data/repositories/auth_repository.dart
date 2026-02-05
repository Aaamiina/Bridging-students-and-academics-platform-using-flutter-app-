import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class AuthRepository {
  static const String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> login(String identifier, String password, bool isStudent) async {
    print("DEBUG: AuthRepository - login ENTRANCE");
    try {
      final body = isStudent 
          ? {"studentId": identifier, "password": password}
          : {"email": identifier, "password": password};
      
      final url = '$baseUrl/auth/login';
      print("DEBUG: AuthRepository - Prepared URL: $url");
      print("DEBUG: AuthRepository - Posting now...");
          
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: AuthRepository - Response Status: ${response.statusCode}");
      print("DEBUG: AuthRepository - Decoding Body now...");
      
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print("DEBUG: AuthRepository - Failed to decode JSON. Body: ${response.body}");
        return {
          "success": false,
          "message": "Invalid server response (not JSON). Status: ${response.statusCode}"
        };
      }

      print("DEBUG: AuthRepository - Response Body: $data");
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "token": data['token'],
          "user": UserModel.fromJson(data['user'])
        };
      } else {
        return {
          "success": false,
          "message": data['msg'] ?? 'Login failed (${response.statusCode})'
        };
      }
    } catch (e) {
      print("DEBUG: AuthRepository - Connection catch: $e");
      return {
        "success": false,
        "message": 'Network error: $e'
      };
    }
  }

  Future<Map<String, dynamic>?> updateProfile(String token, {String? name, String? email, String? password, String? phone}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
