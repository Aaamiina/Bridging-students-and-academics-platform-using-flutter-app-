import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/core/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class logAdmin extends StatefulWidget {
  const logAdmin({super.key});

  @override
  State<logAdmin> createState() => _logAdminState();
}

class _logAdminState extends State<logAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    final authController = Get.find<AuthController>();
    authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(top: -50, right: -5, child: _circle(110, 200, const Color(0xFF4A6D3F).withOpacity(0.3))),
            Positioned(top: -20, right: -20, child: _circle(110, 110, const Color(0xFF4A6D3F))),
            Positioned(bottom: -50, left: -10, child: _circle(120, 200, const Color(0xFF4A6D3F).withOpacity(0.25))),
            Positioned(bottom: -25, left: -25, child: _circle(120, 120, const Color(0xFF4A6D3F))),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Icon(Icons.school_rounded, size: 64, color: const Color(0xFF4A6D3F)),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              "ADMIN LOGIN",
                              style: const TextStyle(
                                fontFamily: 'InriaSerif',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A6D3F),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildLabel("Email"),
                          _buildEmailField(),
                          _buildLabel("Password"),
                          _buildPasswordField(),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: Obx(() {
                              final authController = Get.find<AuthController>();
                              return ElevatedButton(
                                onPressed: authController.isLoading.value ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A6D3F),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: authController.isLoading.value
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontFamily: 'InriaSerif',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                "Back to Login",
                                style: TextStyle(
                                  fontFamily: 'InriaSerif',
                                  fontSize: 14,
                                  color: Color(0xFF4A6D3F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double w, double h, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'InriaSerif',
          fontSize: 14,
          color: Color(0xFF4A6D3F),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: "admin@example.com",
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: Validators.email,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: "Enter your password",
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: (v) => Validators.password(v, minLength: 3),
      ),
    );
  }
}
