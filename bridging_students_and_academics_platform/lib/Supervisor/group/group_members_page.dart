import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../core/app_config.dart';

class SupervisorGroupMembersPage extends StatefulWidget {
  final String groupName;
  const SupervisorGroupMembersPage({super.key, required this.groupName});

  @override
  State<SupervisorGroupMembersPage> createState() => _SupervisorGroupMembersPageState();
}

class _SupervisorGroupMembersPageState extends State<SupervisorGroupMembersPage> {
  List<dynamic> members = [];
  bool isLoading = true;
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final token = _storage.read('token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/supervisor/groups/${widget.groupName}/members'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          members = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  // This function creates the toggle appearance from your Figma/Image design
  void _showMemberToggle(dynamic member) {
    String name = member['name']?.toString() ?? 'Unknown';
    String statusText = "Active";
    if (member['status'] is bool) {
      statusText = member['status'] == true ? "Active" : "Inactive";
    } else {
      statusText = member['status']?.toString() ?? "Active";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Allows rounded corners
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gray handle bar at top
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFD1DBCE),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                "Due Feb 25 2026", // Place holder for date if available in your model
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Status", style: TextStyle(color: Color(0xFF4A6D3F), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              // The large toggle button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    statusText,
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
        title: Text("Members: ${widget.groupName}", style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage('assets/profile_placeholder.png'), // Add your actual asset
            ),
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)))
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: members.length,
            itemBuilder: (context, index) => _buildMemberTile(members[index]),
          ),
    );
  }

  Widget _buildMemberTile(dynamic member) {
    String name = member['name']?.toString() ?? 'Unknown';
    String email = member['email']?.toString() ?? '';
    
    String statusText = "Active";
    if (member['status'] != null) {
      if (member['status'] is bool) {
        statusText = member['status'] == true ? "Active" : "Inactive";
      } else {
        statusText = member['status'].toString();
      }
    }

    return GestureDetector(
      onTap: () => _showMemberToggle(member), // Triggers the bottom sheet
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFD1DBCE),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text("Due Feb 25 2026", style: TextStyle(color: Colors.grey, fontSize: 10)),
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
                statusText,
                style: const TextStyle(color: Color(0xFF4A6D3F), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}