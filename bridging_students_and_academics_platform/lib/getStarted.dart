import 'package:bridging_students_and_academics_platform/Login.dart';
import 'package:flutter/material.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative circles – app brand green
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6D3F).withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6D3F).withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
      
            // Main card content
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Heading – app brand green
                          Text(
                            "Bridging Students & Academics",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'InriaSerif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A6D3F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subheading – muted dark green/grey
                          Text(
                            "One platform for supervision, groups, and submissions",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'InriaSerif',
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Illustration – light green tint to match app
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: size.width * 0.7,
                              height: size.width * 0.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A6D3F).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/images/coll.png",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.school_rounded,
                                  size: 64,
                                  color: const Color(0xFF4A6D3F).withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Get Started Button – app brand green (same as login/dashboard)
                          GestureDetector(
                            onTapDown: (_) {
                              setState(() => _isButtonPressed = true);
                            },
                            onTapUp: (_) {
                              setState(() => _isButtonPressed = false);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            },
                            onTapCancel: () {
                              setState(() => _isButtonPressed = false);
                            },
                            child: AnimatedScale(
                              scale: _isButtonPressed ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A6D3F),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Get Started",
                                    style: TextStyle(
                                      fontFamily: 'InriaSerif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
}
