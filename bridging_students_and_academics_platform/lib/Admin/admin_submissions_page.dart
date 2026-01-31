import 'package:bridging_students_and_academics_platform/Admin/submission_details.dart';
import 'package:flutter/material.dart';

class AdminSubmissionsPage extends StatelessWidget {
  const AdminSubmissionsPage({super.key});

  // ---------------- MOCK DATA ----------------

  final List<Map<String, String>> supervisors = const [
    {"id": "s1", "name": "Hassan Ali"},
    {"id": "s2", "name": "Amina Noor"},
  ];

  final List<Map<String, String>> groups = const [
    {"id": "g1", "name": "Group A", "supervisorId": "s1"},
    {"id": "g2", "name": "Group B", "supervisorId": "s2"},
  ];

  final List<Map<String, String>> students = const [
    {"id": "u1", "name": "Abdi Mohamed", "groupId": "g1"},
    {"id": "u2", "name": "Fatima Ali", "groupId": "g2"},
  ];

  final List<Map<String, String>> tasks = const [
    {"id": "t1", "title": "Database Design", "groupId": "g1"},
    {"id": "t2", "title": "UI Implementation", "groupId": "g2"},
  ];

  final List<Map<String, String>> submissions = const [
    {
      "taskId": "t1",
      "studentId": "u1",
      "date": "2026-01-04",
      "status": "Submitted",
    },
    {
      "taskId": "t2",
      "studentId": "u2",
      "date": "2026-01-05",
      "status": "Reviewed",
    },
  ];

  // ---------------- HELPERS ----------------

  String taskTitle(String id) =>
      tasks.firstWhere((t) => t["id"] == id)["title"]!;

  String studentName(String id) =>
      students.firstWhere((s) => s["id"] == id)["name"]!;

  String groupNameByTask(String taskId) {
    final groupId =
        tasks.firstWhere((t) => t["id"] == taskId)["groupId"];
    return groups.firstWhere((g) => g["id"] == groupId)["name"]!;
  }

  String supervisorNameByTask(String taskId) {
    final groupId =
        tasks.firstWhere((t) => t["id"] == taskId)["groupId"];
    final supervisorId =
        groups.firstWhere((g) => g["id"] == groupId)["supervisorId"];
    return supervisors
        .firstWhere((s) => s["id"] == supervisorId)["name"]!;
  }

  Color statusColor(String status) {
    switch (status) {
      case "Reviewed":
        return const Color.fromARGB(255, 118, 129, 121);
      case "Approved":
        return const Color.fromARGB(255, 136, 154, 136);
      default:
        return const Color.fromARGB(255, 14, 15, 16);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "All Submissions (Admin View)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];

                return Card(
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          statusColor(sub["status"]!),
                      child:
                          const Icon(Icons.upload_file, color: Colors.white),
                    ),
                    title: Text(taskTitle(sub["taskId"]!)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Student: ${studentName(sub["studentId"]!)}"),
                        Text(
                            "Group: ${groupNameByTask(sub["taskId"]!)}"),
                        Text(
                            "Supervisor: ${supervisorNameByTask(sub["taskId"]!)}"),
                        Text("Date: ${sub["date"]}"),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        sub["status"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          statusColor(sub["status"]!),
                    ),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const SubmissionDetailsPage(
      taskTitle: "Database Design",
      studentName: "Abdi Mahmed",
      supervisorName: "Hassan Ali",
      submissionDate: "2026-01-3",
      contentDescription: "Upload all your project files, including PHP page, database files, ReadMe",
      fileName: "Submission_file.pdf",
    ),
    ),
  );
},

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
