import 'package:flutter/material.dart';
import 'package:zionshopings/screens/main_app_shell.dart';
import 'package:zionshopings/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainAppShell()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Main Center Content
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ZION',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        letterSpacing: 4.0,
                        fontSize: 56,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SHOPPING',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.secondaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator in Gold
                    CircularProgressIndicator(
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tibeb Bottom Strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 12,
              decoration: const BoxDecoration(
                gradient: AppTheme.tibebGradient,
              ),
            ),
          ),
          
          // Decorative Top Strip (Optional, thinner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: AppTheme.tibebGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
