import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

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
              // Beautiful woman applying face cream with soft glow effect
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
                    // Background with soft gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFEAE6), // Very light pink
                            Color(0xFFFFF8F7), // Even lighter pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Simulated image area with beauty products
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            // Simulated woman's face area
                            Positioned(
                              top: 10,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.face,
                                  size: 80,
                                  color: Color(0xFFFFB7C9), // Soft pink face icon
                                ),
                              ),
                            ),
                            // Simulated skincare products
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9), // Light green for skincare
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFA5D6A7),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.opacity,
                                  color: Color(0xFF4CAF50),
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E5F5), // Light purple for serum
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCE93D8),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_drink,
                                  color: Color(0xFF7B1FA2),
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 80,
                              child: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD), // Light blue for moisturizer
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF90CAF9),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.pin,
                                  color: Color(0xFF1976D2),
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
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
                'Discover Your Glow',
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
                'Experience luxury skincare tailored just for you. Unveil your natural radiance with our premium collection.',
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