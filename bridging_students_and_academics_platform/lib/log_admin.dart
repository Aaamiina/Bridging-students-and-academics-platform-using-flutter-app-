import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'api/login.dart'; 

class logAdmin extends StatefulWidget {
  const logAdmin({super.key});

  @override
  State<logAdmin> createState() => _logAdminState();
}

class _logAdminState extends State<logAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiLogin _apiLogin = ApiLogin(); 
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _apiLogin.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null && result['token'] != null) {
      // 1. Ensure token is a String
      String rawToken = result['token'].toString();
      
      if (result['user']['role'] == 'Admin') {
        // 2. Save the token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', rawToken); 
        
        // 3. Navigate
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        _showError("Access Denied: You are not an Admin.");
      }
    } else {
      _showError("Invalid Admin Credentials");
    }
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
                "SIGN IN", 
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
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6D3F), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
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