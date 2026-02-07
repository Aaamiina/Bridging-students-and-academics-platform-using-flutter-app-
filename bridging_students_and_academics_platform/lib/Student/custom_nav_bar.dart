import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A6D3F),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          onTap: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0: Get.offAllNamed('/student_dashboard'); break;
              case 1: Get.offAllNamed('/student_tasks'); break;
              case 2: Get.offAllNamed('/student_feedback'); break;
              case 3: Get.offAllNamed('/student_messages'); break;
              case 4: Get.offAllNamed('/student_profile'); break;
              default: Get.offAllNamed('/student_dashboard');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 22), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded, size: 22), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.rate_review_rounded, size: 22), label: 'Feedback'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded, size: 22), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 22), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
