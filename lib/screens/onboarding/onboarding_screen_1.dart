import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Premium Image Area - With decorations
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Glow
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFF1493).withOpacity(0.15),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Image Container
                    Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/onboarding/onboarding_makeup.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Decorative Floating Icons
                    _buildFloatingElement(
                      top: 10,
                      right: 10,
                      icon: Icons.auto_awesome,
                      color: const Color(0xFFFF1493),
                    ),
                    _buildFloatingElement(
                      bottom: 30,
                      left: 10,
                      icon: Icons.favorite,
                      color: const Color(0xFFFF69B4),
                    ),
                    _buildFloatingElement(
                      top: 80,
                      left: 0,
                      icon: Icons.star,
                      color: const Color(0xFFFFD700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Creative Artistic Text Area
              Stack(
                alignment: Alignment.center,
                children: [
                  // Layered Abstract Shapes for Depth
                  Positioned(
                    top: 0,
                    right: 40,
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF1493).withOpacity(0.08),
                            const Color(0xFFFF1493).withOpacity(0.01),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF1493).withOpacity(0.04),
                      ),
                    ),
                  ),
                  // Central Soft Glow
                  Container(
                    width: 320,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF1493).withOpacity(0.12),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // Text Content
                  Column(
                    children: [
                      // English Title - Philosopher Font
                      Text(
                        'Welcome to Zion Shopings',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.philosopher(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          letterSpacing: 0.8,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Amharic Subtext - Noto Sans Ethiopic
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1493).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'እንኳን ደህና መጡ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            letterSpacing: 1.0,
                            color: const Color(0xFFFF1493),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Micro Decorations near Text
                  Positioned(
                    top: -10,
                    left: 40,
                    child: Icon(Icons.auto_awesome, size: 16, color: const Color(0xFFFF1493).withOpacity(0.4)),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 30,
                    child: Icon(Icons.stars, size: 14, color: const Color(0xFFFFD700).withOpacity(0.6)),
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
        padding: const EdgeInsets.all(10),
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
          size: 20,
          color: color,
        ),
      ),
    );
  }
}