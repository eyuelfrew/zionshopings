import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
              // Elegant makeup products on velvet background
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
                    // Soft pink velvet-like background
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFECE4), // Soft pink
                            Color(0xFFFFF5F0), // Lighter pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Makeup products arranged artistically
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            // Lipstick collection
                            Positioned(
                              top: 20,
                              left: 30,
                              child: Container(
                                width: 45,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE91E63), // Pink
                                      Color(0xFFAD1457), // Darker pink
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE91E63).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.linear_scale,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 90,
                              child: Container(
                                width: 45,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF5722), // Orange-red
                                      Color(0xFFE64A19), // Darker orange-red
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5722).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.linear_scale,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 30,
                              child: Container(
                                width: 45,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF795548), // Brown
                                      Color(0xFF5D4037), // Darker brown
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF795548).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.linear_scale,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            // Makeup palette
                            Positioned(
                              bottom: 40,
                              left: 50,
                              child: Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFF5F5F5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Palette colors
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFCDD2),
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFE0B2),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFC8E6C9),
                                                borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFBBDEFB),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE1BEE7),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E0),
                                                borderRadius: const BorderRadius.only(
                                                  bottomRight: Radius.circular(12),
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Mascara
                            Positioned(
                              bottom: 40,
                              right: 60,
                              child: Container(
                                width: 30,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF37474F), // Dark gray
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF37474F).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.linear_scale,
                                  color: Colors.white,
                                  size: 16,
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
                'Perfect Your Look',
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
                'Create stunning looks with our premium makeup collection. From natural to bold, express your unique style.',
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