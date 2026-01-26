import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_controller.dart';
import 'main_app_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Decorations (Matching Onboarding flair)
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF1493).withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF1493).withOpacity(0.1),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Decorative Floating Icons
                        _buildFloatingElement(
                          icon: Icons.auto_awesome,
                          color: const Color(0xFFFF1493),
                          size: 28,
                        ),
                        const SizedBox(height: 24),
                        
                        // Branding
                        Text(
                          'ZION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.philosopher(
                            color: const Color(0xFFFF1493),
                            letterSpacing: 8.0,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'SHOPPING',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.philosopher(
                            color: const Color(0xFF2D2D2D),
                            letterSpacing: 4.0,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 60),

                        // Subtitle
                        Text(
                          'Welcome to a world of luxury and beauty',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 100),

                        // Google Sign-In Button
                        Consumer<AuthController>(
                          builder: (context, controller, child) {
                            if (controller.state.isSigningIn) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF1493),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await context.read<AuthController>().signInWithGoogle();
                                    
                                    // Clear guest mode after successful sign in
                                    if (controller.state.user != null) {
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('guest_mode', false);
                                    }
                                  },
                                  icon: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 24.0,
                                  ),
                                  label: Text(
                                    'Continue with Google',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2D2D2D),
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Continue as Guest Button
                                TextButton(
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('guest_mode', true);
                                    
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MainAppShell()),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Continue as Guest',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFFFF1493),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElement({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}
