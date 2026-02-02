import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Result of auth operations for the UI (success or error message).
class AuthResult {
  const AuthResult({this.success = false, this.errorMessage});

  final bool success;
  final String? errorMessage;

  const AuthResult.success() : this(success: true);
  AuthResult.failure(String message) : this(success: false, errorMessage: message);
}

/// ViewModel for authentication: login, signup, logout, reset password.
/// Auth state is consumed via Firebase authStateChanges() in the app root.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult.failure(e.message ?? 'Authentication failed');
    }
  }

  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult.failure(e.message ?? 'Registration failed');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') {
        return AuthResult.failure('This user does not exist');
      }
      return AuthResult.failure(e.message ?? 'Failed to send reset email');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
