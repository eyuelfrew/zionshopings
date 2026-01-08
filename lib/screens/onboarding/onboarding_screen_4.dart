import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              // Joyful woman with shopping bags and beauty products
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
                    // Warm pink gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF0F5), // Soft pink
                            Color(0xFFFFF8F7), // Light pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Woman's joyful face
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xFFFFF0F0).withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_emotions,
                          size: 100,
                          color: Color(0xFFFFB7C9), // Soft pink face icon
                        ),
                      ),
                    ),
                    // Shopping bags
                    Positioned(
                      bottom: 30,
                      left: 40,
                      child: Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2), // Light orange
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE0B2).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Color(0xFFE65100), // Orange
                          size: 30,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 40,
                      child: Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9), // Light green
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC8E6C9).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Color(0xFF2E7D32), // Green
                          size: 30,
                        ),
                      ),
                    ),
                    // Beauty products floating around
                    Positioned(
                      top: 80,
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
                      top: 80,
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
                'Start Your Journey',
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
                'Begin your beauty transformation with premium products curated just for you. Your perfect look awaits.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5D4037), // Brownish text
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 40),
              // Continue button
              ElevatedButton(
                onPressed: () async {
                  // Mark onboarding as completed
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('has_completed_onboarding', true);

                  // Navigate back to the auth wrapper which will show login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF880E4F), // Dark pink
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}