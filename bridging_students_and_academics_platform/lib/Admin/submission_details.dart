import 'package:flutter/material.dart';

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

            // File Card
            _buildFileCard(fileName),
            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(context),
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

  Widget _buildFileCard(String fileName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text(fileName, style: const TextStyle(fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildButton("Approve", const Color(0xFF4A6D3F))),
        const SizedBox(width: 15),
        Expanded(child: _buildButton("Rejected", const Color(0xFFD32F2F))),
      ],
    );
  }

  Widget _buildButton(String text, Color color) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: const StadiumBorder()),
        onPressed: () {},
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}