import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final GetStorage _storage = GetStorage();
  
  // In-memory token
  String? _token;

  String? getToken() {
    if (_token != null && _token!.isNotEmpty) return _token;
    // Fallback to storage
    return _storage.read('token');
  }

  Future<void> setToken(String newToken) async {
    _token = newToken;
    await _storage.write('token', newToken);
    print("DEBUG: SessionManager - Token set in memory (Length: ${newToken.length})");
    print("DEBUG: SessionManager - Current Token: $_token");
  }

  Future<void> clearSession() async {
    _token = null;
    await _storage.remove('token');
    await _storage.remove('user_role');
  }
}
