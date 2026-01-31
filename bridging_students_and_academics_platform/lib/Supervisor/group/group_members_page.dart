import 'package:flutter/material.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupName;
  const GroupMembersPage({super.key, required this.groupName});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  // Mock data for members
  final List<Map<String, String>> members = List.generate(
    5,
    (index) => {
      "name": "Asma Abdi Ali",
      "date": "Due Feb 25 2026",
      "status": "Active"
    },
  );

  // Function to show the status toggle (Frame 57)
  void _showStatusToggle(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, color: Colors.grey, size: 40),
              ),
              const SizedBox(height: 10),
              Text(
                members[index]["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                members[index]["date"]!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Status", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 10),
              // The Toggle/Button shown in Frame 57
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    members[index]["status"]!,
                    style: const TextStyle(color: Color(0xFF4A6D3F), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Group: ${widget.groupName}", 
          style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(radius: 15, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: members.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _showStatusToggle(index),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(members[index]["name"]!, 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(members[index]["date"]!, 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        members[index]["status"]!,
                        style: const TextStyle(color: Color(0xFF4A6D3F), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}