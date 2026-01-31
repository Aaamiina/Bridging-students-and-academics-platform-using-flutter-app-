import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiUsers {
  static const String baseUrl = "http://172.22.115.99:5000/api";

  // FETCH USERS
  Future<List<dynamic>> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // CREATE USER WITH IMAGE
  Future<bool> createUser(Map<String, dynamic> data, String token, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/admin/users'));
      request.headers["Authorization"] = "Bearer $token";

      data.forEach((key, value) => request.fields[key] = value.toString());

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage', 
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Set a timeout to catch IP connection issues
      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);
      
      print("Status: ${response.statusCode} Body: ${response.body}"); // FOR DEBUGGING
      return response.statusCode == 201;
    } catch (e) { 
      print("API Error: $e");
      return false; 
    }
  }
  // UPDATE USER
  Future<bool> updateUser(String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // DELETE USER
  Future<bool> deleteUser(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}