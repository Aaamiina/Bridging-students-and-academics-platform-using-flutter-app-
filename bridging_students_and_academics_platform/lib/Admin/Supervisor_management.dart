import 'package:flutter/material.dart';

class SupervisorManagementPage extends StatelessWidget {
  const SupervisorManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey to control the scaffold (useful if you want to open drawer via button)
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F4F0),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Supervisor Management",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildUserCard(
                  name: "Ahmed Ali",
                  username: "RayanAhmed . student",
                  role: "Supervisor",
                  isAssigned: false,
                ),
                const SizedBox(height: 15),
                _buildUserCard(
                  name: "Sofia Hussein",
                  username: "RayanAhmed . student",
                  role: "Supervisor",
                  isAssigned: true,
                  assignedGroup: "Group A",
                ),
                const SizedBox(height: 15),
                _buildUserCard(
                  name: "Mahamed Noor",
                  username: "RayanAhmed . student",
                  role: "Supervisor",
                  isAssigned: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reuse the _buildUserCard helper from previous code...
  Widget _buildUserCard({
    required String name,
    required String username,
    required String role,
    required bool isAssigned,
    String? assignedGroup,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFD1DBCE),
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(username, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1DBCE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (!isAssigned)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6D3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {},
                child: const Text("Assign Group", style: TextStyle(color: Colors.white)),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text("Assigned Group: $assignedGroup", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}