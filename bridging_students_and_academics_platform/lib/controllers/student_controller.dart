import 'package:bridging_students_and_academics_platform/data/repositories/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentController extends GetxController {
  final StudentRepository _repo = StudentRepository();
  var isLoading = false.obs;
  var tasks = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  void fetchTasks() async {
    isLoading.value = true;
    tasks.value = await _repo.getMyTasks();
    isLoading.value = false;
  }

  Future<void> submitTask(String taskId, String description, String? link) async {
    isLoading.value = true;
    bool success = await _repo.submitTask(taskId, description, link);
    if (success) {
      Get.snackbar("Success", "Task Submitted", backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(); // Go back to list
    } else {
      Get.snackbar("Error", "Submission failed", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }
}
