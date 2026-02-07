import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/core/validators.dart';
import 'package:bridging_students_and_academics_platform/log_admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final RxBool isSupervisor = true.obs;

  @override
  void dispose() {
    _emailOrIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final trimmedEmailOrId = _emailOrIdController.text.trim();
    final trimmedPassword = _passwordController.text.trim();

    // Close any previous login-failed snackbar so only validation errors show
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    // 1. Frontend validation first – do not send to backend until format is valid
    if (isSupervisor.value) {
      final emailError = Validators.email(trimmedEmailOrId);
      if (emailError != null) {
        _formKey.currentState?.validate();
        return;
      }
    } else {
      final idOrEmailError = Validators.idOrEmail(trimmedEmailOrId);
      if (idOrEmailError != null) {
        _formKey.currentState?.validate();
        return;
      }
    }
    final passwordError = Validators.password(trimmedPassword, minLength: 3);
    if (passwordError != null) {
      _formKey.currentState?.validate();
      return;
    }

    // 2. All formats valid – now call backend (backend only returns account/password messages)
    final authController = Get.find<AuthController>();
    authController.login(trimmedEmailOrId, trimmedPassword, isSupervisor.value);
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

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
                        children: [
                          Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _switchButton("Supervisor", isSupervisor.value, true, isSupervisor),
                                  _switchButton("Student", !isSupervisor.value, false, isSupervisor),
                                ],
                              )),
                          const SizedBox(height: 20),
                          Center(
                            child: Obx(() => Text(
                                  isSupervisor.value ? "ACADEMIC LOGIN" : "STUDENT LOGIN",
                                  style: const TextStyle(
                                    fontFamily: 'InriaSerif',
                                    color: Color(0xFF4A6D3F),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                )),
                          ),
                          const SizedBox(height: 25),
                          Obx(() => _label(isSupervisor.value ? "Academic Email" : "University ID or Email")),
                          Obx(() => _buildEmailOrIdField(isSupervisor.value)),
                          _label("Password"),
                          _buildPasswordField(),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: Obx(() => ElevatedButton(
                                  onPressed: authController.isLoading.value ? null : _onLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A6D3F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                )),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: TextButton(
                              onPressed: () => Get.toNamed('/admin_login'),
                              child: const Text(
                                "Login As Admin",
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

  Widget _switchButton(String text, bool active, bool stateValue, RxBool stateController) {
    return GestureDetector(
      onTap: () {
        stateController.value = stateValue;
        _formKey.currentState?.reset();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4A6D3F) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF4A6D3F)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'InriaSerif',
            color: active ? Colors.white : const Color(0xFF4A6D3F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'InriaSerif',
          fontSize: 14,
          color: Color(0xFF4F7F3B),
        ),
      ),
    );
  }

  Widget _buildEmailOrIdField(bool isSupervisorMode) {
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
        key: Key('login_email_or_id_$isSupervisorMode'),
        controller: _emailOrIdController,
        keyboardType: isSupervisorMode ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: isSupervisorMode ? "supervisor@example.com" : "ID or email",
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) {
          if (isSupervisorMode) return Validators.email(value);
          return Validators.idOrEmail(value);
        },
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
          hintText: "Password",
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) => Validators.password(value, minLength: 3),
      ),
    );
  }
}
