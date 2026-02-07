import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/supervisor_repository.dart';

class SupervisorController extends GetxController {
  final SupervisorRepository _repo = SupervisorRepository();
  final GetStorage _storage = GetStorage();
  
  var userName = "".obs;
  var userEmail = "".obs;
  var password = "".obs;
  var groups = <dynamic>[].obs;
  var isLoading = false.obs;

  var tasks = <dynamic>[].obs;
  var allSubmissions = <dynamic>[].obs;
  var submissionsByTask = <dynamic>[].obs;
  var groupMembers = <dynamic>[].obs; 

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    fetchTasks(); // Load tasks as soon as supervisor is active so Tasks tab shows them on first open
  }


void loadUserData() {
  final userData = _storage.read('user');
  if (userData != null) {
    userName.value = userData['name'] ?? userName.value;
    userEmail.value = userData['email'] ?? userEmail.value;
  }
  if (userName.value.isEmpty) userName.value = _storage.read('user_name') ?? "User Name";
  if (userEmail.value.isEmpty) userEmail.value = _storage.read('user_email') ?? "email@example.com";
}

void logout() {
  _storage.erase(); // Clear all tokens and user data
  Get.offAllNamed('/login'); // Redirect to login screen
}
 // lib/controllers/supervisor_controller.dart
void fetchGroups() async {
  try {
    isLoading.value = true;
    final data = await _repo.getMyGroups();
    
    // DEBUG: This will show you exactly what is coming from the backend
    print("DEBUG: Groups data received: $data");
    
    if (data != null && data is List) {
      groups.assignAll(data);
    } else {
      print("DEBUG: Data is either null or not a list");
      groups.clear();
    }
  } catch (e) {
    print("DEBUG: Error in fetchGroups: $e");
  } finally {
    isLoading.value = false;
  }
}
Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      final data = await _repo.getTasks();
      if (data != null && data is List) {
        tasks.assignAll(data);
      } else {
        tasks.clear();
      }
    } catch (e) {
      debugPrint("DEBUG: Error in fetchTasks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask(String title, String description, String groupId, String deadline) async {
    try {
      isLoading.value = true;
      bool success = await _repo.createTask(
        title: title, 
        description: description, 
        groupId: groupId, 
        deadline: deadline,
      );

      if (success) {
        Get.snackbar("Success", "Task Created Successfully", 
            backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
        fetchTasks(); // Refresh list to show the new task
      } else {
        Get.snackbar("Error", "Failed to create task. Check backend logs.", 
            backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      isLoading.value = true;
      bool success = await _repo.updateTask(taskId, taskData);
      
      if (success) {
        Get.back(); // Return from Details Page
        fetchTasks(); // Refresh List
        Get.snackbar("Updated", "Task details updated successfully",
            backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("DEBUG: Error in updateTask: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      bool success = await _repo.deleteTask(taskId);

      if (success) {
        // Update UI immediately so the task disappears without refresh
        tasks.removeWhere((t) => (t['_id'] ?? t['id']).toString() == taskId);
        Get.back(); // Close Dialog
        Get.back(); // Return to Task Page
        Get.snackbar("Deleted", "Task has been removed",
            backgroundColor: Colors.black87, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("DEBUG: Error in deleteTask: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllSubmissions() async {
    try {
      isLoading.value = true;
      final data = await _repo.getAllSubmissions();
      if (data != null && data is List) {
        allSubmissions.assignAll(data);
      } else {
        allSubmissions.clear();
      }
    } catch (e) {
      debugPrint("fetchAllSubmissions: $e");
      allSubmissions.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSubmissionsByTask(String taskId) async {
    try {
      isLoading.value = true;
      final data = await _repo.getSubmissionsByTask(taskId);
      if (data != null && data is List) {
        submissionsByTask.assignAll(data);
      } else {
        submissionsByTask.clear();
      }
    } catch (e) {
      debugPrint("fetchSubmissionsByTask: $e");
      submissionsByTask.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupMembers(String groupName) async {
    try {
      isLoading.value = true;
      final data = await _repo.getGroupMembers(groupName);
      if (data != null && data is List) {
        groupMembers.assignAll(data);
      } else {
        groupMembers.clear();
      }
    } catch (e) {
      debugPrint("fetchGroupMembers: $e");
      groupMembers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> gradeSubmission(String submissionId, int? marks, String feedback) async {
    try {
      isLoading.value = true;
      bool success = await _repo.gradeSubmission(submissionId, marks, feedback);
      if (success) {
        Get.snackbar("Success", "Feedback submitted", backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
        Get.back();
      } else {
        Get.snackbar("Error", "Failed to submit feedback", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("gradeSubmission: $e");
      Get.snackbar("Error", "Failed to submit feedback", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}