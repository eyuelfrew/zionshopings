import 'dart:convert';
import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_state.dart';

class BackendAuthService {
  // Replace with your actual backend URL
  static const String _backendUrl = 'http://localhost:5000/api/auth';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for storing tokens in secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Sign in with Google and authenticate with the custom backend
  Future<AuthState> signInWithGoogle() async {
    try {
      log('Starting Google Sign-In with backend integration');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      log('Google Sign-In account obtained');
      log('Google User: ${googleUser?.email}');
      log('Google User ID: ${googleUser?.id}');
      if (googleUser == null) {
        log('User cancelled Google Sign-In');
        return AuthState(user: null, isLoading: false, isSigningIn: false);
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Get Firebase ID token to send to backend
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase to get user details
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase authentication failed');
      }

      // Get fresh Firebase ID token to send to backend
      final String? idToken = await firebaseUser.getIdToken(true); // Force refresh
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Send Firebase ID token to backend for verification and token issuance
      final response = await http.post(
        Uri.parse('$_backendUrl/firebase/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken, // Send Firebase ID token to backend
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store tokens in secure storage
        await _storeTokens(
          data['data']['accessToken'],
          data['data']['refreshToken'],
          data['data']['user']
        );

        // Update last login
        await _updateLastLogin(firebaseUser.uid);

        // Return success state with user info
        return AuthState(
          user: firebaseUser,
          isLoading: false,
          isSigningIn: false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Authentication failed');
      }
    } catch (e, s) {
      log('Backend auth failed', error: e, stackTrace: s);
      return AuthState(
        user: null,
        isLoading: false,
        isSigningIn: false,
        error: e.toString(),
      );
    }
  }

  /// Validate current session with the backend
  Future<bool> validateSession() async {
    final tokens = await _getTokens();
    if (tokens['accessToken'] == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/firebase/me'),
        headers: {
          'Authorization': 'Bearer ${tokens['accessToken']}',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Access token expired, try to refresh
        return await refreshAccessToken();
      } else if (response.statusCode == 403) {
        // Account blocked - user needs to sign in again
        await _clearTokens();
        return false;
      }
      return false;
    } catch (e) {
      log('Session validation failed', error: e);
      return false;
    }
  }

  /// Refresh the access token using the refresh token
  Future<bool> refreshAccessToken() async {
    final tokens = await _getTokens();
    if (tokens['refreshToken'] == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/firebase/refresh'),
        headers: {
          'Authorization': 'Bearer ${tokens['refreshToken']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': tokens['refreshToken'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = await _getStoredUser(); // Preserve user data
        await _storeTokens(data['data']['accessToken'], tokens['refreshToken']!, userData);
        return true;
      } else if (response.statusCode == 401) {
        // Refresh token invalid or expired - user must sign in again
        await _clearTokens();
        return false;
      }
      return false;
    } catch (e) {
      log('Token refresh failed', error: e);
      return false;
    }
  }

  /// Get current user profile from backend
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final tokens = await _getTokens();
    if (tokens['accessToken'] == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/firebase/me'),
        headers: {
          'Authorization': 'Bearer ${tokens['accessToken']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update stored user data
        await _storage.write(key: _userDataKey, value: jsonEncode(data['data']['user']));
        return data['data']['user'];
      } else if (response.statusCode == 401) {
        // Try to refresh and retry
        if (await refreshAccessToken()) {
          final retryResponse = await http.get(
            Uri.parse('$_backendUrl/firebase/me'),
            headers: {
              'Authorization': 'Bearer ${(await _getTokens())['accessToken']}',
            },
          );
          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            // Update stored user data
            await _storage.write(key: _userDataKey, value: jsonEncode(data['data']['user']));
            return data['data']['user'];
          }
        }
      } else if (response.statusCode == 403) {
        // Account blocked
        await _clearTokens();
      }
      return null;
    } catch (e) {
      log('Failed to get user profile', error: e);
      return null;
    }
  }

  /// Sign out from the backend and clear local tokens
  Future<void> signOut() async {
    try {
      final tokens = await _getTokens();
      if (tokens['accessToken'] != null) {
        // Revoke all tokens on backend using access token
        await http.post(
          Uri.parse('$_backendUrl/firebase/logout'),
          headers: {
            'Authorization': 'Bearer ${tokens['accessToken']}',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      log('Backend logout failed, continuing with local cleanup', error: e);
    } finally {
      // Clear local tokens regardless of backend logout success
      await _clearTokens();
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    }
  }

  /// Store access and refresh tokens securely
  Future<void> _storeTokens(String accessToken, String refreshToken, Map<String, dynamic>? userData) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);

    // Store refresh token hash for additional security
    final refreshTokenHash = sha256.convert(utf8.encode(refreshToken)).toString();
    await _storage.write(key: _refreshTokenKey, value: refreshTokenHash);

    // Store user data
    if (userData != null) {
      await _storage.write(key: _userDataKey, value: jsonEncode(userData));
    }
  }

  /// Get stored tokens (private method for internal use)
  Future<Map<String, String?>> _getTokens() async {
    return {
      'accessToken': await _storage.read(key: _accessTokenKey),
      'refreshToken': await _storage.read(key: _refreshTokenKey),
    };
  }

  /// Get stored tokens (public method for external access)
  Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': await _storage.read(key: _accessTokenKey),
      'refreshToken': await _storage.read(key: _refreshTokenKey),
    };
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> _getStoredUser() async {
    final userDataString = await _storage.read(key: _userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String firebaseUid) async {
    // This would typically be done server-side, but we can track locally too
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_login_firebase_uid', firebaseUid);
    await prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// Silent sign-in (check if we have valid tokens)
  User? get currentUser {
    // Check if we have valid tokens
    // In a real implementation, you'd validate the token with the backend
    // For now, we'll return the Firebase user if we have tokens
    return _firebaseAuth.currentUser;
  }
}