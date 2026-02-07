import 'package:flutter/material.dart';

class AdminGroupMembersPage extends StatefulWidget {
  const AdminGroupMembersPage({super.key});

  @override
  State<AdminGroupMembersPage> createState() => _AdminGroupMembersPageState();
}

class _AdminGroupMembersPageState extends State<AdminGroupMembersPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<Map<String, String>> _members = [
    {"name": "Asma Abdi Ali", "date": "Feb 25, 2025", "avatar": "assets/images/profile.jpg"},
    {"name": "Mohamed Usman Umar", "date": "Feb 25, 2025", "avatar": "assets/images/profile2.jpg"},
    {"name": "Amina Ali Ahmed", "date": "Feb 25, 2025", "avatar": "assets/images/profile3.jpg"},
    {"name": "Baysar Ahmed Lomale", "date": "Feb 25, 2025", "avatar": "assets/images/profile4.jpg"},
    {"name": "Asma Abdi Ali", "date": "Feb 25, 2025", "avatar": "assets/images/profile.jpg"},
  ];

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredMembers = _members
        .where((m) =>
            m['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF4A6D3F),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Group: A",
                    style: TextStyle(
                      fontFamily: 'InriaSerif',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF757575)),
                    hintText: "Search..",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // MEMBERS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + index * 100),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: _memberCard(member),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF4A6D3F),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 24), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded, size: 24), label: "Task"),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded, size: 24), label: "Submission"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 24), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

Widget _memberCard(Map<String, String> member) {
  return GestureDetector(
    onTap: () {
      // Show member info modal
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _memberDetailSheet(member),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(member['avatar']!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name']!,
                  style: const TextStyle(
                    fontFamily: 'InriaSerif',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Joined: ${member['date']}",
                  style: TextStyle(
                    fontFamily: 'InriaSerif',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Active",
              style: TextStyle(
                fontFamily: 'InriaSerif',
                fontSize: 13,
                color: Color(0xFF4A6D3F),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
Widget _memberDetailSheet(Map<String, String> member) {
  return DraggableScrollableSheet(
    initialChildSize: 0.35,
    minChildSize: 0.2,
    maxChildSize: 0.6,
    builder: (context, scrollController) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(member['avatar']!),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                member['name']!,
                style: const TextStyle(
                  fontFamily: 'InriaSerif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Joined: ${member['date']}",
                style: TextStyle(
                  fontFamily: 'InriaSerif',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 16),
            Text(
              "Status",
              style: TextStyle(
                fontFamily: 'InriaSerif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Active",
                style: TextStyle(
                  fontFamily: 'InriaSerif',
                  fontSize: 13,
                  color: Color(0xFF4A6D3F),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Additional Info",
              style: TextStyle(
                fontFamily: 'InriaSerif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "This is some placeholder information about the member. You can show email, role, tasks completed, or any other details here.",
              style: TextStyle(
                fontFamily: 'InriaSerif',
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    },
  );
}

}
