import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/evaluate_submission_page.dart';

class TaskDetailsPage extends StatefulWidget {
  final dynamic taskData; // Receiving the full Task object from API

  const TaskDetailsPage({super.key, required this.taskData});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _deadlineController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskData['title']);
    _descController = TextEditingController(text: widget.taskData['description']);
    
    // Format deadline consistently as YYYY-MM-DD HH:mm for display
    String rawDate = widget.taskData['deadline'] ?? "";
    String displayDeadline = rawDate;
    try {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        displayDeadline = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    _deadlineController = TextEditingController(text: displayDeadline);
    final groupId = widget.taskData['groupId'];
    String groupName = '';
    if (groupId is Map && groupId['name'] != null) {
      groupName = groupId['name'].toString();
    }
    if (groupName.isNotEmpty) controller.fetchGroupMembers(groupName);
    controller.fetchSubmissionsByTask(widget.taskData['_id'] ?? '');
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Delete Task",
      middleText: "This action cannot be undone. Are you sure?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
                  final id = widget.taskData['_id'] ?? widget.taskData['id'];
                  controller.deleteTask(id?.toString() ?? '');
                },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("Edit Task", style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Task Title"),
            _buildTextField(_titleController),
            const SizedBox(height: 20),
            
            _buildLabel("Description"),
            _buildTextField(_descController, maxLines: 5),
            const SizedBox(height: 20),
            
            _buildLabel("Deadline"),
            _buildTextField(_deadlineController),
            const SizedBox(height: 40),

            // Update Action
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6D3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value ? null : () {
                  controller.updateTask((widget.taskData['_id'] ?? widget.taskData['id'])?.toString() ?? '', {
                    "title": _titleController.text,
                    "description": _descController.text,
                    "deadline": _deadlineController.text,
                  });
                },
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),

            const SizedBox(height: 15),

            // Delete Action
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _confirmDelete,
                child: const Text("Delete Task", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Students in this task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.groupMembers.isEmpty && controller.submissionsByTask.isEmpty) {
                return const Padding(padding: EdgeInsets.all(12), child: Text("No students in this group or loading...", style: TextStyle(color: Colors.grey)));
              }
              final members = controller.groupMembers;
              final submissions = controller.submissionsByTask;
              if (members.isEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, i) {
                    final sub = submissions[i];
                    final student = sub['studentId'] is Map ? sub['studentId'] : null;
                    final name = student?['name'] ?? 'Student';
                    final isGraded = sub['status'] == 'Graded';
                    return _buildStudentSubmissionTile(
                      name: name,
                      status: isGraded ? 'Graded' : 'Submitted',
                      isDone: true,
                      onTap: () => Get.to(() => EvaluateSubmissionPage(submission: sub)),
                    );
                  },
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, i) {
                  final member = members[i];
                  final studentId = member['_id'];
                  final name = member['name'] ?? 'Student';
                  final submission = submissions.cast<Map<String, dynamic>>().where((s) {
                    final sid = s['studentId'];
                    final id = sid is Map ? sid['_id']?.toString() : sid?.toString();
                    return id == studentId.toString();
                  }).toList();
                  final hasSubmitted = submission.isNotEmpty;
                  final sub = hasSubmitted ? submission.first : null;
                  return _buildStudentSubmissionTile(
                    name: name,
                    status: hasSubmitted ? (sub!['status'] == 'Graded' ? 'Graded' : 'Submitted') : 'Pending',
                    isDone: hasSubmitted,
                    onTap: hasSubmitted && sub != null ? () => Get.to(() => EvaluateSubmissionPage(submission: sub)) : null,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSubmissionTile({required String name, required String status, required bool isDone, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
                isDone ? Icons.check_circle : Icons.pending,
                color: isDone ? const Color(0xFF4A6D3F) : Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(status, style: TextStyle(color: isDone ? const Color(0xFF4A6D3F) : Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isDone) const Icon(Icons.chevron_right, color: Color(0xFF4A6D3F)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
  );

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      ),
    );
  }
}