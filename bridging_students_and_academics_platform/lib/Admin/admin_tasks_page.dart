import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTasksPage extends StatelessWidget {
  const AdminTasksPage({super.key});

  Color statusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('complete') || status.contains('graded')) {
      return const Color(0xFF4A6D3F);
    } else if (status.contains('progress') || status.contains('submitted')) {
      return Colors.amber.shade800;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tasks Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif'),
              ),
              Obx(() => Text("${controller.adminTasks.length} Total", style: const TextStyle(color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 15),

          Expanded(
            child: Obx(() {
              if (controller.adminTasks.isEmpty) {
                return const Center(child: Text("No tasks found."));
              }

              return ListView.builder(
                itemCount: controller.adminTasks.length,
                itemBuilder: (context, index) {
                  final task = controller.adminTasks[index];
                  final String title = task['title'] ?? 'No Title';
                  final String group = task['groupId']?['name'] ?? 'Unknown Group';
                  final String supervisor = task['createdBy']?['name'] ?? 'System';
                  const String status = "Active"; // Tasks in this model don't have a status, but we can assume Active

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F1E4),
                        child: Icon(Icons.assignment_outlined, color: const Color(0xFF4A6D3F)),
                      ),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Group: $group", style: const TextStyle(fontSize: 12)),
                            Text("By: $supervisor", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: const Color(0xFFE8F1E4),
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: Text("Active", style: TextStyle(color: const Color(0xFF4A6D3F), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
