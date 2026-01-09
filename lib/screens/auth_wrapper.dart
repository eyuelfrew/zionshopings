import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_controller.dart';
import 'login_screen.dart';
import 'main_app_shell.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingGuestMode = true;
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final guestMode = prefs.getBool('guest_mode') ?? false;
    
    setState(() {
      _isGuestMode = guestMode;
      _isCheckingGuestMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingGuestMode) {
      return const SplashScreen();
    }

    return Consumer<AuthController>(
      builder: (context, controller, child) {
        if (controller.state.isLoading) {
          return const SplashScreen();
        }
        
        // If user is authenticated, show main app
        if (controller.state.user != null) {
          return const MainAppShell();
        }
        
        // If in guest mode, show main app without authentication
        if (_isGuestMode) {
          return const MainAppShell();
        }
        
        // Otherwise show login screen
        return const LoginScreen();
      },
    );
  }
}