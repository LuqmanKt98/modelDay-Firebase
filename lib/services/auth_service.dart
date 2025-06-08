import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'token_storage_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
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
      // Listen for auth state changes
      _auth.authStateChanges().listen((User? user) async {
        _currentUser = user;
        
        if (user != null) {
          debugPrint('User signed in: ${user.email}');
          // Create user profile if it doesn't exist
          await _createUserProfileIfNeeded(user);
        } else {
          debugPrint('User signed out');
          await TokenStorageService.clearAll();
        }

        notifyListeners();
      });

      // Check for existing user
      _currentUser = _auth.currentUser;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Create user profile in Firestore if it doesn't exist
  Future<void> _createUserProfileIfNeeded(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'onboarding_tour_seen': false,
          'onboarding_completed': false,
        });
        debugPrint('User profile created for: ${user.email}');
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('Attempting to sign up with email: ${email.split('@')[0]}@...');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      _currentUser = credential.user;

      // Update display name if provided
      if (fullName != null && fullName.trim().isNotEmpty) {
        await _currentUser!.updateDisplayName(fullName.trim());
        await _currentUser!.reload();
        _currentUser = _auth.currentUser;
      }

      debugPrint('Sign up successful for user: ${_currentUser?.uid}');

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

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      _loading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      _currentUser = credential.user;

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

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final credential = await _auth.signInWithPopup(googleProvider);
        _currentUser = credential.user;
      } else {
        // Mobile implementation
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign in cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        _currentUser = userCredential.user;
      }

      debugPrint('Google sign in successful for user: ${_currentUser?.email}');

      _loading = false;
      notifyListeners();

      if (_currentUser != null) {
        navigatorKey.currentState?.pushReplacementNamed('/welcome');
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await TokenStorageService.clearAll();
      await _auth.signOut();
      
      // Also sign out from Google if needed
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }

      _currentUser = null;
      notifyListeners();

      navigatorKey.currentState?.pushReplacementNamed('/');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Check if user has seen onboarding tour
  Future<bool> hasSeenOnboardingTour() async {
    try {
      if (_currentUser == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      return userDoc.data()?['onboarding_tour_seen'] ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding tour status: $e');
      return false;
    }
  }

  /// Mark onboarding tour as seen
  Future<void> markOnboardingTourAsSeen() async {
    try {
      if (_currentUser == null) return;

      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'onboarding_tour_seen': true,
        'updatedAt': FieldValue.serverTimestamp(),
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

      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'onboarding_completed': completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Onboarding completion updated: $completed');
    } catch (e) {
      debugPrint('Error updating onboarding completion: $e');
      rethrow;
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      if (_currentUser == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      return userDoc.data()?['onboarding_completed'] ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding completion: $e');
      return false;
    }
  }

  /// Update user profile data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) return;

      final updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
        ...data,
      };

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      debugPrint('User data updated successfully');
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_currentUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      return userDoc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
}
