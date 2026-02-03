import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/custom/custom_bottom_bar.dart';
import 'package:get/get.dart';


class ProfilePageSup extends StatefulWidget {
  const ProfilePageSup({super.key});

  @override
  State<ProfilePageSup> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageSup> {
  final int _selectedIndex = 3; // Highlight 'Profile' tab

  // Controllers for the profile fields
  final TextEditingController _nameController = TextEditingController(text: "Asma Umar Abdi");
  final TextEditingController _emailController = TextEditingController(text: "asma@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+252 612345678");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6D3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile", // Note: Your Frame 46 says "Submissions" in the header, likely a placeholder. I used "Profile" for clarity.
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Profile Image Section with Edit Icon
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB7CFB1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.black54),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A6D3F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Profile Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Full Name"),
                    _buildProfileTextField(_nameController),
                    const SizedBox(height: 20),
                    
                    _buildLabel("Email"),
                    _buildProfileTextField(_emailController),
                    const SizedBox(height: 20),
                    
                    _buildLabel("Phone"),
                    _buildProfileTextField(_phoneController),
                  ],
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
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6D3F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Logic to save profile
                      },
                      child: const Text("Save Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F), // Red for Logout
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Logic to logout
                      },
                      child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
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
            default: Get.offAllNamed('/supervisor_dashboard');
          }
        },
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text, 
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
    ),
  );

  Widget _buildProfileTextField(TextEditingController controller) {
    return TextField(
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
      ),
    );
  }
}