import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
                          color: const Color(0xFFFFF7F3),
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
                            Icons.brush,
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
                      icon: Icons.palette,
                      color: const Color(0xFFFF1493),
                    ),
                    _buildFloatingElement(
                      bottom: 60,
                      right: 10,
                      icon: Icons.auto_fix_high,
                      color: const Color(0xFFDA121A),
                    ),
                    _buildFloatingElement(
                      top: 80,
                      right: 20,
                      icon: Icons.flare,
                      color: const Color(0xFFFF69B4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // English Title
              Text(
                'PERFECT YOUR LOOK',
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
                'Create stunning looks with our premium makeup collection. From natural to bold, express your unique style.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
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