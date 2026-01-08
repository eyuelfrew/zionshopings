import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_controller.dart';
import '../theme/app_theme.dart';

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
                  return ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthController>().signInWithGoogle();
                    },
                    icon: Image.asset('assets/images/google_logo.png', height: 24.0), // Make sure you have this asset
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppTheme.textColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
