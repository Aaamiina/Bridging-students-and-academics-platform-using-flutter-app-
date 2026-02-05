import 'package:bridging_students_and_academics_platform/data/models/user_model.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bridging_students_and_academics_platform/core/session_manager.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final GetStorage _storage = GetStorage();
  
  // Observables
  var isLoading = false.obs;
  var user = Rxn<UserModel>();

  String? get token => SessionManager().getToken();

  @override
  void onInit() {
    super.onInit();
    print("DEBUG: AuthController onInit");
    // Check for persisted user/token
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    print("DEBUG: AuthController._checkLoginStatus");
    String? token = _storage.read('token');
    if (token != null) {
      // Decode user info if you stored it, or better yet, fetch profile from backend
      // For now, we assume if token exists, we are somewhat logged in.
      String? name = _storage.read('user_name');
      String? email = _storage.read('user_email');
      String? role = _storage.read('user_role');
      String? image = _storage.read('user_image');

      if (name != null && email != null && role != null) {
        user.value = UserModel(
          id: '', 
          name: name,
          email: email,
          role: role,
          profileImage: image,
        );
      }
    }
  }
  Future<void> login(String identifier, String password, bool isSupervisor) async {
    print("DEBUG: AuthController.login v4 - Entry");
    try {
      print("DEBUG: AuthController.login called with identifier: $identifier, isSupervisor: $isSupervisor");
      isLoading.value = true;
      bool isStudent = !isSupervisor;
      
      print("DEBUG: AuthController - Calling repository.login(isStudent: $isStudent)");
      final result = await _authRepository.login(identifier, password, isStudent);
      print("DEBUG: AuthController - Repository result arrived: ${result['success']}");

      if (result['success']) {
        String token = result['token'];
        UserModel loggedInUser = result['user'];
        
        print("DEBUG: Login Successful. Token received: '$token'");

        await SessionManager().setToken(token);
        await _storage.write('user_role', loggedInUser.role);
        await _storage.write('user_name', loggedInUser.name);
        await _storage.write('user_email', loggedInUser.email);
        await _storage.write('user_image', loggedInUser.profileImage);
        await _storage.write('user_group', loggedInUser.group ?? '');

        user.value = loggedInUser;
        Get.snackbar('Success', 'Login successful', backgroundColor: Colors.green, colorText: Colors.white);
        _navigateBasedOnRole(loggedInUser.role);
      } else {
        print("DEBUG: Login Failed: ${result['message']}");
        final msg = result['message']?.toString() ?? 'Login failed';
        Get.snackbar('Login Failed', msg, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
      }
    } catch (e, stack) {
      print("DEBUG: AuthController.login CRASH: $e");
      print(stack);
      Get.snackbar('Crash', 'Internal error: $e', backgroundColor: Colors.purple, colorText: Colors.white);
    } finally {
      print("DEBUG: AuthController.login - Finally: Resetting isLoading");
      isLoading.value = false;
    }
  }

  void _navigateBasedOnRole(String role) {
    String normalizedRole = role.trim().toLowerCase();
    print("DEBUG: Navigating for role: '$role' -> normalized: '$normalizedRole'");

    if (normalizedRole.contains('admin')) {
       Get.offAllNamed('/admin_dashboard');
    } else if (normalizedRole.contains('supervisor')) {
       Get.offAllNamed('/supervisor_dashboard');
    } else if (normalizedRole.contains('student')) {
       Get.offAllNamed('/student_dashboard'); 
    } else {
       Get.snackbar('Error', 'Role Failure (v2): "$role" -> "$normalizedRole"');
    }
  }

  Future<void> logout() async {
    await SessionManager().clearSession();
    user.value = null;
    Get.offAllNamed('/login');
  }
}
