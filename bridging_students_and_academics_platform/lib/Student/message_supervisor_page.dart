import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/student_repository.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/messages/chat_page.dart';

/// Student: load my supervisor then open chat with them.
class MessageSupervisorPage extends StatefulWidget {
  const MessageSupervisorPage({super.key});

  @override
  State<MessageSupervisorPage> createState() => _MessageSupervisorPageState();
}

class _MessageSupervisorPageState extends State<MessageSupervisorPage> {
  final StudentRepository _repo = StudentRepository();
  Map<String, dynamic>? _supervisor;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sup = await _repo.getMySupervisor();
    setState(() {
      _supervisor = sup;
      _loading = false;
      _error = sup == null ? 'No supervisor assigned to your group.' : null;
    });
    if (sup != null && sup['id'] != null && sup['name'] != null) {
      Get.off(() => ChatPage(
            otherUserId: sup['id'].toString(),
            otherName: sup['name'].toString(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("Message Supervisor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
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
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: Text("Loading...")),
    );
  }
}
