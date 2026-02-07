import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task-details-page.dart';
import 'package:bridging_students_and_academics_platform/core/validators.dart';
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

  final _formKey = GlobalKey<FormState>();
  String? selectedGroupId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  /// Deadline is picked via date/time picker, not typed.
  DateTime? _pickedDeadline;

  final int _selectedIndex = 1;

  static String _formatDeadline(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  /// Format API deadline string (ISO or date-only) to consistent "YYYY-MM-DD HH:mm" for display.
  static String formatTaskDeadline(dynamic deadline) {
    if (deadline == null) return 'N/A';
    final s = deadline.toString().trim();
    if (s.isEmpty) return 'N/A';
    try {
      final dt = DateTime.tryParse(s);
      if (dt != null) return _formatDeadline(dt);
    } catch (_) {}
    if (s.contains('T')) return s.split('T')[0] + (s.length > 10 ? ' ${s.substring(11, 16)}' : '');
    return s;
  }

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
                              final isExpired = _isTaskExpired(task['deadline']);
                              return _buildTaskCard(task, isExpired);
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
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Task Title"),
            _buildTitleField(),
            const SizedBox(height: 15),
            _buildLabel("Description"),
            _buildDescriptionField(),
            const SizedBox(height: 15),
            _buildLabel("Assign to Group"),
            _buildGroupDropdown(),
            const SizedBox(height: 15),
            _buildLabel("Deadline"),
            _buildDeadlineField(),
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
      ),
    );
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (selectedGroupId == null || selectedGroupId!.isEmpty) return;

    await controller.createTask(
      titleController.text.trim(),
      descController.text.trim(),
      selectedGroupId!,
      _pickedDeadline!.toIso8601String(),
    );
    // Success cleanup
    titleController.clear();
    descController.clear();
    setState(() {
      selectedGroupId = null;
      _pickedDeadline = null;
    });
    _formKey.currentState?.reset();
  }

  Widget _blob(double w, double h, Color color) => Container(width: w, height: h, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  static bool _isTaskExpired(dynamic deadline) {
    if (deadline == null) return false;
    try {
      final dt = DateTime.tryParse(deadline.toString().trim());
      return dt != null && dt.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isExpired) {
    return Card(
      elevation: isExpired ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isExpired ? Colors.grey.shade200 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task['title'] ?? 'Untitled',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.grey.shade700 : null,
                ),
              ),
            ),
            if (isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Expired", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text(
          "Group: ${task['groupId']?['name'] ?? 'N/A'}\nDue: ${formatTaskDeadline(task['deadline'])}",
          style: TextStyle(color: isExpired ? Colors.grey.shade600 : null, fontSize: 12),
        ),
        trailing: Icon(Icons.edit_note, color: isExpired ? Colors.grey : const Color(0xFF4A6D3F)),
        onTap: () => Get.to(() => TaskDetailsPage(taskData: task)),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF4A6D3F), fontWeight: FontWeight.w600)));

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(12),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: titleController,
      decoration: _inputDecoration("Enter title"),
      validator: Validators.taskTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descController,
      maxLines: 3,
      decoration: _inputDecoration("Enter details..."),
      validator: Validators.taskDescription,
    );
  }

  Widget _buildDeadlineField() {
    return FormField<DateTime>(
      initialValue: _pickedDeadline,
      validator: (value) {
        if (value == null) return 'Please pick a deadline';
        if (value.isBefore(DateTime.now())) return 'Deadline must be in the future (not in the past)';
        return null;
      },
      builder: (formState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _pickDateAndTime(context, formState),
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'Tap to pick date and time',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: formState.hasError
                        ? const BorderSide(color: Colors.red)
                        : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4A6D3F)),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                isEmpty: _pickedDeadline == null,
                child: Text(
                  _pickedDeadline == null
                      ? ''
                      : _formatDeadline(_pickedDeadline!),
                  style: TextStyle(
                    color: _pickedDeadline == null ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            if (formState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  formState.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickDateAndTime(BuildContext context, FormFieldState<DateTime> formState) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedDeadline ?? now,
      firstDate: today,
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _pickedDeadline != null
          ? TimeOfDay(
              hour: _pickedDeadline!.hour,
              minute: _pickedDeadline!.minute,
            )
          : TimeOfDay.fromDateTime(now),
    );
    if (time == null || !context.mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (dateTime.isBefore(now)) {
      if (context.mounted) {
        Get.snackbar(
          "Invalid deadline",
          "Deadline must be later than now. Please pick a future date and time.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
      setState(() => _pickedDeadline = null);
      formState.didChange(null);
      formState.validate();
      return;
    }
    setState(() => _pickedDeadline = dateTime);
    formState.didChange(dateTime);
  }

  Widget _buildGroupDropdown() {
    return FormField<String>(
      initialValue: selectedGroupId,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please select a group' : null,
      builder: (formState) {
        return Obx(() {
          if (controller.groups.isEmpty) {
            return const Text("No groups found. Assign one in Admin panel.");
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(10),
                  border: formState.hasError
                      ? const Border.fromBorderSide(BorderSide(color: Colors.red))
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGroupId,
                    hint: const Text("Select Group"),
                    isExpanded: true,
                    items: controller.groups.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['_id'],
                        child: Text(group['name'] ?? 'Group'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedGroupId = val);
                      formState.didChange(val);
                    },
                  ),
                ),
              ),
              if (formState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    formState.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}