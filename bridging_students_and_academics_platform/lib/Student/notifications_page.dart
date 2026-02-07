import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/student_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final StudentController controller = Get.isRegistered<StudentController>()
      ? Get.find<StudentController>()
      : Get.put(StudentController());

  @override
  void initState() {
    super.initState();
    controller.fetchFeedback();
    controller.fetchTasks();
  }

  static String _relativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString().trim());
  }

  static bool _isTaskExpired(dynamic deadline) {
    final dt = _parseDate(deadline);
    return dt != null && dt.isBefore(DateTime.now());
  }

  static bool _isDueWithinDays(dynamic deadline, int days) {
    final dt = _parseDate(deadline);
    if (dt == null) return false;
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    return !dt.isBefore(now) && !dt.isAfter(end);
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
            child: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final feedbackList = controller.feedbackList;
        final tasks = controller.tasks;

        // Build real notifications from graded feedback and tasks
        final List<Map<String, dynamic>> items = [];

        // 1. From graded submissions (feedback)
        for (final sub in feedbackList) {
          if ((sub['status'] ?? '').toString() != 'Graded') continue;
          final taskIdObj = sub['taskId'];
          final taskTitle = taskIdObj is Map ? (taskIdObj as Map)['title']?.toString() : null;
          final title = taskTitle ?? 'Task';
          final grade = sub['grade'] is Map ? sub['grade'] as Map<String, dynamic>? : null;
          final marks = grade?['marks'];
          final feedback = grade?['feedback']?.toString()?.trim();
          final gradedAt = grade?['gradedAt']?.toString() ?? sub['updatedAt']?.toString();
          String body = 'Your submission for "$title" has been graded.';
          if (marks != null) body += ' Marks: $marks.';
          if (feedback != null && feedback.isNotEmpty) {
            final preview = feedback.length > 60 ? '${feedback.substring(0, 60)}...' : feedback;
            body += ' $preview';
          }
          items.add({
            'title': 'New Feedback',
            'body': body,
            'time': gradedAt,
            'icon': Icons.star_rounded,
            'color': Colors.orange,
            'sortAt': _parseDate(gradedAt),
          });
        }

        // 2. From tasks: overdue (not submitted) and due soon (next 7 days, not submitted)
        for (final task in tasks) {
          final submitted = task['submitted'] == true;
          if (submitted) continue;
          final taskTitle = task['title']?.toString() ?? 'Task';
          final deadline = task['deadline'];
          final deadlineStr = deadline?.toString() ?? '';
          String dateStr = deadlineStr.contains('T') ? deadlineStr.split('T')[0] : deadlineStr;
          if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

          if (_isTaskExpired(deadline)) {
            items.add({
              'title': 'Overdue',
              'body': '"$taskTitle" was due on $dateStr. Submit as soon as you can.',
              'time': deadlineStr,
              'icon': Icons.warning_amber_rounded,
              'color': Colors.red,
              'sortAt': _parseDate(deadline),
            });
          } else if (_isDueWithinDays(deadline, 7)) {
            items.add({
              'title': 'Due soon',
              'body': '"$taskTitle" is due on $dateStr.',
              'time': deadlineStr,
              'icon': Icons.alarm_rounded,
              'color': Colors.blue,
              'sortAt': _parseDate(deadline),
            });
          }
        }

        // Sort by date descending (newest first)
        items.sort((a, b) {
          final at = a['sortAt'] as DateTime?;
          final bt = b['sortAt'] as DateTime?;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });

        if (controller.isLoading.value && feedbackList.isEmpty && items.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)));
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see feedback and deadline reminders here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final n = items[index];
            return _notifItem(
              n['title'] as String,
              n['body'] as String,
              _relativeTime(n['time'] as String?),
              n['icon'] as IconData,
              n['color'] as Color,
            );
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A6D3F),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFF4A6D3F), width: 1),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.dashboard_rounded),
            label: const Text(
              "Return to Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifItem(String title, String sub, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(sub, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
