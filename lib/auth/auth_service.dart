import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';

import 'backend_auth_service.dart';
import 'auth_state.dart';

/// -------------------------------
/// Google + Firebase + Backend Auth Service
/// -------------------------------
class GoogleAuthService {
  final BackendAuthService _backendAuthService = BackendAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Sign in with Google and authenticate with Firebase and Backend
  Future<AuthState> signInWithGoogle() async {
    try {
      log('Starting Google Sign-In with Backend Integration');

      // Use the new backend service for authentication
      return await _backendAuthService.signInWithGoogle();
    } catch (e, s) {
      log('Google sign-in with backend failed', error: e, stackTrace: s);
      return AuthState(
        user: null,
        isLoading: false,
        isSigningIn: false,
        error: e.toString(),
      );
    }
  }

  /// Silent sign-in (check backend session)
  Future<User?> getCurrentUser() async {
    bool isValid = await _backendAuthService.validateSession();
    if (isValid) {
      return _firebaseAuth.currentUser;
    }
    return null;
  }

  /// Sign out from Firebase, Google, and Backend
  Future<void> signOut() async {
    await _backendAuthService.signOut();
  }

  /// Get current user profile from backend
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    return await _backendAuthService.getCurrentUserProfile();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _backendAuthService.validateSession();
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final tokens = await _backendAuthService.getTokens();
    return tokens['accessToken'];
  }

  /// Refresh access token
  Future<String?> refreshAccessToken() async {
    bool success = await _backendAuthService.refreshAccessToken();
    if (success) {
      final tokens = await _backendAuthService.getTokens();
      return tokens['accessToken'];
    }
    return null;
  }
}
