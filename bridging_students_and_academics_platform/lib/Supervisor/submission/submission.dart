import 'package:bridging_students_and_academics_platform/Supervisor/group/supervisor_groups_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/profile/profile_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/evaluate_submission_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task_Page.dart';
import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  int _selectedIndex = 2; // Highlight 'Submissions' tab

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSubmissionItem(
            context,
            title: "Math Assignment",
            group: "Group A",
            status: "Submitted",
            isDone: true,
          ),
          const SizedBox(height: 15),
          _buildSubmissionItem(
            context,
            title: "Math Assignment",
            group: "Group A",
            status: "Pending",
            isDone: false,
          ),
          const SizedBox(height: 15),
          _buildSubmissionItem(
            context,
            title: "Math Assignment",
            group: "Group A",
            status: "Submitted",
            isDone: true,
          ),
          const SizedBox(height: 15),
          _buildSubmissionItem(
            context,
            title: "Math Assignment",
            group: "Group A",
            status: "Pending",
            isDone: false,
          ),
        ],
      ),
      bottomNavigationBar: SupervisorBottomBar(
  currentIndex: _selectedIndex, // 0 for Groups, 1 for Tasks, etc.
  onTap: (index) {
    if (index == _selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const SupervisorGroupsPage(); // Frame 39
        break;
      case 1:
        page = const TaskPage(); // Frame 40/41
        break;
      case 2:
        page = const SubmissionPage(); // Frame 44
        break;
      case 3:
        page = const ProfilePageSup(); // Frame 46
        break;
      default:
        page = const SupervisorGroupsPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
      ),
    );
  },
),
    );
  }

  Widget _buildSubmissionItem(BuildContext context, {required String title, required String group, required String status, required bool isDone}) {
    return GestureDetector(
      onTap: () {
        if (isDone) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EvaluateSubmissionPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Icon(Icons.file_download_outlined, color: Colors.blue.shade700, size: 20),
          ],
        ),
      ),
    );
  }
}