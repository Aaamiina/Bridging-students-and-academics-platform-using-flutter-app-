import 'package:bridging_students_and_academics_platform/Student/task_list_page.dart';
import 'package:flutter/material.dart';
import 'custom_nav_bar.dart';
import 'notifications_page.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false, // Removes arrow
          backgroundColor: Colors.transparent,
          elevation: 0,
          // flexibleSpace is used to create the rounded green background
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
                  // Centered Title
                  const Center(
                    child: Text(
                      "Student Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Notification Icon aligned to the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_active_outlined, 
                          color: Colors.white, 
                          size: 26,
                        ),
                        onPressed: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const NotificationsPage()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Student", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))
            ),
            const Text(
              "Group: Group A", 
              style: TextStyle(color: Colors.grey, fontSize: 14)
            ),
            const SizedBox(height: 25),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("8", "Total Tasks", Colors.blue),
                _statCard("5", "Pending", Colors.orange),
                _statCard("3", "Submitted", Colors.green),
              ],
            ),
            
            const SizedBox(height: 35),
            
            // View Tasks Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6D3F),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              onPressed: () {
Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => TaskListPage(),
        transitionDuration: Duration.zero, // Instant transition to match Nav Bar feel
      ),
    );              },
              child: const Text(
                "View My Tasks", 
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _statCard(String val, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 8, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            val, 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54)
          ),
        ],
      ),
    );
  }
}