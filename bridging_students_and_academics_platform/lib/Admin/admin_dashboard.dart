import 'package:bridging_students_and_academics_platform/Admin/admin_notifications_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_submissions_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_tasks_page.dart';
import 'package:flutter/material.dart';
import 'users_page.dart';
import 'groups_page.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  final Color brandGreen = const Color(0xFF4A6D3F);

  // FULL LIST OF ALL SECTIONS
  final List<Widget> pages = const [
    Center(child: Text("Dashboard Home")), 
    AdminUsersPage(),
    Center(child: Text("Supervisors Management")), 
    GroupsPage(),
    AdminTasksPage(),       
    AdminSubmissionsPage(), 
    AdminNotificationsPage(), 
    Center(child: Text("Profile Settings")),
  ];

  final List<String> titles = [
    "Dashboard",
    "Users Management",
    "Supervisors",
    "Groups",
    "Tasks",
    "Submissions",
    "Notifications",
    "Profile"
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
      ),
      drawer: _buildDrawer(),
      body: pages[selectedIndex],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: brandGreen),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white, 
              child: Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF4A6D3F))
            ),
            accountName: const Text("Admin User", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("admin@academics.edu"),
          ),
          
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
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
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