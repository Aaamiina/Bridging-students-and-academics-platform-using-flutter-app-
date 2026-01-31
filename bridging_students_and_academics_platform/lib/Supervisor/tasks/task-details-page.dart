import 'package:bridging_students_and_academics_platform/Supervisor/group/supervisor_groups_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/profile/profile_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/submission.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task_Page.dart';
import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, String> taskData;

  const TaskDetailsPage({super.key, required this.taskData});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _deadlineController;
  String _selectedStatus = "Pending";
  final int _selectedIndex = 1; // Keeping Tasks highlighted

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskData['title']);
    _descController = TextEditingController(text: widget.taskData['description']);
    _deadlineController = TextEditingController(text: widget.taskData['deadline'] ?? "nnnnnnnnnn");
  }

  // Frame 45: Delete Confirmation Dialog
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete Tasks",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              const Text(
                "Are you sure you want to delete this task?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      // Add delete logic here
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to list
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        title: const Text("Task Details", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Task Title"),
            _buildTextField(_titleController),
            const SizedBox(height: 15),
            
            _buildLabel("Description"),
            _buildTextField(_descController, maxLines: 4),
            const SizedBox(height: 15),
            
            _buildLabel("Deadline"),
            _buildTextField(_deadlineController),
            const SizedBox(height: 15),
            
            _buildLabel("Status"),
            _buildStatusDropdown(),
            const SizedBox(height: 30),
            
            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6D3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Add update logic here
                },
                child: const Text("Update Task", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
            
            // Delete Button (Outline)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _showDeleteDialog,
                child: const Text("Delete Task", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SupervisorBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          Widget page;
          switch (index) {
            case 0:
              page = const SupervisorGroupsPage();
              break;
            case 1:
              page = const TaskPage();
              break;
            case 2:
              page = const SubmissionPage();
              break;
            case 3:
              page = const ProfilePageSup();
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          items: ["Pending", "Completed", "In Progress"].map((String val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val!),
        ),
      ),
    );
  }
}