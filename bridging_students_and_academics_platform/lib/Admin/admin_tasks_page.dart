import 'package:flutter/material.dart';

class AdminTasksPage extends StatelessWidget {
  const AdminTasksPage({super.key});

  // ---------------- MOCK DATA ----------------

  final List<Map<String, String>> supervisors = const [
    {"id": "s1", "name": "Hassan Ali"},
    {"id": "s2", "name": "Amina Noor"},
  ];

  final List<Map<String, String>> groups = const [
    {"id": "g1", "name": "Group A", "supervisorId": "s1"},
    {"id": "g2", "name": "Group B", "supervisorId": "s2"},
  ];

  final List<Map<String, String>> tasks = const [
    {
      "title": "Database Design",
      "status": "Pending",
      "supervisorId": "s1",
      "groupId": "g1",
    },
    {
      "title": "UI Implementation",
      "status": "In Progress",
      "supervisorId": "s2",
      "groupId": "g2",
    },
    {
      "title": "Final Report",
      "status": "Completed",
      "supervisorId": "s1",
      "groupId": "g1",
    },
  ];

  // ---------------- HELPERS ----------------

  String supervisorName(String id) {
    return supervisors.firstWhere((s) => s["id"] == id)["name"]!;
  }

  String groupName(String id) {
    return groups.firstWhere((g) => g["id"] == id)["name"]!;
  }

  Color statusColor(String status) {
    switch (status) {
      case "Completed":
        return const Color.fromARGB(255, 57, 108, 59);
      case "In Progress":
        return const Color.fromARGB(255, 129, 92, 35);
      default:
        return const Color.fromARGB(255, 209, 32, 19);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "All Tasks (Admin View)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor(task["status"]!),
                      child: const Icon(Icons.task, color: Colors.white),
                    ),
                    title: Text(task["title"]!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Supervisor: ${supervisorName(task["supervisorId"]!)}",
                        ),
                        Text(
                          "Group: ${groupName(task["groupId"]!)}",
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        task["status"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          statusColor(task["status"]!),
                    ),
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
