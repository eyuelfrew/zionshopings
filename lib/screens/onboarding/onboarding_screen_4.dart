import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth_wrapper.dart';

class OnboardingScreen4 extends StatefulWidget {
  const OnboardingScreen4({super.key});

  @override
  _OnboardingScreen4State createState() => _OnboardingScreen4State();
}

class _OnboardingScreen4State extends State<OnboardingScreen4> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visual Illustration Area - Slightly smaller to fit
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Glow
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFF1493).withOpacity(0.2),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Large Decorative Circle
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF1493).withOpacity(0.05),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner Design Elements
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F8E9),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1493).withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 100,
                            color: const Color(0xFFFF1493).withAlpha(180),
                          ),
                        ),
                      ),
                    ),
                    // Floating Elements
                    _buildFloatingElement(
                      top: 40,
                      left: 15,
                      icon: Icons.check_circle,
                      color: const Color(0xFFFF1493),
                    ),
                    _buildFloatingElement(
                      bottom: 60,
                      right: 10,
                      icon: Icons.local_shipping,
                      color: const Color(0xFFDA121A),
                    ),
                    _buildFloatingElement(
                      top: 80,
                      right: 20,
                      icon: Icons.star_border_purple500,
                      color: const Color(0xFFFF69B4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // English Title
              Text(
                'START YOUR JOURNEY',
                textAlign: TextAlign.center,
                style: GoogleFonts.philosopher(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 1.2,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              // English Description
              Text(
                'Begin your beauty transformation with premium products curated just for you. Your perfect look awaits.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_completed_onboarding', true);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      );
                    },
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                    ),
                    label: Text(
                      'SIGN IN WITH GOOGLE',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D2D2D),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_completed_onboarding', true);
                      await prefs.setBool('guest_mode', true);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      );
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      foregroundColor: const Color(0xFFFF1493),
                    ),
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElement({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }
}