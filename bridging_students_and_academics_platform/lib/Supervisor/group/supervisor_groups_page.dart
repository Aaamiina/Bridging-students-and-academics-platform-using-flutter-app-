import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/profile/profile_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/submission/submission.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/tasks/task_Page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/group/group_members_page.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';

class SupervisorGroupsPage extends StatefulWidget {
  const SupervisorGroupsPage({super.key});

  @override
  State<SupervisorGroupsPage> createState() => _SupervisorGroupsPageState();
}

class _SupervisorGroupsPageState extends State<SupervisorGroupsPage> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF537A40),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Asma Umar Abdi",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Supervisor",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chat_bubble, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search groups or members",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            const Text(
              "Your Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Groups Grid
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildGroupCard(context, "Group A"),
                  _buildGroupCard(context, "Group B"),
                  _buildGroupCard(context, "Group C"),
                  _buildGroupCard(context, "Group D"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SupervisorBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          Widget page;
          switch (index) {
            case 0:
              page = const SupervisorGroupsPage();
              break;
            case 1:
              page = const TaskPage();
              break;
            case 2:
              page = const SubmissionPage();
              break;
            case 3:
              page = const ProfilePageSup();
              break;
            default:
              page = const SupervisorGroupsPage();
          }

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, String groupName) {
    return GestureDetector(
      onTap: () {
        // Navigation to the members list page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMembersPage(groupName: groupName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F0E5),
              radius: 25,
              child: Icon(Icons.groups, color: Color(0xFF537A40)),
            ),
            const SizedBox(height: 10),
            Text(
              groupName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "Tap to view members",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}