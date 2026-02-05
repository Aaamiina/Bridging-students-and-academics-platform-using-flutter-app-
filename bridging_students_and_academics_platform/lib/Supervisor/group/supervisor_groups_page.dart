import 'package:bridging_students_and_academics_platform/Supervisor/group/group_members_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/supervisor_controller.dart';
import '../custom/custom_bottom_bar.dart';

class SupervisorGroupsPage extends StatelessWidget {
  SupervisorGroupsPage({super.key});

  // Use Get.find if already put, otherwise put it. 
  // This helps avoid the GlobalKey duplication error.
  final SupervisorController controller = Get.isRegistered<SupervisorController>() 
      ? Get.find<SupervisorController>() 
      : Get.put(SupervisorController());
      
  final GetStorage _storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userName = _storage.read('user_name') ?? 'Supervisor';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(userName),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Assigned Groups",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF537A40)));
                }
                if (controller.groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No groups assigned to you."),
                        TextButton(
                          onPressed: () => controller.fetchGroups(),
                          child: const Text("Refresh", style: TextStyle(color: Color(0xFF537A40))),
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
                    itemCount: controller.groups.length,
                    itemBuilder: (context, index) {
                      final group = controller.groups[index];
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

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF537A40),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white, 
            child: Icon(Icons.person, color: Color(0xFF537A40))
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.chat_bubble, color: Colors.white),
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
          const Icon(Icons.groups, color: Color(0xFF537A40), size: 40),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text("$members Members", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}