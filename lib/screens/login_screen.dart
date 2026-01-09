import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_controller.dart';
import '../theme/app_theme.dart';
import 'main_app_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Text(
                'ZION',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      letterSpacing: 4.0,
                      fontSize: 56,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'SHOPPING',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.secondaryColor,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 60),

              // Subtitle
              Text(
                'Welcome to a world of luxury and beauty.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 120),

              // Google Sign-In Button
              Consumer<AuthController>(
                builder: (context, controller, child) {
                  if (controller.state.isSigningIn) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.login, size: 24),
                        ),
                        label: const Text('Continue with Google'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppTheme.textColor,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
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
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Facebook Sign In (Commented for future use)
              // const SizedBox(height: 16),
              // OutlinedButton.icon(
              //   onPressed: () {
              //     //  Implement Facebook sign in
              //   },
              //   icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
              //   label: const Text('Continue with Facebook'),
              //   style: OutlinedButton.styleFrom(
              //     foregroundColor: const Color(0xFF1877F2),
              //     side: const BorderSide(color: Color(0xFF1877F2)),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
