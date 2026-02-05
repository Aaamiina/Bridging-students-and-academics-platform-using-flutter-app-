import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task-details-page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());

  String? selectedGroupId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    controller.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: Stack(
        children: [
          // Background UI Elements
          Positioned(top: -50, right: -5, child: _blob(110, 200, Colors.green.withOpacity(0.3))),
          Positioned(top: -20, right: -20, child: _blob(110, 110, const Color(0xFF4A6D3F))),

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
                          child: Text("Manage Tasks",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildTaskForm(),

                        const SizedBox(height: 25),
                        const Text("Active Tasks",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
                        const SizedBox(height: 10),

                        // List of Created Tasks
                        Obx(() {
                          if (controller.isLoading.value && controller.tasks.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (controller.tasks.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("No tasks found. Create one above!", style: TextStyle(color: Colors.grey)),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.tasks.length,
                            itemBuilder: (context, index) {
                              final task = controller.tasks[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  title: Text(task['title'] ?? 'Untitled', 
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Group: ${task['groupId']?['name'] ?? 'N/A'}\nDue: ${task['deadline'].toString().split('T')[0]}"),
                                  trailing: const Icon(Icons.edit_note, color: Color(0xFF4A6D3F)),
                                  onTap: () => Get.to(() => TaskDetailsPage(taskData: task)),
                                ),
                              );
                            },
                          );
                        }),
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
          _navigate(index);
        },
      ),
    );
  }

  void _navigate(int index) {
    switch (index) {
      case 0: Get.offAllNamed('/supervisor_dashboard'); break;
      case 1: Get.offAllNamed('/supervisor_tasks'); break;
      case 2: Get.offAllNamed('/supervisor_submissions'); break;
      case 3: Get.offAllNamed('/supervisor_profile'); break;
    }
  }

  Widget _buildTaskForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Task Title"),
          _buildTextField("Enter title", controller: titleController),
          const SizedBox(height: 15),
          _buildLabel("Description"),
          _buildTextField("Enter details...", controller: descController, maxLines: 3),
          const SizedBox(height: 15),
          _buildLabel("Assign to Group"),
          _buildDropdown(),
          const SizedBox(height: 15),
          _buildLabel("Deadline"),
          _buildTextField("YYYY-MM-DD", controller: deadlineController),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : _submitForm,
              child: controller.isLoading.value 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Create Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (selectedGroupId != null && titleController.text.isNotEmpty && deadlineController.text.isNotEmpty) {
      await controller.createTask(
        titleController.text, 
        descController.text, 
        selectedGroupId!, 
        deadlineController.text
      );
      // Success Cleanup
      titleController.clear();
      descController.clear();
      deadlineController.clear();
      setState(() => selectedGroupId = null);
    } else {
      Get.snackbar("Missing Info", "Please fill all required fields", backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  Widget _blob(double w, double h, Color color) => Container(width: w, height: h, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF4A6D3F), fontWeight: FontWeight.w600)));

  Widget _buildTextField(String hint, {int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildDropdown() {
    return Obx(() {
      if (controller.groups.isEmpty) return const Text("No groups found. Assign one in Admin panel.");
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedGroupId,
            hint: const Text("Select Group"),
            isExpanded: true,
            items: controller.groups.map<DropdownMenuItem<String>>((group) {
              return DropdownMenuItem<String>(value: group['_id'], child: Text(group['name'] ?? 'Group'));
            }).toList(),
            onChanged: (val) => setState(() => selectedGroupId = val),
          ),
        ),
      );
    });
  }
}