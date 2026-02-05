import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class SupervisorManagementPage extends StatelessWidget {
  SupervisorManagementPage({super.key});

  final AdminController controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Supervisor Management",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)));
              }
              
              if (controller.supervisors.isEmpty) {
                return const Center(child: Text("No supervisors found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.supervisors.length,
                itemBuilder: (context, index) {
                  final supervisor = controller.supervisors[index];
                  final String name = supervisor['name'] ?? 'Unknown';
                  final String email = supervisor['email'] ?? 'No Email';
                  final String role = supervisor['role'] ?? 'Supervisor';
                  final String? group = supervisor['group']; // The assigned group name (e.g. "Group A")
                  final bool isAssigned = group != null && group.isNotEmpty;

                  return _buildUserCard(
                    context: context,
                    userId: supervisor['_id'],
                    name: name,
                    username: email, 
                    role: role,
                    isAssigned: isAssigned,
                    assignedGroup: group,
                    imgUrl: supervisor['profileImage'],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required BuildContext context,
    required String userId,
    required String name,
    required String username,
    required String role,
    required bool isAssigned,
    String? assignedGroup,
    String? imgUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD1DBCE),
                backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                    ? NetworkImage("${AppConfig.imageBaseUrl}$imgUrl")
                    : null,
                child: (imgUrl == null || imgUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(username, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1DBCE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (!isAssigned)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6D3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showAssignGroupDialog(context, userId),
                child: const Text("Assign Group", style: TextStyle(color: Colors.white)),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                   const Text("Assigned Group: ", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text(assignedGroup ?? "", style: const TextStyle(fontWeight: FontWeight.normal)),
                   const Spacer(),
                   // Optional: Allow re-assigning
                   IconButton(
                     icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                     onPressed: () => _showAssignGroupDialog(context, userId),
                   )
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ... existing imports ...

  void _showAssignGroupDialog(BuildContext context, String supervisorId) {
    if (controller.groups.isEmpty) {
      Get.snackbar("Notice", "No groups available to assign.");
      return;
    }

    Get.defaultDialog(
      title: "Select Group",
      content: SizedBox(
        height: 300,
        width: 300,
        child: ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            final String groupName = group['name'] ?? "Unknown Group";
            final String groupId = group['_id']; // Get the MongoDB ID

            return ListTile(
              leading: const Icon(Icons.group_work, color: Color(0xFF4A6D3F)),
              title: Text(groupName),
              subtitle: Text("ID: ...${groupId.substring(groupId.length - 5)}"),
              onTap: () {
                Get.back(); // Close dialog
                
                // CRITICAL FIX: 
                // Your Controller method is: assignSupervisor(String groupId, String supervisorId)
                // You were sending: assignSupervisor(supervisorId, groupName)
                
                controller.assignSupervisor(groupId, supervisorId);
              },
            );
          },
        ),
      ),
      textCancel: "Cancel",
    );
  }
}