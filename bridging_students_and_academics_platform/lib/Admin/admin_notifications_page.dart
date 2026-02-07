import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Notification item built from real app data (tasks, submissions).
class _NotificationItem {
  final String title;
  final String message;
  final DateTime? date;
  final String type; // 'task' | 'submission'

  _NotificationItem({
    required this.title,
    required this.message,
    this.date,
    required this.type,
  });
}

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  static const Color brandGreen = Color(0xFF4A6D3F);

  String _formatTime(dynamic dateValue) {
    if (dateValue == null) return 'No date';
    DateTime dt;
    if (dateValue is DateTime) {
      dt = dateValue;
    } else if (dateValue is String) {
      dt = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      return 'No date';
    }
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  List<_NotificationItem> _buildNotificationsFromData(AdminController controller) {
    final List<_NotificationItem> items = [];

    for (final task in controller.adminTasks) {
      final title = task['title'] ?? 'Untitled Task';
      final groupName = task['groupId']?['name'] ?? 'Unknown Group';
      final createdBy = task['createdBy']?['name'] ?? 'Supervisor';
      DateTime? date;
      if (task['createdAt'] != null) {
        if (task['createdAt'] is String) {
          date = DateTime.tryParse(task['createdAt'] as String);
        } else if (task['createdAt'] is DateTime) {
          date = task['createdAt'] as DateTime;
        }
      }
      items.add(_NotificationItem(
        title: 'New Task Created',
        message: 'Task "$title" assigned to $groupName by $createdBy',
        date: date,
        type: 'task',
      ));
    }

    for (final sub in controller.adminSubmissions) {
      final taskTitle = sub['taskId']?['title'] ?? 'Unknown Task';
      final studentName = sub['studentId']?['name'] ?? 'Unknown Student';
      final status = sub['status'] ?? 'Submitted';
      DateTime? date;
      if (sub['createdAt'] != null) {
        if (sub['createdAt'] is String) {
          date = DateTime.tryParse(sub['createdAt'] as String);
        } else if (sub['createdAt'] is DateTime) {
          date = sub['createdAt'] as DateTime;
        }
      }
      items.add(_NotificationItem(
        title: 'Submission Received',
        message: '$studentName submitted "$taskTitle" — $status',
        date: date,
        type: 'submission',
      ));
    }

    items.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return items;
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'task':
        return Icons.task_alt;
      case 'submission':
        return Icons.assignment_turned_in;
      default:
        return Icons.notifications;
    }
  }

  Color _colorByType(String type) {
    switch (type) {
      case 'task':
        return Colors.orange;
      case 'submission':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Obx(() {
        if (controller.isLoading.value && controller.adminTasks.isEmpty && controller.adminSubmissions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = _buildNotificationsFromData(controller);

        if (notifications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No notifications yet.\nTasks and submissions will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final timeStr = _formatTime(n.date);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _colorByType(n.type).withOpacity(0.15),
                      child: Icon(
                        _iconByType(n.type),
                        color: _colorByType(n.type),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: const TextStyle(
                              fontFamily: 'InriaSerif',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.message,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
