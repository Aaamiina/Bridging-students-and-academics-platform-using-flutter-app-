import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:bridging_students_and_academics_platform/core/validators.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:bridging_students_and_academics_platform/api/api_users.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;
    if (user == null || user.id.isEmpty) {
      Get.snackbar("Error", "User ID not found. Please log in again.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController();
    Uint8List? imageBytes;
    String? imageFilename;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (v) => Validators.required(v, 'Name') ?? Validators.name(v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone (optional)"),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      imageBytes = bytes;
                      imageFilename = picked.name;
                      Get.snackbar("", "Image selected", backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 1));
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(imageBytes != null ? "Change Photo" : "Add Photo"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6D3F)),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final res = await ApiUsers().updateUser(
                user.id,
                {"name": nameCtrl.text.trim(), "email": emailCtrl.text.trim(), "phone": phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()},
                imageBytes: imageBytes,
                imageFilename: imageFilename,
              );
              if (context.mounted) Get.back();
              if (res != null) {
                final updatedName = res['name']?.toString() ?? nameCtrl.text.trim();
                final updatedEmail = res['email']?.toString() ?? emailCtrl.text.trim();
                final updatedImage = res['profileImage']?.toString();
                authController.updateStoredUser(
                  name: updatedName,
                  email: updatedEmail,
                  phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                  profileImage: updatedImage,
                );
                Get.snackbar("Success", "Profile updated", backgroundColor: Colors.green, colorText: Colors.white);
              } else {
                Get.snackbar("Error", "Failed to update profile", backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text("Change Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
                validator: (v) => Validators.password(v, minLength: 4),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm New Password"),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your password';
                  if (v != newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6D3F)),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final ok = await authController.changePassword(newCtrl.text);
              if (context.mounted) Get.back();
              if (ok) {
                Get.snackbar("Success", "Password changed", backgroundColor: Colors.green, colorText: Colors.white);
              } else {
                Get.snackbar("Error", "Failed to change password", backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

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
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: (imgUrl != null && imgUrl.isNotEmpty)
                                  ? Image.network(
                                      "${AppConfig.imageBaseUrl}$imgUrl",
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFA6BC9D),
                                        child: const Icon(Icons.person, size: 45, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFFA6BC9D),
                                      child: const Icon(Icons.person, size: 45, color: Colors.white),
                                    ),
                            ),
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
              _buildMenuItem(Icons.edit_outlined, "Edit Profile", () => _showEditProfileDialog(context)),
              _buildMenuItem(Icons.lock_outline, "Change Password", () => _showChangePasswordDialog(context)),
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
