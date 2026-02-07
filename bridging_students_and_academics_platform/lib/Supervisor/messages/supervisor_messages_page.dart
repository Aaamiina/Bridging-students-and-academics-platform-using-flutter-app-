import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/message_repository.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/messages/chat_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/messages/select_student_page.dart';

class SupervisorMessagesPage extends StatefulWidget {
  const SupervisorMessagesPage({super.key});

  @override
  State<SupervisorMessagesPage> createState() => _SupervisorMessagesPageState();
}

class _SupervisorMessagesPageState extends State<SupervisorMessagesPage> {
  final MessageRepository _repo = MessageRepository();
  List<dynamic> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getConversations();
    setState(() {
      _conversations = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("Messages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 24),
            tooltip: "Start conversation",
            onPressed: () => Get.to(() => const SelectStudentPage()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("No messages yet", style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      const Text("Tap the + icon above to start a conversation with a student.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final c = _conversations[index] as Map<String, dynamic>;
                      final userId = c['userId']?.toString() ?? c['userId']?['_id']?.toString() ?? '';
                      final name = c['name']?.toString() ?? 'Unknown';
                      final lastMsg = c['lastMessage']?.toString() ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4A6D3F).withOpacity(0.15),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF4A6D3F)),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600)),
                        onTap: () => Get.to(() => ChatPage(otherUserId: userId, otherName: name)),
                      );
                    },
                  ),
                ),
    );
  }
}
