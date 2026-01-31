import 'package:bridging_students_and_academics_platform/Student/dashboard_page.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_dashboard.dart';
import 'package:bridging_students_and_academics_platform/Supervisor/group/supervisor_groups_page.dart';
import 'package:bridging_students_and_academics_platform/log_admin.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSupervisor = true; // Switch between Supervisor / Student

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // TOP RIGHT CIRCLES
            Positioned(
              top: -50,
              right: -5,
              child: Container(
                width: 110,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C763B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
      
            // BOTTOM LEFT CIRCLES
            Positioned(
              bottom: -50,
              left: -10,
              child: Container(
                width: 120,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -25,
              left: -25,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F7F3B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
      
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _switchButton("Supervisor", _isSupervisor, true),
                            _switchButton("Student", !_isSupervisor, false),
                          ],
                        ),
                        const SizedBox(height: 20),
      
                        Center(
                          child: Text(
                            _isSupervisor ? "SUPERVISOR LOGIN" : "STUDENT LOGIN",
                            style: TextStyle(
                              fontFamily: 'InriaSerif',
                              color: Colors.green.shade800,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
      
                        _label("Email"),
                        _shadowInput(controller: _emailController),
      
                        _label("Password"),
                        _shadowInput(controller: _passwordController, isPassword: true),
      
                        const SizedBox(height: 25),
      
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_isSupervisor) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => SupervisorGroupsPage()));
                              } else {
                                // TODO: Student home page
                                 Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => StudentDashboard()));
                              
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F7F3B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'InriaSerif',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
      
                        const SizedBox(height: 15),
      
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => logAdmin()));
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

  // SWITCH BUTTON
  Widget _switchButton(String text, bool active, bool isSupervisor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSupervisor = isSupervisor;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: active ? Color(0xFF4F7F3B) : Colors.white,
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
  Widget _shadowInput({required TextEditingController controller, bool isPassword = false}) {
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
