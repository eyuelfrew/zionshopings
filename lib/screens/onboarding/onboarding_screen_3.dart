import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF5F5), // Light pink
            const Color(0xFFFFFFFF), // White
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Confident woman with mirror and products
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100,
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Soft gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF8F7), // Very light pink
                            Color(0xFFFFF0F5), // Soft pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Mirror with reflection effect
                    Positioned(
                      top: 30,
                      left: 50,
                      right: 50,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD7CCC8), // Light brown
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.face,
                          size: 120,
                          color: Color(0xFFFFB7C9), // Soft pink face icon
                        ),
                      ),
                    ),
                    // Floating cosmetic products around the mirror
                    Positioned(
                      top: 60,
                      left: 10,
                      child: Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE), // Light red
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFEBEE).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.linear_scale,
                          color: Color(0xFFC2185B), // Pink
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      right: 10,
                      child: Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9), // Light green
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8F5E9).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pin,
                          color: Color(0xFF388E3C), // Green
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Light blue
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE3F2FD).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.opacity,
                          color: Color(0xFF1976D2), // Blue
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      right: 20,
                      child: Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5), // Light purple
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF3E5F5).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_drink,
                          color: Color(0xFF7B1FA2), // Purple
                          size: 20,
                        ),
                      ),
                    ),
                    // Soft glow effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.3),
                            radius: 1.5,
                            colors: [
                              Colors.transparent,
                              const Color(0x22FFCDD2).withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Confidence is Key',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF880E4F), // Dark pink
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 20),
              // Body text
              Text(
                'Feel empowered and radiant with our beauty essentials. Your confidence is our inspiration.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5D4037), // Brownish text
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}