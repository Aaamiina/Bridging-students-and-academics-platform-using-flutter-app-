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
                  final String supervisorId = supervisor['_id'];
                  final String name = supervisor['name'] ?? 'Unknown';
                  final String email = supervisor['email'] ?? 'No Email';
                  final String role = supervisor['role'] ?? 'Supervisor';
                  // All groups assigned to this supervisor
                  final assignedGroups = _findAssignedGroups(controller.groups, supervisorId);
                  final bool isAssigned = assignedGroups.isNotEmpty;

                  return _buildUserCard(
                    context: context,
                    userId: supervisorId,
                    name: name,
                    username: email, 
                    role: role,
                    isAssigned: isAssigned,
                    assignedGroups: assignedGroups,
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

  /// Find ALL groups assigned to this supervisor (from Group.supervisorId)
  List<Map<String, dynamic>> _findAssignedGroups(List<dynamic> groups, String supervisorId) {
    final list = <Map<String, dynamic>>[];
    for (final g in groups) {
      final sid = g['supervisorId'];
      String? sidStr;
      if (sid is Map) sidStr = sid['_id']?.toString();
      else if (sid != null) sidStr = sid.toString();
      if (sidStr == supervisorId) list.add(g as Map<String, dynamic>);
    }
    return list;
  }

  /// Check if group can be selected (unassigned or assigned to this supervisor)
  bool _isGroupSelectable(Map<String, dynamic> group, String supervisorId) {
    final sid = group['supervisorId'];
    if (sid == null) return true;
    String? sidStr = sid is Map ? sid['_id']?.toString() : sid.toString();
    return sidStr == supervisorId;
  }

  /// Get supervisor name from group's supervisorId (when populated)
  String _supervisorNameFromGroup(dynamic sid) {
    if (sid is Map && sid['name'] != null) return sid['name'] as String;
    for (final s in controller.supervisors) {
      if (s['_id']?.toString() == sid?.toString()) return s['name'] ?? 'Unknown';
    }
    return 'Another supervisor';
  }

  Widget _buildUserCard({
    required BuildContext context,
    required String userId,
    required String name,
    required String username,
    required String role,
    required bool isAssigned,
    required List<Map<String, dynamic>> assignedGroups,
    String? imgUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAssigned ? const Color(0xFFE8F1E4) : const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isAssigned ? const Color(0xFF4A6D3F).withOpacity(0.3) : Colors.black.withOpacity(0.05),
          width: isAssigned ? 1.5 : 1,
        ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Text("Assigned: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...assignedGroups.map((g) => Chip(
                              label: Text(g['name'] ?? "?", style: const TextStyle(fontSize: 12)),
                              backgroundColor: const Color(0xFFE8F1E4),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                        tooltip: "Remove a group",
                        onPressed: () => _showRemoveGroupChoiceDialog(context, assignedGroups),
                      ),
                    ],
                  ),
                ),
                if (assignedGroups.length < controller.groups.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAssignGroupDialog(context, userId),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Assign another group"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A6D3F),
                          side: const BorderSide(color: Color(0xFF4A6D3F)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Show list of assigned groups - user picks which one to remove
  void _showRemoveGroupChoiceDialog(BuildContext context, List<Map<String, dynamic>> assignedGroups) {
    if (assignedGroups.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text("Select group to remove"),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assignedGroups.length,
            itemBuilder: (context, index) {
              final group = assignedGroups[index];
              final String groupName = group['name'] ?? "Unknown";
              final String groupId = group['_id'];

              return ListTile(
                leading: const Icon(Icons.group_work, color: Color(0xFF4A6D3F)),
                title: Text(groupName),
                trailing: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmRemoveAssignment(context, groupId, groupName);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveAssignment(BuildContext context, String groupId, String groupName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Assignment"),
        content: Text(
          "Remove supervisor from \"$groupName\"? The group will become available for other supervisors.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.unassignSupervisor(groupId);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAssignGroupDialog(BuildContext context, String supervisorId) {
    if (controller.groups.isEmpty) {
      Get.snackbar("Notice", "No groups found. Create a group first.");
      return;
    }

    Get.defaultDialog(
      title: "Select Group",
      content: SizedBox(
        height: 320,
        width: 320,
        child: ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index] as Map<String, dynamic>;
            final String groupName = group['name'] ?? "Unknown Group";
            final String groupId = group['_id'];
            final bool selectable = _isGroupSelectable(group, supervisorId);
            final sid = group['supervisorId'];
            final bool isAssigned = sid != null;
            final bool isAssignedToCurrent = selectable && isAssigned;
            final bool isAssignedToOther = isAssigned && !selectable;

            String subtitle = "Available";
            if (isAssignedToCurrent) subtitle = "Your assignment";
            else if (isAssignedToOther) subtitle = "Assigned to ${_supervisorNameFromGroup(sid)}";

            return ListTile(
              leading: Icon(
                Icons.group_work,
                color: selectable ? const Color(0xFF4A6D3F) : Colors.grey,
              ),
              title: Text(
                groupName,
                style: TextStyle(
                  fontWeight: selectable ? FontWeight.w600 : FontWeight.normal,
                  color: selectable ? Colors.black87 : Colors.grey,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isAssignedToOther ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ),
              enabled: selectable,
              onTap: selectable
                  ? () {
                      Get.back();
                      controller.assignSupervisor(groupId, supervisorId);
                    }
                  : null,
            );
          },
        ),
      ),
      textCancel: "Cancel",
    );
  }
}