import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4F7F3B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF4F7F3B),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          onTap: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0: Get.offAllNamed('/student_dashboard'); break;
              case 1: Get.offAllNamed('/student_tasks'); break;
              case 2: Get.offAllNamed('/student_feedback'); break;
              case 3: Get.offAllNamed('/student_profile'); break;
              default: Get.offAllNamed('/student_dashboard');
            }
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
