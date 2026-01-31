import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'task_list_page.dart';
import 'feedback_page.dart';
import 'profile_page.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4A6D3F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          onTap: (index) {
            if (index == currentIndex) return;
            Widget page;
            switch (index) {
              case 0: page = const StudentDashboard(); break;
              case 1: page = const TaskListPage(); break;
              case 2: page = const FeedbackPage(); break;
              case 3: page = const ProfilePage(); break;
              default: page = const StudentDashboard();
            }
            Navigator.pushReplacement(
              context, 
              PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero)
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_sharp), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted_rounded), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.reply_all_rounded), label: 'Feedback'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}