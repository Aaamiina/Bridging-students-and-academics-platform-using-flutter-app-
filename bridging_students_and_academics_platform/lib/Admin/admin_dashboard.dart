import 'package:bridging_students_and_academics_platform/Admin/admin_notifications_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_submissions_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_tasks_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/Admin/Supervisor_management.dart';
import 'package:bridging_students_and_academics_platform/Admin/users_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/groups_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_stats_view.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  final Color brandGreen = const Color(0xFF4A6D3F);

  // FULL LIST OF ALL SECTIONS
  late final List<Widget> pages;

  @override
  void initState() {
    print("DEBUG: AdminDashboard.initState - Mounting...");
    super.initState();
    // Initialize AdminController once for the whole dashboard
    print("DEBUG: AdminDashboard - Putting AdminController");
    Get.put(AdminController());
    
    pages = [
      AdminStatsView(onCardTap: (index) => setState(() => selectedIndex = index)), 
      const AdminUsersPage(),
      SupervisorManagementPage(), 
      GroupsPage(),
      const AdminTasksPage(),       
      const AdminSubmissionsPage(), 
      const AdminNotificationsPage(), 
      const AdminProfilePage(),
    ];
  }

  final List<String> titles = [
    "DASHBOARD",
    "USERS",
    "SUPERVISORS",
    "GROUPS",
    "TASKS",
    "SUBMISSIONS",
    "NOTIFICATIONS",
    "PROFILE",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: brandGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          titles[selectedIndex].toUpperCase(),
          style: const TextStyle(
            fontFamily: 'InriaSerif', 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            tooltip: 'Debug Session',
            onPressed: () {
              final token = Get.find<AuthController>().token;
               Get.defaultDialog(
                title: "CURRENT SESSION",
                middleText: "Token: ${token != null && token.isNotEmpty ? 'EXISTS (${token.substring(0,10)}...)' : 'EMPTY/NULL'}",
                textConfirm: "OK",
                onConfirm: () => Get.back(),
              );
            },
          )
        ],
      ),
      drawer: _buildDrawer(),
      body: pages[selectedIndex],
    );
  }

  Widget _buildDrawer() {
    final authController = Get.find<AuthController>();
    return Drawer(
      child: Column(
        children: [
          Obx(() {
            final user = authController.user.value;
            final name = user?.name ?? "Admin User";
            final email = user?.email ?? "admin@academics.edu";
            
            return UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: brandGreen),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                  ? NetworkImage("${AppConfig.imageBaseUrl}${user.profileImage}")
                  : null,
                child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                  ? Icon(Icons.admin_panel_settings, size: 40, color: brandGreen)
                  : null,
              ),
              accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(email),
            );
          }),
          
          // SCROLLABLE MENU ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.dashboard_outlined, "Dashboard", 0),
                _drawerTile(Icons.people_outline, "Users", 1),
                _drawerTile(Icons.supervisor_account_outlined, "Supervisors", 2),
                _drawerTile(Icons.group_outlined, "Groups", 3),
                const Divider(),
                
                // ADDED SECTIONS HERE
                _drawerTile(Icons.task_outlined, "Tasks", 4),
                _drawerTile(Icons.file_present_outlined, "Submissions", 5),
                _drawerTile(Icons.notifications_none_outlined, "Notifications", 6),
                _drawerTile(Icons.person_outline, "Profile", 7),
              ],
            ),
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
               // Ensure AuthController is available or use Get.find
               Get.find<AuthController>().logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? brandGreen : Colors.grey[700]),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? brandGreen : Colors.black87, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      selected: isSelected,
      selectedTileColor: brandGreen.withOpacity(0.1),
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}