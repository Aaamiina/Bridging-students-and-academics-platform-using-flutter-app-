import 'package:bridging_students_and_academics_platform/data/repositories/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StudentController extends GetxController {
  final StudentRepository _repo = StudentRepository();
  final GetStorage _storage = GetStorage();
  var isLoading = false.obs;
  var tasks = <dynamic>[].obs;
  var feedbackList = <dynamic>[].obs;

  /// Current student profile from database (name, group).
  var studentName = ''.obs;
  var studentGroup = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  /// Loads student name and group from the database; falls back to storage if API fails.
  Future<void> fetchProfile() async {
    final data = await _repo.getMyProfile();
    if (data != null) {
      studentName.value = (data['name']?.toString() ?? '').trim();
      studentGroup.value = (data['group']?.toString() ?? '').trim();
    } else {
      studentName.value = (_storage.read('user_name')?.toString() ?? '').trim();
      studentGroup.value = (_storage.read('user_group')?.toString() ?? '').trim();
    }
  }
  

  void fetchTasks() async {
    isLoading.value = true;
    tasks.value = await _repo.getMyTasks();
    isLoading.value = false;
  }

  Future<void> submitTask(
    String taskId,
    String description,
    String? link, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
    isLoading.value = true;
    try {
      final errorMessage = await _repo.submitTask(
        taskId,
        description,
        link,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (errorMessage == null) {
        Get.snackbar("Success", "Submitted", backgroundColor: Colors.green, colorText: Colors.white);
        tasks.value = await _repo.getMyTasks();
        Get.back();
      } else {
        debugPrint('Submit task error: $errorMessage');
        Get.snackbar("Submission failed", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
      }
    } catch (e, stack) {
      debugPrint('Submit task exception: $e');
      debugPrint(stack.toString());
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFeedback() async {
    isLoading.value = true;
    final data = await _repo.getFeedback();
    if (data != null && data is List) {
      feedbackList.assignAll(data);
    } else {
      feedbackList.clear();
    }
    isLoading.value = false;
  }
}
