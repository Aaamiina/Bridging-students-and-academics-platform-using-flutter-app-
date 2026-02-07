import 'package:bridging_students_and_academics_platform/controllers/student_controller.dart';
import 'package:bridging_students_and_academics_platform/Student/task_list_page.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'custom_nav_bar.dart';
import 'notifications_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentController controller = Get.put(StudentController());
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    controller.fetchProfile();
    controller.fetchTasks();
    controller.fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF4A6D3F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Obx(() => _buildProfileAvatar()),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Student Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final name = controller.studentName.value.isEmpty ? 'Student' : controller.studentName.value;
              final group = controller.studentGroup.value.isEmpty ? 'Not assigned' : controller.studentGroup.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $name",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F)),
                  ),
                  Text(
                    "Group: $group",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  if (controller.studentGroup.value.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Ask your admin to assign you to a group to see tasks.",
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 25),
            Obx(() {
              final total = controller.tasks.length;
              final submitted = controller.feedbackList.length;
              final pending = total > submitted ? total - submitted : 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard("$total", "Total Tasks", Colors.blue),
                  _statCard("$pending", "Pending", Colors.orange),
                  _statCard("$submitted", "Submitted", Colors.green),
                ],
              );
            }),
            const SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const TaskListPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text(
                "View My Tasks",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProfileAvatar() {
    final profileImage = controller.studentProfileImage.value ?? _storage.read<String>('user_image');
    final hasImage = profileImage != null && profileImage.trim().isNotEmpty;
    String? fullUrl;
    if (hasImage) {
      final path = profileImage!.trim().replaceFirst(RegExp(r'^/'), '');
      final base = AppConfig.imageBaseUrl.endsWith('/') ? AppConfig.imageBaseUrl : '${AppConfig.imageBaseUrl}/';
      fullUrl = '$base$path';
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      backgroundImage: fullUrl != null ? NetworkImage(fullUrl) : null,
      child: fullUrl == null
          ? const Icon(Icons.person_rounded, color: Color(0xFF4A6D3F), size: 32)
          : null,
    );
  }

  Widget _statCard(String val, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
