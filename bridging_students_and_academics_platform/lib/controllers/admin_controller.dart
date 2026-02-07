// import 'package:bridging_students_and_academics_platform/data/repositories/admin_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AdminController extends GetxController {
//   final AdminRepository _repo = AdminRepository();

//   var groups = <dynamic>[].obs;
//   var students = <dynamic>[].obs; 
//   var supervisors = <dynamic>[].obs;
//   var totalUsersCount = 0.obs;
//   var stats = <String, dynamic>{}.obs; // Global counts
//   var adminTasks = <dynamic>[].obs;
//   var adminSubmissions = <dynamic>[].obs;
//   var isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchData();
//   }

//   void fetchData() async {
//     print("DEBUG: AdminController.fetchData - START");
//     isLoading.value = true;
    
//     // Concurrently fetch all data
//     final results = await Future.wait([
//       _repo.getAllGroups(),
//       _repo.getAllUsers(),
//       _repo.getGlobalStats(),
//       _repo.getAdminTasks(),
//       _repo.getAdminSubmissions(),
//     ]);

//     groups.value = results[0] as List<dynamic>;
//     List<dynamic> allUsers = results[1] as List<dynamic>;
//     stats.value = results[2] as Map<String, dynamic>;
//     adminTasks.value = results[3] as List<dynamic>;
//     adminSubmissions.value = results[4] as List<dynamic>;
    
//     print("DEBUG: AdminController.fetchData - Filtering users...");
//     students.value = allUsers.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'student').toList();
//     supervisors.value = allUsers.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'supervisor').toList();
//     totalUsersCount.value = allUsers.length;
    
//     isLoading.value = false;
//     print("DEBUG: AdminController.fetchData - FINISHED");
//   }

//   Future<void> createGroup(String name) async {
//     isLoading.value = true;
//     bool success = await _repo.createGroup(name, "Group Description"); // Add desc input if needed
//     if (success) {
//       Get.snackbar("Success", "Group Created", backgroundColor: Colors.green, colorText: Colors.white);
//       fetchData(); // Refresh list
//     } else {
//       Get.snackbar("Error", "Failed to create group", backgroundColor: Colors.red, colorText: Colors.white);
//     }
//     isLoading.value = false;
//   }

//   Future<void> assignStudents(String groupId, List<String> emails) async {
//     isLoading.value = true;
//     bool success = await _repo.assignMembers(groupId, emails);
//     if (success) {
//       Get.snackbar("Success", "Members Assigned", backgroundColor: Colors.green, colorText: Colors.white);
//       fetchData();
//     } else {
//       Get.snackbar("Error", "Failed to assign members", backgroundColor: Colors.red, colorText: Colors.white);
//     }
//     isLoading.value = false;
//   }

//   // Assign a group to a supervisor (Update User Profile)
//   Future<void> assignSupervisor(String userId, String groupName) async {
//     isLoading.value = true;
//     // We update the user's "group" field directly
//     // Using ApiUsers logic but accessible here? 
//     // Ideally we should move updateUser to AdminRepository or call ApiUsers().
//     // For speed, let's use ApiUsers instance here or import it.
//     // Better: Add updateUser to AdminRepository if not there, or use a quick import.
//     // Let's assume we can use the Repo to maintain pattern.
    
//     // Since AdminRepository doesn't have updateUser yet, let's add a quick helper here or just use ApiUsers
//     // Actually, let's add it to AdminRepository to be clean.
//     bool success = await _repo.updateUserGroup(userId, groupName);

//     if (success) {
//       Get.snackbar("Success", "Supervisor Assigned to $groupName", backgroundColor: Colors.green, colorText: Colors.white);
//       fetchData();
//     } else {
//       Get.snackbar("Error", "Failed to assign group", backgroundColor: Colors.red, colorText: Colors.white);
//     }
//     isLoading.value = false;
//   }

//   Future<void> removeStudentFromGroup(String userId) async {
//     isLoading.value = true;
//     bool success = await _repo.removeStudentFromGroup(userId);
//     if (success) {
//       Get.snackbar("Success", "Student removed from group", backgroundColor: Colors.green, colorText: Colors.white);
//       fetchData();
//     } else {
//       Get.snackbar("Error", "Failed to remove student", backgroundColor: Colors.red, colorText: Colors.white);
//     }
//     isLoading.value = false;
//   }

//   Future<void> deleteGroup(String groupId) async {
//     isLoading.value = true;
//     bool success = await _repo.deleteGroup(groupId);
//     if (success) {
//       Get.snackbar("Success", "Group Deleted", backgroundColor: Colors.green, colorText: Colors.white);
//       fetchData();
//     } else {
//       Get.snackbar("Error", "Failed to delete group", backgroundColor: Colors.red, colorText: Colors.white);
//     }
//     isLoading.value = false;
//   }
// }




import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:bridging_students_and_academics_platform/core/session_manager.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AdminController extends GetxController {
  final AdminRepository _repo = AdminRepository();

  var groups = <dynamic>[].obs;
  var students = <dynamic>[].obs;
  var supervisors = <dynamic>[].obs;
  var totalUsersCount = 0.obs;
  var stats = <String, dynamic>{}.obs; 
  var adminTasks = <dynamic>[].obs;
  var adminSubmissions = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  /// Fetches all administrative data concurrently
  void fetchData() async {
    print("DEBUG: AdminController.fetchData - START");
    isLoading.value = true;
    
    try {
      final results = await Future.wait([
        _repo.getAllGroups(),
        _repo.getAllUsers(),
        _repo.getGlobalStats(),
        _repo.getAdminTasks(),
        _repo.getAdminSubmissions(),
      ]);

      groups.value = results[0] as List<dynamic>;
      List<dynamic> allUsers = results[1] as List<dynamic>;
      stats.value = results[2] as Map<String, dynamic>;
      adminTasks.value = results[3] as List<dynamic>;
      adminSubmissions.value = results[4] as List<dynamic>;
      
      print("DEBUG: AdminController.fetchData - Filtering users...");
      students.value = allUsers.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'student').toList();
      supervisors.value = allUsers.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'supervisor').toList();
      totalUsersCount.value = allUsers.length;
    } catch (e) {
      print("DEBUG: Error in fetchData: $e");
    } finally {
      isLoading.value = false;
      print("DEBUG: AdminController.fetchData - FINISHED");
    }
  }

  /// UPDATE 1: Create Group now accepts name and optional supervisorId
  Future<void> createGroup(String name, {String? supervisorId}) async {
    isLoading.value = true;
    // We send the supervisorId directly to the backend during creation if available
    bool success = await _repo.createGroup(
      name: name, 
      description: "Group Description", 
      academicYear: "2024-2025",
      supervisorId: supervisorId,
    );

    if (success) {
      Get.snackbar("Success", "Group Created", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData(); 
    } else {
      Get.snackbar("Error", "Failed to create group", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  /// UPDATE 2: Assign Supervisor (Post-Creation)
  /// This hits your new 'assignSupervisor' backend logic
  Future<void> assignSupervisor(String groupId, String supervisorId) async {
    isLoading.value = true;
    
    // Updated to use the new repository method that links Group ID to Supervisor ID
    bool success = await _repo.assignSupervisor(groupId, supervisorId);

    if (success) {
      Get.snackbar("Success", "Supervisor Assigned Successfully", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData(); // Refresh list to show updated supervisor field
    } else {
      Get.snackbar("Error", "Failed to assign supervisor", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  /// Unassign supervisor from group (makes group available for other supervisors)
  Future<void> unassignSupervisor(String groupId) async {
    isLoading.value = true;
    bool success = false;
    try {
      final token = SessionManager().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Error", "Not logged in", backgroundColor: Colors.red, colorText: Colors.white);
        isLoading.value = false;
        return;
      }
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/groups/$groupId/unassign-supervisor'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));
      success = response.statusCode == 200;
    } catch (e) {
      print("DEBUG: AdminController.unassignSupervisor ERROR: $e");
    }
    if (success) {
      Get.snackbar("Success", "Supervisor removed from group", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to remove supervisor from group", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  /// UPDATE 3: Assign Students
  /// Maintains existing logic of linking students via emails to a Group ID
  Future<void> assignStudents(String groupId, List<String> emails) async {
    isLoading.value = true;
    bool success = await _repo.assignMembers(groupId, emails);
    if (success) {
      Get.snackbar("Success", "Students Assigned to Group", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to assign students", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  Future<void> removeStudentFromGroup(String userId) async {
    isLoading.value = true;
    bool success = await _repo.removeStudentFromGroup(userId);
    if (success) {
      Get.snackbar("Success", "Student removed from group", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to remove student", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  Future<void> deleteGroup(String groupId) async {
    isLoading.value = true;
    bool success = await _repo.deleteGroup(groupId);
    if (success) {
      Get.snackbar("Success", "Group Deleted", backgroundColor: Colors.green, colorText: Colors.white);
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to delete group", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }
}