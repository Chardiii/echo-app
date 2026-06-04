/// Echo — Auth Service
///
/// Firebase Auth wrapper for login, register, logout, and current user.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Whether the user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current user's Firebase ID token for API calls
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Register with email and password
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
      });
    }

    return user;
  }

  /// Login with email and password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
