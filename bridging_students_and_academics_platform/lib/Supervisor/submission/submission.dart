import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/evaluate_submission_page.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  int _selectedIndex = 2;
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());

  @override
  void initState() {
    super.initState();
    controller.fetchAllSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        title: const Text("Submissions", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSubmissions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)));
        }
        if (controller.allSubmissions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchAllSubmissions(),
            color: const Color(0xFF4A6D3F),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No submitted tasks yet. Pull down to refresh.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchAllSubmissions(),
          color: const Color(0xFF4A6D3F),
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Submitted tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F)),
              ),
            ),
            const Text("Tap to view, download file, and give feedback.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.allSubmissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final sub = controller.allSubmissions[index];
                final task = sub['taskId'] is Map ? sub['taskId'] as Map : null;
                final student = sub['studentId'] is Map ? sub['studentId'] as Map : null;
                final title = task?['title']?.toString() ?? 'Task';
                final groupName = student?['name']?.toString() ?? 'Student';
                final isDone = sub['status'] == 'Graded' || sub['status'] == 'Submitted';
                final status = sub['status'] == 'Graded' ? 'Graded' : 'Submitted';
                return _buildSubmissionItem(
                  context,
                  title: title,
                  group: groupName,
                  status: status,
                  isDone: isDone,
                  submission: sub,
                );
              },
            ),
          ],
          ),
        ),
      }),
      bottomNavigationBar: SupervisorBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          switch (index) {
            case 0: Get.offAllNamed('/supervisor_dashboard'); break;
            case 1: Get.offAllNamed('/supervisor_tasks'); break;
            case 2: Get.offAllNamed('/supervisor_submissions'); break;
            case 3: Get.offAllNamed('/supervisor_profile'); break;
            default: Get.offAllNamed('/supervisor_dashboard');
          }
        },
      ),
    );
  }

  Widget _buildSubmissionItem(
    BuildContext context, {
    required String title,
    required String group,
    required String status,
    required bool isDone,
    required Map<String, dynamic> submission,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => EvaluateSubmissionPage(submission: submission));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDone ? const Color(0xFFE8F0E5) : const Color(0xFFFFF4D3),
              child: Icon(
                isDone ? Icons.check_circle : Icons.circle,
                color: isDone ? const Color(0xFF4A6D3F) : const Color(0xFFFFCC4D),
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(group, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: isDone ? const Color(0xFF4A6D3F) : const Color(0xFFFFCC4D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }
}
