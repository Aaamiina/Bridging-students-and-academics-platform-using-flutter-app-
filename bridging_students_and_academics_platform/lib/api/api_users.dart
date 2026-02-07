import 'dart:convert';
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

  /// Picks content type from filename (works on all platforms: mobile, web, emulator).
  static MediaType _imageContentType(String? filename) {
    if (filename != null && filename.toLowerCase().endsWith('.png')) {
      return MediaType('image', 'png');
    }
    return MediaType('image', 'jpeg');
  }

  // CREATE USER WITH IMAGE (bytes work on mobile, web, and emulator)
  Future<bool> createUser(Map<String, dynamic> data, {List<int>? imageBytes, String? imageFilename}) async {
    try {
      final token = _token;
      if (token.isEmpty) {
        Get.defaultDialog(title: "ERROR", middleText: "Token is empty! Relogin required.");
        return false;
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/admin/users'));
      request.headers["Authorization"] = "Bearer $token";

      data.forEach((key, value) => request.fields[key] = value.toString());

      if (imageBytes != null && imageBytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          imageBytes,
          filename: imageFilename ?? 'image.jpg',
          contentType: _imageContentType(imageFilename),
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
  // UPDATE USER WITH IMAGE SUPPORT (bytes work on mobile, web, and emulator).
  // Returns updated user map on success (with profileImage etc), null on failure.
  Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> data, {List<int>? imageBytes, String? imageFilename}) async {
    try {
      final token = _token;
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/admin/users/$id'));
      request.headers["Authorization"] = "Bearer $token";

      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (imageBytes != null && imageBytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          imageBytes,
          filename: imageFilename ?? 'image.jpg',
          contentType: _imageContentType(imageFilename),
        ));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      final user = body?['user'];
      if (user is Map<String, dynamic>) return user as Map<String, dynamic>;
      return body ?? {};
    } catch (e) { return null; }
  }

  // BULK IMPORT USERS FROM CSV
  Future<Map<String, dynamic>?> importUsers(List<int> csvBytes, String filename) async {
    try {
      final token = _token;
      if (token.isEmpty) {
        Get.defaultDialog(title: "ERROR", middleText: "Token is empty! Relogin required.");
        return null;
      }
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/users/import'),
      );
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        csvBytes,
        filename: filename.endsWith('.csv') ? filename : '$filename.csv',
      ));
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        final body = response.body;
        Get.defaultDialog(
          title: "Import Failed",
          middleText: body.length > 200 ? '${body.substring(0, 200)}...' : body,
        );
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      Get.defaultDialog(title: "Import Error", middleText: "$e");
      return null;
    }
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