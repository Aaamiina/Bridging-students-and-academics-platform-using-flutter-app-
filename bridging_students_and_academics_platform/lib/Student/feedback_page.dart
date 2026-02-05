import 'package:bridging_students_and_academics_platform/controllers/student_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_nav_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final StudentController controller = Get.put(StudentController());

  @override
  void initState() {
    super.initState();
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4A6D3F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const SafeArea(
              child: Center(
                child: Text(
                  "Feedback & Grade",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.feedbackList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)));
        }
        if (controller.feedbackList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No feedback yet. Submit tasks and wait for your supervisor to grade them.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: controller.feedbackList.length,
          itemBuilder: (context, index) {
            final item = controller.feedbackList[index];
            final task = item['taskId'] is Map ? item['taskId'] as Map : null;
            final title = task?['title']?.toString() ?? 'Task';
            final grade = item['grade'] is Map ? item['grade'] as Map<String, dynamic> : null;
            final marks = grade?['marks'];
            final feedbackText = grade?['feedback']?.toString() ?? '';
            final status = item['status']?.toString() ?? '';
            final isGraded = status == 'Graded';
            final gradeStr = marks != null ? '$marks/100' : '--/100';
            return _buildFeedbackCard(
              taskTitle: title,
              gradeStr: gradeStr,
              isGraded: isGraded,
              feedbackText: feedbackText.isNotEmpty ? feedbackText : 'No feedback yet.',
            );
          },
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFeedbackCard({
    required String taskTitle,
    required String gradeStr,
    required bool isGraded,
    required String feedbackText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taskTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4A6D3F), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Grade", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text(
                    gradeStr,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Chip(
              label: Text(isGraded ? "Graded" : "Pending"),
              backgroundColor: isGraded ? Colors.green : Colors.orange,
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Supervisor Feedback",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A6D3F)),
                ),
                const SizedBox(height: 4),
                const Text(
                  "What your supervisor says about your submission:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 20),
                Text(
                  feedbackText,
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
