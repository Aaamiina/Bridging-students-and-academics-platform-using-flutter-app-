import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/supervisor_repository.dart';

class SupervisorController extends GetxController {
  final SupervisorRepository _repo = SupervisorRepository();
  final GetStorage _storage = GetStorage();
  
  var groups = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
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

 Future<void> createTask(String title, String description, String groupId, String deadline) async {
  isLoading.value = true;
  
  // Use named arguments here to match your repository definition
  bool success = await _repo.createTask(
    title: title, 
    description: description, 
    groupId: groupId, 
    deadline: deadline,
  );

  if (success) {
    Get.snackbar("Success", "Task Created", 
        backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    fetchGroups(); 
  } else {
    Get.snackbar("Error", "Failed to create task", 
        backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
  }
  isLoading.value = false;
}
}