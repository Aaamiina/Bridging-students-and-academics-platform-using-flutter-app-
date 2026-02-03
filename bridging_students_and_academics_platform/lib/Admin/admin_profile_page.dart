import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final adminController = Get.find<AdminController>();
    final Color brandGreen = const Color(0xFF4A6D3F);

    return Stack(
      children: [
        // Header Background
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: brandGreen,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "Admin Profile",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif'),
            ),
          ),
        ),
        
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 20),
          child: Column(
            children: [
              /// Main Profile Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Obx(() {
                  final user = authController.user.value;
                  final name = user?.name ?? "Admin User";
                  final email = user?.email ?? "admin@example.com";
                  final imgUrl = user?.profileImage;

                  return Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFA6BC9D),
                            backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                                ? NetworkImage("${AppConfig.imageBaseUrl}$imgUrl")
                                : null,
                            child: (imgUrl == null || imgUrl.isEmpty)
                                ? const Icon(Icons.person, size: 45, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(Icons.edit_outlined, size: 18, color: brandGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif')),
                      const Text("System Administrator", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 25),

              /// Stat Cards
              Obx(() {
                final s = adminController.stats;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("${s['tasks'] ?? 0}", "Tasks"),
                    _buildStatCard("${s['supervisors'] ?? 0}", "Supervisors"),
                    _buildStatCard("${s['groups'] ?? 0}", "Groups"),
                  ],
                );
              }),

              const SizedBox(height: 30),

              /// Menu Items
              _buildMenuItem(Icons.edit_outlined, "Edit Profile", () {}),
              _buildMenuItem(Icons.lock_outline, "Change Password", () {}),
              _buildMenuItem(Icons.logout, "Logout", () => authController.logout(), isDestructive: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1E4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF4A6D3F))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF4A6D3F), size: 20),
        title: Text(title, style: TextStyle(fontSize: 14, color: isDestructive ? Colors.red : Colors.black87)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
