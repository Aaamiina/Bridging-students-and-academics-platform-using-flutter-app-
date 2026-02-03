import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/supervisor_controller.dart';
import '../custom/custom_bottom_bar.dart';

class SupervisorGroupsPage extends StatelessWidget {
  SupervisorGroupsPage({super.key});

  final SupervisorController controller = Get.put(SupervisorController(), permanent: true);
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
              child: Text(
                "Your Assigned Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No groups assigned to you."),
                        TextButton(
                          onPressed: () => controller.fetchGroups(),
                          child: const Text("Refresh"),
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
                      // FIX: Pass only 2 arguments to match the function definition below
                      return _buildGroupCard(
                        group['title'] ?? group['name'] ?? 'Unnamed', 
                        group['memberCount'] ?? 0,
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
          // Navigation logic...
          if (index == 1) Get.toNamed('/supervisor_tasks');
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
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white, 
                child: Icon(Icons.person, color: Color(0xFF537A40))
              ),
              const SizedBox(width: 12),
              Text(
                name, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
              const Spacer(),
              const Icon(Icons.chat_bubble, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // Updated to properly receive exactly 2 arguments
  Widget _buildGroupCard(String name, int members) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups, color: Color(0xFF537A40), size: 40),
          const SizedBox(height: 8),
          Text(
            name, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "$members Members", 
            style: const TextStyle(color: Colors.grey, fontSize: 12)
          ),
        ],
      ),
    );
  }
}