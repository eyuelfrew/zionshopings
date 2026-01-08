import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zionshopings/screens/splash_screen.dart';
import 'package:zionshopings/services/cart_controller.dart';
import 'package:zionshopings/services/theme_controller.dart';
import 'package:zionshopings/services/wishlist_controller.dart';
import 'package:zionshopings/services/address_controller.dart';
import 'auth/auth_controller.dart';
import 'screens/auth_wrapper.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AddressController()), 
      ],
      builder: (context, child) {
        final themeController = context.watch<ThemeController>();
        return MaterialApp(
          title: 'Zion Shopings',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const OnboardingOrAuthWrapper(),
        );
      },
    );
  }
}

class OnboardingOrAuthWrapper extends StatefulWidget {
  const OnboardingOrAuthWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingOrAuthWrapperState createState() => _OnboardingOrAuthWrapperState();
}

class _OnboardingOrAuthWrapperState extends State<OnboardingOrAuthWrapper> {
  bool _isCheckingOnboarding = true;  
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

    setState(() {
      _isCheckingOnboarding = false;
      _hasCompletedOnboarding = hasCompletedOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding) {
      return const SplashScreen();
    }

    // If user hasn't completed onboarding, show onboarding flow
    if (!_hasCompletedOnboarding) {
      return const OnboardingFlowScreen();
    }

    // Otherwise, show the auth wrapper as before
    return const AuthWrapper();
  }
}
