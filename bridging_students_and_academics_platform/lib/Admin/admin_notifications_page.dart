import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "New Task Created",
      "message": "Task 'Database Design' assigned to Hassan Ali",
      "time": "2 mins ago",
      "type": "task",
      "read": false,
    },
    {
      "title": "Submission Received",
      "message": "Group A submitted 'Final Report'",
      "time": "1 hour ago",
      "type": "submission",
      "read": false,
    },
    {
      "title": "Group Created",
      "message": "Group B created with 5 students",
      "time": "Yesterday",
      "type": "group",
      "read": true,
    },
    {
      "title": "Supervisor Assigned",
      "message": "Amina Noor assigned to Group C",
      "time": "2 days ago",
      "type": "supervisor",
      "read": true,
    },
  ];

  IconData _iconByType(String type) {
    switch (type) {
      case "task":
        return Icons.task;
      case "submission":
        return Icons.assignment_turned_in;
      case "group":
        return Icons.groups;
      case "supervisor":
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color _colorByType(String type) {
    switch (type) {
      case "task":
        return Colors.orange;
      case "submission":
        return Colors.green;
      case "group":
        return Colors.blue;
      case "supervisor":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4F7F3B),
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontFamily: 'InriaSerif',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          final bool isRead = n["read"];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : const Color(0xFFE8F1E4),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      _colorByType(n["type"]).withOpacity(0.15),
                  child: Icon(
                    _iconByType(n["type"]),
                    color: _colorByType(n["type"]),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n["title"],
                        style: TextStyle(
                          fontFamily: 'InriaSerif',
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n["message"],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n["time"],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
