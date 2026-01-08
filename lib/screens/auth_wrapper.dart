import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_controller.dart';
import 'login_screen.dart';
import 'main_app_shell.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, child) {
        if (controller.state.isLoading) {
          return const SplashScreen();
        }
        if (controller.state.user != null) {
          return const MainAppShell();
        }
        return const LoginScreen();
      },
    );
  }
}