import 'package:bridging_students_and_academics_platform/controllers/student_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_nav_bar.dart';
import 'submit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final StudentController controller = Get.put(StudentController());

  @override
  void initState() {
    super.initState();
    controller.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4A6D3F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const SafeArea(
              child: Center(
                child: Text(
                  "My Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.tasks.isEmpty) {
          return const Center(child: Text("No tasks assigned yet."));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: controller.tasks.length,
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            // Identify fields from backend response
             // Task model (title, description, deadline, etc.)
            final String title = task['title'] ?? 'Task';
            String deadline = task['deadline']?.toString() ?? 'No Deadline';
            if (deadline.contains('T')) deadline = deadline.split('T')[0];
            final String taskId = task['_id'] ?? '';
            final bool submitted = task['submitted'] == true;
            final String status = submitted ? 'Submitted' : 'Pending';
            final Color statusColor = submitted ? Colors.green : Colors.orange;
            final IconData statusIcon = submitted ? Icons.check_circle : Icons.storage;

            return _taskCard(context, title, deadline, status, statusColor, statusIcon, taskId);
          },
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _taskCard(BuildContext context, String title, String date, String status, Color color, IconData icon, String taskId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Due: $date", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitTaskPage(taskId: taskId, taskName: title, dueDate: date),
            ),
          );
        },
      ),
    );
  }
}