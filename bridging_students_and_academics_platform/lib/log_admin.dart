import 'package:flutter/material.dart';
import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:get/get.dart'; 

class logAdmin extends StatefulWidget {
  const logAdmin({super.key});

  @override
  State<logAdmin> createState() => _logAdminState();
}

class _logAdminState extends State<logAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    print("DEBUG: log_admin.dart - _handleLogin button clicked");
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      print("DEBUG: log_admin.dart - Validation failed: empty fields");
      _showError("Please enter email and password");
      return;
    }
    
    final AuthController authController = Get.find<AuthController>();
    print("DEBUG: log_admin.dart - Dispatching login to AuthController: ${_emailController.text}");
    authController.login(_emailController.text.trim(), _passwordController.text.trim(), true); 
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.redAccent, 
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_rounded, size: 100, color: Color(0xFF4A6D3F)),
              const SizedBox(height: 10),
              const Text(
                "SIGN IN (v3)", 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF4A6D3F), 
                  letterSpacing: 2.0
                )
              ),
              const SizedBox(height: 50),
              _buildLabel("Email"),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "admin@example.com", 
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))
                ),
              ),
              const SizedBox(height: 30),
              _buildLabel("Password"),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  final authController = Get.find<AuthController>();
                  return ElevatedButton(
                    onPressed: authController.isLoading.value ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6D3F), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: authController.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft, 
      child: Text(
        text.toUpperCase(), 
        style: const TextStyle(color: Color(0xFF4A6D3F), fontWeight: FontWeight.bold, fontSize: 12)
      )
    );
  }
}