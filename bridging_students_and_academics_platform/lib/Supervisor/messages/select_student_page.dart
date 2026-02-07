import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/supervisor_repository.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/messages/chat_page.dart';

/// Lets the supervisor pick a student from their groups to start a conversation.
class SelectStudentPage extends StatefulWidget {
  const SelectStudentPage({super.key});

  @override
  State<SelectStudentPage> createState() => _SelectStudentPageState();
}

class _SelectStudentPageState extends State<SelectStudentPage> {
  final SupervisorRepository _repo = SupervisorRepository();
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _repo.getMyGroups();
      if (groups.isEmpty) {
        setState(() {
          _students = [];
          _loading = false;
        });
        return;
      }
      final Map<String, Map<String, dynamic>> byId = {};
      for (final g in groups) {
        final name = g['name']?.toString();
        if (name == null || name.isEmpty) continue;
        final members = await _repo.getGroupMembers(name);
        for (final m in members) {
          final id = m['_id']?.toString();
          if (id == null) continue;
          byId[id] = {
            '_id': id,
            'name': m['name']?.toString() ?? 'Student',
          };
        }
      }
      setState(() {
        _students = byId.values.toList()
          ..sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("Start conversation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _loadStudents,
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A6D3F)),
                          label: const Text("Retry", style: TextStyle(color: Color(0xFF4A6D3F))),
                        ),
                      ],
                    ),
                  ),
                )
              : _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text("No students in your groups", style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          const Text("Students appear here when they are assigned to your groups.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStudents,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final s = _students[index];
                          final id = s['_id']?.toString() ?? '';
                          final name = s['name']?.toString() ?? 'Student';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF4A6D3F).withOpacity(0.15),
                                child: const Icon(Icons.person_rounded, color: Color(0xFF4A6D3F)),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              trailing: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4A6D3F), size: 22),
                              onTap: () => Get.to(() => ChatPage(otherUserId: id, otherName: name)),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
