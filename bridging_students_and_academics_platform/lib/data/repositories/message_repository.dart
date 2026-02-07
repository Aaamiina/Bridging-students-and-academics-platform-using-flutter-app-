import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class MessageRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  String? get _token => _storage.read('token');

  Map<String, String> _headers() => {
        'Authorization': 'Bearer ${_token ?? ''}',
        'Content-Type': 'application/json',
      };

  Future<List<dynamic>> getConversations() async {
    try {
      if (_token == null) return [];
      final r = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return jsonDecode(r.body) as List<dynamic>;
      return [];
    } catch (e) {
      print('getConversations: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMessages(String withUserId) async {
    try {
      if (_token == null) return [];
      final r = await http.get(
        Uri.parse('$baseUrl/messages?with=$withUserId'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return jsonDecode(r.body) as List<dynamic>;
      return [];
    } catch (e) {
      print('getMessages: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String receiverId, String content) async {
    try {
      if (_token == null) return null;
      final r = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers(),
        body: jsonEncode({'receiverId': receiverId, 'content': content.trim()}),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 201) return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('sendMessage: $e');
      return null;
    }
  }
}
