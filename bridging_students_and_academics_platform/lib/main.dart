import 'dart:async';
import 'package:bridging_students_and_academics_platform/Admin/admin_group_members_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_dashboard.dart';
import 'package:bridging_students_and_academics_platform/Login.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/group/group_members_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bridging_students_and_academics_platform/getStarted.dart';
import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Student/dashboard_page.dart';
import 'package:bridging_students_and_academics_platform/Student/task_list_page.dart';
import 'package:bridging_students_and_academics_platform/Student/feedback_page.dart';
import 'package:bridging_students_and_academics_platform/Student/student_messages_page.dart';
import 'package:bridging_students_and_academics_platform/Student/profile_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/group/supervisor_groups_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task_Page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/submission.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/profile/profile_page.dart';
import 'package:bridging_students_and_academics_platform/log_admin.dart';

import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };
  runZonedGuarded(() async {
    debugPrint("DEBUG: App starting...");
    try {
      await GetStorage.init();
      Get.put(AuthController(), permanent: true);
      runApp(const MyApp());
    } catch (e, stack) {
      debugPrint('FATAL on startup: $e\n$stack');
      rethrow;
    }
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bridging Platform',
      theme: ThemeData(
        fontFamily: 'InriaSerif',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/start',
      getPages: [
        GetPage(name: '/start', page: () => GetStartedPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/group-members', page: () => const AdminGroupMembersPage()),
        GetPage(name: '/admin_dashboard', page: () => const AdminDashboard()),
        GetPage(name: '/student_dashboard', page: () => const StudentDashboard()),
        GetPage(name: '/student_tasks', page: () => TaskListPage()),
        GetPage(name: '/student_feedback', page: () => const FeedbackPage()),
        GetPage(name: '/student_messages', page: () => const StudentMessagesPage()),
        GetPage(name: '/student_profile', page: () => const ProfilePage()),
        GetPage(name: '/supervisor_dashboard', page: () =>  SupervisorGroupsPage()),
        GetPage(name: '/supervisor_tasks', page: () => const TaskPage()),
        GetPage(name: '/supervisor_submissions', page: () => const SubmissionPage()),
        GetPage(name: '/supervisor_profile', page: () => const ProfilePageSup()),
        GetPage(name: '/admin_login', page: () => const logAdmin()),
        // main.dart - Add this to your getPages list
 GetPage(
  name: '/supervisor_group_members', 
  page: () => SupervisorGroupMembersPage(groupName: Get.arguments ?? 'Group'),
),
      ],
    );
  }
}
