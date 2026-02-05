import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/open_submission_url_io.dart'
    if (dart.library.html) 'package:bridging_students_and_academics_platform/Supervisor/submission/open_submission_url_web.dart' as open_url;

class EvaluateSubmissionPage extends StatefulWidget {
  final Map<String, dynamic>? submission;

  const EvaluateSubmissionPage({super.key, this.submission});

  @override
  State<EvaluateSubmissionPage> createState() => _EvaluateSubmissionPageState();
}

class _EvaluateSubmissionPageState extends State<EvaluateSubmissionPage> {
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sub = widget.submission;
    if (sub != null && sub['grade'] is Map) {
      final g = sub['grade'] as Map<String, dynamic>;
      if (g['marks'] != null) gradeController.text = g['marks'].toString();
      if (g['feedback'] != null) feedbackController.text = g['feedback'].toString();
    }
  }

  @override
  void dispose() {
    gradeController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  String _studentName() {
    final s = widget.submission?['studentId'];
    if (s is Map) return s['name']?.toString() ?? 'Student';
    return 'Student';
  }

  String _taskTitle() {
    final t = widget.submission?['taskId'];
    if (t is Map) return t['title']?.toString() ?? 'Task';
    return 'Task';
  }

  String _submittedDate() {
    final createdAt = widget.submission?['createdAt'];
    if (createdAt == null) return 'N/A';
    try {
      final d = DateTime.parse(createdAt.toString());
      return '${d.day} ${_month(d.month)} ${d.year}';
    } catch (_) {
      return createdAt.toString();
    }
  }

  String _month(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  String? _linkOrDescription() {
    final sub = widget.submission;
    if (sub == null) return null;
    final link = sub['externalLink']?.toString();
    if (link != null && link.isNotEmpty) return link;
    return sub['description']?.toString();
  }

  /// Full URL for downloading the submitted file (backend serves /uploads as static).
  String? _fileDownloadUrl() {
    final path = widget.submission?['fileUrl']?.toString();
    if (path == null || path.isEmpty) return null;
    final base = AppConfig.imageBaseUrl.endsWith('/') ? AppConfig.imageBaseUrl : '${AppConfig.imageBaseUrl}/';
    return path.startsWith('http') ? path : '$base$path';
  }

  String? _fileName() {
    final path = widget.submission?['fileUrl']?.toString();
    if (path == null || path.isEmpty) return null;
    final parts = path.replaceAll(r'\', '/').split('/');
    return parts.isNotEmpty ? parts.last : null;
  }

  Future<void> _openOrDownloadFile() async {
    final url = _fileDownloadUrl();
    if (url == null) return;
    final ok = await open_url.openSubmissionUrl(url);
    if (!ok && mounted) {
      Get.snackbar("Error", "Could not open file", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool get _isGraded => widget.submission?['status'] == 'Graded';

  String _gradeStr() {
    final g = widget.submission?['grade'];
    if (g is Map && g['marks'] != null) return '${g['marks']}/100';
    return '--/100';
  }

  String _feedbackText() {
    final g = widget.submission?['grade'];
    if (g is Map && g['feedback'] != null) return g['feedback'].toString();
    return 'No feedback yet.';
  }

  @override
  Widget build(BuildContext context) {
    final linkOrDesc = _linkOrDescription();
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Evaluate Submission", style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_taskTitle(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Student", style: TextStyle(color: Colors.grey)),
                      Text(_studentName(), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Submitted On", style: TextStyle(color: Colors.grey)),
                      Text(_submittedDate(), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (linkOrDesc != null && linkOrDesc.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA6B7A2),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.snackbar("Link", linkOrDesc, backgroundColor: Colors.white);
                        },
                        icon: const Icon(Icons.link, color: Colors.white, size: 18),
                        label: Text(
                          linkOrDesc.length > 35 ? '${linkOrDesc.substring(0, 35)}...' : linkOrDesc,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  if (_fileDownloadUrl() != null) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A6D3F),
                          side: const BorderSide(color: Color(0xFF4A6D3F)),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openOrDownloadFile,
                        icon: const Icon(Icons.download, size: 20),
                        label: Text("Download file: ${_fileName() ?? 'attachment'}"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (_isGraded) ...[
              const Text("Grade", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4A6D3F), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Grade", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text(
                        _gradeStr(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Chip(
                  label: const Text("Graded"),
                  backgroundColor: Colors.green,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Supervisor Feedback",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A6D3F)),
                    ),
                    const Divider(height: 20),
                    Text(
                      _feedbackText(),
                      style: const TextStyle(height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A6D3F),
                    side: const BorderSide(color: Color(0xFF4A6D3F)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    gradeController.text = _gradeStr().replaceAll('/100', '').trim();
                    feedbackController.text = _feedbackText();
                  },
                  child: const Text("Edit grade / feedback"),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!_isGraded) ...[
              const Text("Grade", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
              const SizedBox(height: 8),
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "e.g. 85 or 85 / 100",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Feedback", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Write Feedback for the Student....",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
            ],
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6D3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value ? null : _submitFeedback,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(_isGraded ? "Update Feedback" : "Submit Feedback", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    final id = widget.submission?['_id']?.toString();
    if (id == null || id.isEmpty) {
      Get.snackbar("Error", "Submission not found", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    int? marks;
    final gradeText = gradeController.text.trim();
    if (gradeText.isNotEmpty) {
      marks = int.tryParse(gradeText);
      if (marks == null) {
        final digits = gradeText.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isNotEmpty) marks = int.tryParse(digits.substring(0, digits.length.clamp(0, 3)));
      }
    }
    controller.gradeSubmission(id, marks, feedbackController.text.trim());
  }
}
