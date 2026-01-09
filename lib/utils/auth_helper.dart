import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/auth/auth_controller.dart';
import 'package:zionshopings/widgets/sign_in_bottom_sheet.dart';

class AuthHelper {
  /// Check if user is authenticated, if not show sign-in bottom sheet
  /// Returns true if user is authenticated or signs in, false otherwise
  static Future<bool> requireAuth(
    BuildContext context, {
    String? message,
  }) async {
    final authController = context.read<AuthController>();
    
    // Check if user is already authenticated
    if (authController.state.user != null) {
      return true;
    }

    // Show sign-in bottom sheet
    final result = await SignInBottomSheet.show(
      context,
      message: message,
    );

    return result ?? false;
  }

  /// Check if user is authenticated without showing any UI
  static bool isAuthenticated(BuildContext context) {
    final authController = context.read<AuthController>();
    return authController.state.user != null;
  }
}
