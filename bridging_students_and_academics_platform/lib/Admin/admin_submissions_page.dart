import 'package:bridging_students_and_academics_platform/Admin/submission_details.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSubmissionsPage extends StatelessWidget {
  const AdminSubmissionsPage({super.key});

  Color statusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('graded') || status.contains('approved')) {
      return const Color(0xFF4A6D3F);
    } else if (status.contains('submitted') || status.contains('pending')) {
      return Colors.blue.shade700;
    } else {
      return Colors.grey.shade600;
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
                "Submissions Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif'),
              ),
              Obx(() => Text("${controller.adminSubmissions.length} Total", style: const TextStyle(color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 15),

          Expanded(
            child: Obx(() {
              if (controller.adminSubmissions.isEmpty) {
                return const Center(child: Text("No submissions found."));
              }

              return ListView.builder(
                itemCount: controller.adminSubmissions.length,
                itemBuilder: (context, index) {
                  final sub = controller.adminSubmissions[index];
                  final String taskTitle = sub['taskId']?['title'] ?? 'Unknown Task';
                  final String studentName = sub['studentId']?['name'] ?? 'Unknown Student';
                  final String status = sub['status'] ?? 'Submitted';
                  final String date = sub['createdAt'] != null ? sub['createdAt'].toString().split('T')[0] : 'No Date';

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
                        backgroundColor: statusColor(status).withOpacity(0.1),
                        child: Icon(Icons.description_outlined, color: statusColor(status)),
                      ),
                      title: Text(taskTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Student: $studentName", style: const TextStyle(fontSize: 12)),
                            Text("Submitted: $date", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: statusColor(status).withOpacity(0.1),
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: Text(status, style: TextStyle(color: statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      onTap: () {
                        Get.to(() => SubmissionDetailsPage(
                          taskTitle: taskTitle,
                          studentName: studentName,
                          supervisorName: "Supervisor", // Needs more data from backend to show real name
                          submissionDate: date,
                          contentDescription: sub['description'] ?? "No description provided.",
                          fileName: sub['fileUrl'] ?? "attachment.pdf",
                        ));
                      },
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
