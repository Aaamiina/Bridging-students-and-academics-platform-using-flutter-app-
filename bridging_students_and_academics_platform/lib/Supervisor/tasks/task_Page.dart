import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/group/supervisor_groups_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/profile/profile_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/submission.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task-details-page.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String selectedGroup = 'Group A';
  int _selectedIndex = 1; // Highlight 'Tasks' tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: Stack(
        children: [
          // TOP RIGHT CIRCLES (Blob design from Frame 40/41)
          Positioned(
            top: -50,
            right: -5,
            child: Container(
              width: 110,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFF4A6D3F),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            "Create Task",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A6D3F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Input Form Card
                        _buildTaskForm(),

                        const SizedBox(height: 25),
                        
                        // List Header
                        const Text(
                          "Created Tasks",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A6D3F)
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Task List Item with Navigation to Details (Frame 41 -> 42)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskDetailsPage(
                                  taskData: {
                                    'title': 'reacher',
                                    'description': 'waa ficantahin',
                                    'deadline': 'nnnnnnnnnn',
                                  },
                                ),
                              ),
                            );
                          },
                          child: _buildTaskItem(
                            title: "reacher",
                            description: "waa ficantahin",
                            group: "Group A",
                            subtext: "waa ficantahin",
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTaskForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Task Title"),
          _buildTextField(""),
          const SizedBox(height: 15),
          _buildLabel("Description"),
          _buildTextField("", maxLines: 4),
          const SizedBox(height: 15),
          _buildLabel("Group"),
          _buildDropdown(),
          const SizedBox(height: 15),
          _buildLabel("Deadline"),
          _buildTextField(". . ."),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child: const Text("Create Task", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({required String title, required String description, required String group, required String subtext}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF4A6D3F)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text("$group  $subtext", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4A6D3F),
                fontWeight: FontWeight.w600)),
      );

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGroup,
          isExpanded: true,
          items: ['Group A', 'Group B']
              .map((String val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) => setState(() => selectedGroup = val!),
        ),
      ),
    );
  }
}