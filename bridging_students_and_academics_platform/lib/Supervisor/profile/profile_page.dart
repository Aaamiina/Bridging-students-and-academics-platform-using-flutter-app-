import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bridging_students_and_academics_platform/controllers/supervisor_controller.dart';
import 'package:bridging_students_and_academics_platform/core/validators.dart';
import 'package:bridging_students_and_academics_platform/data/repositories/auth_repository.dart';

class ProfilePageSup extends StatefulWidget {
  const ProfilePageSup({super.key});

  @override
  State<ProfilePageSup> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageSup> {
  final _formKey = GlobalKey<FormState>();
  final SupervisorController controller = Get.isRegistered<SupervisorController>()
      ? Get.find<SupervisorController>()
      : Get.put(SupervisorController());
  final GetStorage _storage = GetStorage();
  final int _selectedIndex = 3;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    controller.loadUserData();
    final user = _storage.read<Map>('user');
    final phone = user?['phone']?.toString();
    final name = controller.userName.value.isNotEmpty ? controller.userName.value : _storage.read('user_name') ?? '';
    final email = controller.userEmail.value.isNotEmpty ? controller.userEmail.value : _storage.read('user_email') ?? '';
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone ?? 'Not Set');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: const BoxDecoration(color: Color(0xFFB7CFB1), shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 60, color: Colors.black54),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF4A6D3F), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Profile Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Full Name"),
                      _buildProfileTextFormField(_nameController, validator: (v) => Validators.required(v, 'Full name') ?? Validators.name(v)),
                      const SizedBox(height: 20),
                      _buildLabel("Email Address"),
                      _buildProfileTextField(_emailController, isEnabled: false),
                      const SizedBox(height: 20),
                      _buildLabel("Phone Number"),
                      _buildProfileTextFormField(_phoneController, validator: Validators.phone),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6D3F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) _updateProfile();
                      },
                      child: const Text("Update Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showLogoutDialog(),
                      child: const Text("Logout", style: TextStyle(color: Color(0xFFD32F2F), fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: SupervisorBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          switch (index) {
            case 0: Get.offAllNamed('/supervisor_dashboard'); break;
            case 1: Get.offAllNamed('/supervisor_tasks'); break;
            case 2: Get.offAllNamed('/supervisor_submissions'); break;
            case 3: Get.offAllNamed('/supervisor_profile'); break;
          }
        },
      ),
    );
  }

  Future<void> _updateProfile() async {
    final token = _storage.read<String>('token');
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Not logged in", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    controller.isLoading.value = true;
    final updated = await AuthRepository().updateProfile(
      token,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim() == 'Not Set' ? '' : _phoneController.text.trim(),
    );
    controller.isLoading.value = false;
    if (updated != null) {
      final user = _storage.read<Map>('user') ?? {};
      user['name'] = updated['name'];
      user['email'] = updated['email'];
      if (updated['phone'] != null) user['phone'] = updated['phone'];
      _storage.write('user', user);
      controller.userName.value = updated['name']?.toString() ?? '';
      if (updated['phone'] != null) _phoneController.text = updated['phone'].toString();
      Get.snackbar("Success", "Profile updated", backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Failed to update profile", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to exit?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFD32F2F),
      onConfirm: () => controller.logout(),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A6D3F))),
  );

  Widget _buildProfileTextField(TextEditingController controller, {bool isEnabled = true}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: isEnabled ? Colors.white : const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A6D3F)),
        ),
      ),
    );
  }

  Widget _buildProfileTextFormField(TextEditingController controller, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A6D3F)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      validator: validator,
    );
  }
}