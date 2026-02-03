import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';

class AdminStatsView extends StatelessWidget {
  final Function(int)? onCardTap;
  const AdminStatsView({super.key, this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();
    final AuthController authController = Get.find<AuthController>();
    final Color brandGreen = const Color(0xFF4A6D3F);

    return RefreshIndicator(
      onRefresh: () async => controller.fetchData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final name = authController.user.value?.name ?? "Admin";
              return Row(
                children: [
                   Text(
                    "Welcome back, $name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("👋", style: TextStyle(fontSize: 20)),
                ],
              );
            }),
            const SizedBox(height: 25),
            
            // Stats Grid
            Obx(() {
              if (controller.isLoading.value && controller.totalUsersCount.value == 0) {
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildStatCard(
                    context,
                    "Users",
                    controller.totalUsersCount.value.toString(),
                    Icons.people,
                    brandGreen,
                    onTap: () => onCardTap?.call(1),
                  ),
                  _buildStatCard(
                    context,
                    "Supervisors",
                    controller.supervisors.length.toString(),
                    Icons.supervisor_account,
                    brandGreen,
                    onTap: () => onCardTap?.call(2),
                  ),
                  _buildStatCard(
                    context,
                    "Groups",
                    controller.groups.length.toString(),
                    Icons.group_work,
                    brandGreen,
                    onTap: () => onCardTap?.call(3),
                  ),
                  _buildStatCard(
                    context,
                    "Students",
                    controller.students.length.toString(),
                    Icons.person,
                    brandGreen,
                    onTap: () => onCardTap?.call(1), // Students are also in Users page (filtered usually)
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 30),
            
            // Optional: Recent Activity or shortcut section
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: brandGreen),
            ),
            const SizedBox(height: 15),
            _buildQuickAction(context, "Create New Group", Icons.add_circle_outline, brandGreen, onTap: () => onCardTap?.call(3)),
            _buildQuickAction(context, "Add New User", Icons.person_add_alt_1_outlined, brandGreen, onTap: () => onCardTap?.call(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
