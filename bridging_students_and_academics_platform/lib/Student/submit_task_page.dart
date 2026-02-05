import 'package:bridging_students_and_academics_platform/controllers/student_controller.dart';
import 'package:bridging_students_and_academics_platform/Student/read_file_bytes_io.dart'
    if (dart.library.html) 'package:bridging_students_and_academics_platform/Student/read_file_bytes_stub.dart' as file_reader;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubmitTaskPage extends StatefulWidget {
  final String taskId;
  final String taskName;
  final String dueDate;

  const SubmitTaskPage({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.dueDate,
  });

  @override
  State<SubmitTaskPage> createState() => _SubmitTaskPageState();
}

class _SubmitTaskPageState extends State<SubmitTaskPage> {
  final StudentController controller = Get.put(StudentController());
  final TextEditingController descController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  List<int>? _pickedFileBytes;
  String? _pickedFileName;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      List<int>? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await file_reader.readBytesFromPath(file.path!);
      }
      if (bytes != null) {
        setState(() {
          _pickedFileBytes = bytes;
          _pickedFileName = file.name;
        });
        Get.snackbar("File", "Selected: ${file.name}", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Could not read file", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick file", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _clearFile() {
    setState(() {
      _pickedFileBytes = null;
      _pickedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
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
            child: SafeArea(
              child: Center(
                child: Text(
                  widget.taskName,
                  style: const TextStyle(
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Deadline: ${widget.dueDate}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  _buildInputField("Task Description", controller: descController, maxLines: 4),
                  const SizedBox(height: 20),
                  _buildInputField("External Link (GitHub/Drive)", controller: linkController),
                  const SizedBox(height: 24),
                  if (_pickedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickedFileName!,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: _clearFile,
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _pickFile,
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: Text(
                      _pickedFileName != null ? "Change file" : "Upload File",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6D3F),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.submitTask(
                                  widget.taskId,
                                  descController.text,
                                  linkController.text.isEmpty ? null : linkController.text,
                                  fileBytes: _pickedFileBytes,
                                  fileName: _pickedFileName,
                                );
                              },
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Submit Task",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, {required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
