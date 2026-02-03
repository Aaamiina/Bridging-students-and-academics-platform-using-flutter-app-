import 'package:bridging_students_and_academics_platform/controllers/auth_controller.dart';
import 'package:bridging_students_and_academics_platform/log_admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is now initialized in main.dart globally
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    // Using RxBool for local UI toggle state
    final RxBool isSupervisor = true.obs;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // DECORATIVE CIRCLES
            Positioned(top: -50, right: -5, child: _circle(110, 200, Colors.green.withOpacity(0.3))),
            Positioned(top: -20, right: -20, child: _circle(110, 110, const Color(0xFF4C763B))),
            Positioned(bottom: -50, left: -10, child: _circle(120, 200, Colors.green.withOpacity(0.25))),
            Positioned(bottom: -25, left: -25, child: _circle(120, 120, const Color(0xFF4F7F3B))),

            // MAIN CARD
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LOGIN TYPE SWITCH
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
                                style: TextStyle(
                                  fontFamily: 'InriaSerif',
                                  color: Colors.green.shade800,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              )),
                        ),
                        const SizedBox(height: 25),

                        Obx(() => _label(isSupervisor.value ? "Academic Email" : "University ID")),
                        Obx(() => _shadowInput(
                          controller: emailController, 
                          hintText: isSupervisor.value ? "supervisor@example.com" : "Registration ID"
                        )),

                        _label("Password"),
                        _shadowInput(controller: passwordController, isPassword: true),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: Obx(() => ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () {
                                        print("DEBUG: Login button pressed in UI");
                                        authController.login(
                                          emailController.text,
                                          passwordController.text,
                                          isSupervisor.value,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F7F3B),
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
                            onPressed: () {
                               // Assuming logAdmin is still manual nav or needs refactor later
                               Get.toNamed('/admin_login');
                            },
                            child: const Text(
                              "Login As Admin",
                              style: TextStyle(
                                fontFamily: 'InriaSerif',
                                fontSize: 14,
                                color: Color(0xFF4F7F3B),
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

  // SWITCH BUTTON
  Widget _switchButton(String text, bool active, bool stateValue, RxBool stateController) {
    return GestureDetector(
      onTap: () {
        stateController.value = stateValue;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4F7F3B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green.shade800),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'InriaSerif',
            color: active ? Colors.white : Colors.green.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // LABEL
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

  // SHADOW INPUT
  Widget _shadowInput({required TextEditingController controller, bool isPassword = false, String? hintText}) {
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
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
