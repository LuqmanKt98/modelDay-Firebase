import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'token_storage_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _loading = false;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get loading => _loading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _init();
  }

  void _init() async {
    try {
      // Check for existing session first
      await _checkStoredSession();

      // Then listen for auth state changes
      _supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        _currentUser = session?.user;

        // Save tokens when user signs in
        if (session != null && _currentUser != null) {
          await _saveSessionTokens(session);
        }

        // Clear tokens when user signs out
        if (session == null && _currentUser == null) {
          await TokenStorageService.clearAll();
        }

        notifyListeners();

        // Handle navigation based on auth state
        if (_currentUser != null && _isInitialized) {
          navigatorKey.currentState?.pushReplacementNamed('/welcome');
        } else if (_currentUser == null && _isInitialized) {
          navigatorKey.currentState?.pushReplacementNamed('/');
        }
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Check for stored session and attempt auto-login
  Future<void> _checkStoredSession() async {
    try {
      // First check if we have a valid stored session
      final hasValidSession = await TokenStorageService.hasValidSession();

      if (hasValidSession) {
        // Try to get the current session from Supabase
        final session = _supabase.auth.currentSession;

        if (session != null) {
          _currentUser = session.user;
          debugPrint('Restored session for user: ${_currentUser?.email}');
          return;
        }

        // If no active session but we have stored tokens, try to refresh
        final refreshToken = await TokenStorageService.getRefreshToken();
        if (refreshToken != null) {
          await _refreshSession(refreshToken);
        }
      } else {
        // Clear invalid/expired tokens
        await TokenStorageService.clearAll();
      }
    } catch (e) {
      debugPrint('Error checking stored session: $e');
      await TokenStorageService.clearAll();
    }
  }

  /// Save session tokens securely
  Future<void> _saveSessionTokens(Session session) async {
    try {
      final userData = {
        'id': session.user.id,
        'email': session.user.email,
        'user_metadata': session.user.userMetadata,
        'app_metadata': session.user.appMetadata,
        'created_at': session.user.createdAt,
      };

      await TokenStorageService.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userData: userData,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
      );

      debugPrint('Session tokens saved successfully');
    } catch (e) {
      debugPrint('Error saving session tokens: $e');
    }
  }

  /// Refresh session using stored refresh token
  Future<bool> _refreshSession(String refreshToken) async {
    try {
      final response = await _supabase.auth.refreshSession(refreshToken);

      if (response.session != null) {
        _currentUser = response.session!.user;
        await _saveSessionTokens(response.session!);
        debugPrint('Session refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      await TokenStorageService.clearAll();
      return false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('Attempting to sign up with email: ${email.split('@')[0]}@...');

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: fullName != null ? {'full_name': fullName.trim()} : null,
      );

      if (response.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      _currentUser = response.user;

      // Save session tokens if available
      if (response.session != null) {
        await _saveSessionTokens(response.session!);
      }

      debugPrint('Sign up successful for user: ${_currentUser?.id}');

      _loading = false;
      notifyListeners();

      if (_currentUser != null) {
        navigatorKey.currentState?.pushReplacementNamed('/welcome');
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      _currentUser = response.user;

      // Save session tokens
      if (response.session != null) {
        await _saveSessionTokens(response.session!);
      }

      debugPrint('Sign in successful for user: ${_currentUser?.email}');

      _loading = false;
      notifyListeners();

      if (_currentUser != null) {
        navigatorKey.currentState?.pushReplacementNamed('/welcome');
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      // For web, use OAuth popup
      if (kIsWeb) {
        // Get the current URL origin, but handle both localhost and production
        final origin = Uri.base.origin;
        final redirectTo = origin.contains('localhost')
            ? origin
            : 'https://nvawwmygojhhvimvjiif.supabase.co/auth/v1/callback';

        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectTo,
          queryParams: {'access_type': 'offline', 'prompt': 'consent'},
        );
      } else {
        // For mobile, use Google Sign In package
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google sign in cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null) {
          throw Exception('No Access Token found.');
        }
        if (idToken == null) {
          throw Exception('No ID Token found.');
        }

        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Clear stored tokens first
      await TokenStorageService.clearAll();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      _currentUser = null;
      notifyListeners();

      debugPrint('User signed out successfully');

      // Navigate to landing page on sign out
      navigatorKey.currentState?.pushReplacementNamed('/');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Manual token refresh
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      return await _refreshSession(refreshToken);
    } catch (e) {
      debugPrint('Manual token refresh error: $e');
      return false;
    }
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    try {
      if (_currentUser == null) return false;

      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      // Check if token is expired
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      if (DateTime.now().isAfter(expiresAt)) {
        // Try to refresh
        return await refreshToken();
      }

      return true;
    } catch (e) {
      debugPrint('Session validation error: $e');
      return false;
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        return session.accessToken;
      }

      // Fallback to stored token
      return await TokenStorageService.getAccessToken();
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  /// Force logout and clear all data
  Future<void> forceLogout() async {
    try {
      await TokenStorageService.clearAll();
      _currentUser = null;
      notifyListeners();
      navigatorKey.currentState?.pushReplacementNamed('/');
    } catch (e) {
      debugPrint('Force logout error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _loading = true;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Check if the user has seen the onboarding tour
  Future<bool> hasSeenOnboardingTour() async {
    try {
      if (_currentUser == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('onboarding_tour_seen')
          .eq('id', _currentUser!.id)
          .maybeSingle();

      // If no profile exists yet, user hasn't seen the tour
      if (response == null) return false;

      return response['onboarding_tour_seen'] ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding tour status: $e');
      // If there's an error (like profile doesn't exist), assume they haven't seen it
      return false;
    }
  }

  /// Mark the onboarding tour as seen
  Future<void> markOnboardingTourAsSeen() async {
    try {
      if (_currentUser == null) return;

      await _supabase
          .from('profiles')
          .upsert({
            'id': _currentUser!.id,
            'onboarding_tour_seen': true,
            'updated_at': DateTime.now().toIso8601String(),
          });

      debugPrint('Onboarding tour marked as seen');
    } catch (e) {
      debugPrint('Error marking onboarding tour as seen: $e');
      rethrow;
    }
  }

  /// Update onboarding completion status
  Future<void> updateOnboardingCompleted(bool completed) async {
    try {
      if (_currentUser == null) return;

      await _supabase
          .from('profiles')
          .upsert({
            'id': _currentUser!.id,
            'onboarding_completed': completed,
            'updated_at': DateTime.now().toIso8601String(),
          });

      debugPrint('Onboarding completion status updated: $completed');
    } catch (e) {
      debugPrint('Error updating onboarding completion: $e');
      rethrow;
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      if (_currentUser == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', _currentUser!.id)
          .maybeSingle();

      // If no profile exists yet, onboarding is not completed
      if (response == null) return false;

      return response['onboarding_completed'] ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding completion: $e');
      // If there's an error (like profile doesn't exist), assume onboarding is not completed
      return false;
    }
  }

  /// Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) return;

      final updateData = {
        'id': _currentUser!.id,
        'updated_at': DateTime.now().toIso8601String(),
        ...data,
      };

      await _supabase
          .from('profiles')
          .upsert(updateData);

      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}
