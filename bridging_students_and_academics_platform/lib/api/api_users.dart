import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:bridging_students_and_academics_platform/core/session_manager.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:get/get.dart';

class ApiUsers {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  String get _token => (SessionManager().getToken() ?? '').toString().replaceAll('"', '').trim();

  // FETCH USERS
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {"Authorization": "Bearer $_token"},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // CREATE USER WITH IMAGE
  Future<bool> createUser(Map<String, dynamic> data, File? image) async {
    try {
      final token = _token;
      if (token.isEmpty) {
        Get.defaultDialog(title: "ERROR", middleText: "Token is empty! Relogin required.");
        return false;
      }

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

      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode != 201) {
         Get.defaultDialog(
            title: "API ERROR ${response.statusCode}", 
            middleText: "Server Message:\n${response.body}\n\nToken Sent: ${token.substring(0, 10)}..."
         );
         return false;
      }

      return true;
    } catch (e) { 
      Get.defaultDialog(title: "EXCEPTION", middleText: "$e");
      return false; 
    }
  }
  // UPDATE USER WITH IMAGE SUPPORT
  Future<bool> updateUser(String id, Map<String, dynamic> data, File? image) async {
    try {
      final token = _token;
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/admin/users/$id'));
      request.headers["Authorization"] = "Bearer $token";

      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage', 
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // DELETE USER
  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: {"Authorization": "Bearer $_token"},
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}