import 'package:flutter/material.dart';

class SupervisorBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SupervisorBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // The outer container handles the background/shadow look
      decoration: const BoxDecoration(
        color: Color(0xFF4A6D3F), // Your exact green color
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
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Let the container color show
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded, size: 24),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded, size: 24),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_rounded, size: 24),
              label: 'Submissions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}