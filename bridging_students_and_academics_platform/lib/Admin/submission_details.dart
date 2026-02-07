import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionDetailsPage extends StatelessWidget {
  // These fields must be passed when you navigate to this page
  final String taskTitle;
  final String studentName;
  final String supervisorName;
  final String submissionDate;
  final String contentDescription;
  final String fileName;

  const SubmissionDetailsPage({
    super.key,
    required this.taskTitle,
    required this.studentName,
    required this.supervisorName,
    required this.submissionDate,
    required this.contentDescription,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("Submissions", style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(radius: 18, backgroundColor: Colors.white12),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Info Card using the passed variables
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildDetailRow("Task:", taskTitle),
                  const SizedBox(height: 15),
                  _buildDetailRow("Student:", studentName),
                  const SizedBox(height: 15),
                  _buildDetailRow("Supervisor:", supervisorName),
                  const SizedBox(height: 15),
                  _buildDetailRow("Submission On:", submissionDate),
                  const SizedBox(height: 25),
                  _buildStatusBadge(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content Card
            _buildWhiteCard("Submission Content", contentDescription),
            const SizedBox(height: 20),

            // File Card with Download
            _buildFileCard(context, fileName),
          ],
        ),
      ),
    );
  }

  // Helper methods to keep the code clean
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
        child: const Text("Submitted", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildWhiteCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, String fileName) {
    final String downloadUrl = fileName.startsWith('http')
        ? fileName
        : '${AppConfig.imageBaseUrl}$fileName';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_drive_file, color: const Color(0xFF4A6D3F), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName.split('/').last,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.download, color: Colors.white, size: 20),
              label: const Text('Download Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}