import 'package:flutter/material.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4F7F3B),
        title: const Text(
          "Admin Profile",
          style: TextStyle(
            fontFamily: 'InriaSerif',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  /// Avatar
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF4F7F3B),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Name
                  const Text(
                    "Admin User",
                    style: TextStyle(
                      fontFamily: 'InriaSerif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Role
                  Text(
                    "System Administrator",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Email
                  Text(
                    "admin@example.com",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Tasks", "24"),
                _buildStatCard("Supervisors", "8"),
                _buildStatCard("Groups", "12"),
              ],
            ),

            const SizedBox(height: 28),

            /// Actions
            _buildActionTile(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () {},
            ),

            _buildActionTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {},
            ),

            _buildActionTile(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.red,
              onTap: () {
                // TODO: logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Stat Card
  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1E4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F7F3B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action Tile
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color color = const Color(0xFF4F7F3B),
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
