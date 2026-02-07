import 'package:bridging_students_and_academics_platform/Supervisor/group/group_members_page.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/messages/supervisor_messages_page.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/supervisor_controller.dart';
import '../custom/custom_bottom_bar.dart';

class SupervisorGroupsPage extends StatefulWidget {
  const SupervisorGroupsPage({super.key});

  @override
  State<SupervisorGroupsPage> createState() => _SupervisorGroupsPageState();
}

class _SupervisorGroupsPageState extends State<SupervisorGroupsPage> {
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());
  final GetStorage _storage = GetStorage();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _storage.read('user_name') ?? 'Supervisor';
    final profileImage = _storage.read<String>('user_image');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(userName, profileImage),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Assigned Groups",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search by group name...",
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4A6D3F)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4A6D3F)));
                }
                final query = _searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? controller.groups
                    : controller.groups.where((g) {
                        final name = (g['name']?.toString() ?? '').toLowerCase();
                        return name.contains(query);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          query.isEmpty ? "No groups assigned to you." : "No groups match \"$query\".",
                          textAlign: TextAlign.center,
                        ),
                        if (query.isEmpty)
                          TextButton(
                            onPressed: () => controller.fetchGroups(),
                            child: const Text("Refresh", style: TextStyle(color: Color(0xFF4A6D3F))),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => controller.fetchGroups(),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final group = filtered[index];
                      final String gName = group['name']?.toString() ?? 'Unnamed';
                      final int count = group['memberCount'] ?? 0;

                      return InkWell(
                        onTap: () => Get.to(() => SupervisorGroupMembersPage(groupName: gName)),
                        child: _buildGroupCard(gName, count),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SupervisorBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1: Get.offAllNamed('/supervisor_tasks'); break;
            case 2: Get.offAllNamed('/supervisor_submissions'); break;
            case 3: Get.offAllNamed('/supervisor_profile'); break;
            default: Get.offAllNamed('/supervisor_dashboard');
          }
        },
      ),
    );
  }

  Widget _buildHeader(String name, String? profileImageUrl) {
    final hasImage = profileImageUrl != null && profileImageUrl.trim().isNotEmpty;
    final fullImageUrl = hasImage ? '${AppConfig.imageBaseUrl}$profileImageUrl' : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6D3F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            backgroundImage: fullImageUrl != null
                ? NetworkImage(fullImageUrl)
                : null,
            child: fullImageUrl == null
                ? const Icon(Icons.person_rounded, color: Color(0xFF4A6D3F))
                : null,
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
            onPressed: () => Get.to(() => const SupervisorMessagesPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(String name, int members) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_rounded, color: Color(0xFF4A6D3F), size: 40),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text("$members Members", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}