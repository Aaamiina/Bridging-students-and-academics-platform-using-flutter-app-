import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final SupervisorController controller = Get.find<SupervisorController>();
  // If Controller not found (if coming directly), put it.
  // Actually better use Get.put if unsure, or GetView structure.
  // Assuming it was put in main or previous page. To be safe:
  // final SupervisorController controller = Get.put(SupervisorController()); 
  // But we have it in groups page.

  String? selectedGroupId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<SupervisorController>()) {
      Get.put(SupervisorController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: Stack(
        children: [
          // Background blobs
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
                        
                        _buildTaskForm(),

                        const SizedBox(height: 25),
                        
                        const Text(
                          "Created Tasks",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F)),
                        ),
                        const SizedBox(height: 10),

                        // Placeholder for tasks list (user asked to connect Backend, we added createTask, 
                        // listing created tasks isn't explicit in backend controller yet, only getSubmissions.
                        // We will skip listing created tasks dynamically for now or mock it.)
                        const Text("Newly created tasks will appear for students immediately."),
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
          switch (index) {
            case 0: Get.offAllNamed('/supervisor_dashboard'); break;
            case 1: Get.offAllNamed('/supervisor_tasks'); break;
            case 2: Get.offAllNamed('/supervisor_submissions'); break;
            case 3: Get.offAllNamed('/supervisor_profile'); break;
            default: Get.offAllNamed('/supervisor_dashboard');
          }
        },
      ),
    );
  }

  Widget _blob(double w, double h, Color color) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTaskForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Task Title"),
          _buildTextField("", controller: titleController),
          const SizedBox(height: 15),
          
          _buildLabel("Description"),
          _buildTextField("", controller: descController, maxLines: 4),
          const SizedBox(height: 15),
          
          _buildLabel("Group"),
          _buildDropdown(),
          const SizedBox(height: 15),
          
          _buildLabel("Deadline"),
          _buildTextField("YYYY-MM-DD", controller: deadlineController), 
          // Ideally use DatePicker, keeping text for simplicity as per existing design
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value 
                  ? null
                  : () {
                      if (selectedGroupId != null && titleController.text.isNotEmpty) {
                        controller.createTask(
                          titleController.text, 
                          descController.text, 
                          selectedGroupId!, 
                          deadlineController.text
                        );
                        // Clear form
                        titleController.clear();
                        descController.clear();
                        deadlineController.clear();
                      } else {
                        Get.snackbar("Error", "Please fill all fields and select a group", backgroundColor: Colors.orange, colorText: Colors.white);
                      }
                  },
              child: controller.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Create Task", style: TextStyle(color: Colors.white)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF4A6D3F), fontWeight: FontWeight.w600)),
  );

  Widget _buildTextField(String hint, {int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Obx(() {
       // Populate dropdown from controller.groups
       if (controller.groups.isEmpty) return const Text("No groups available");
       
       return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedGroupId,
            hint: const Text("Select Group"),
            isExpanded: true,
            items: controller.groups.map<DropdownMenuItem<String>>((group) {
              return DropdownMenuItem<String>(
                value: group['_id'],
                child: Text(group['name'] ?? 'Unnamed Group'),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedGroupId = val),
          ),
        ),
      );
    });
  }
}