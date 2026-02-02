import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:reports/viewModel/auth_view_model.dart';

/// ViewModel for Create Account screen. Handles validation and user creation in Firestore.
class CreateAccountViewModel extends ChangeNotifier {
  CreateAccountViewModel({required AuthViewModel authViewModel}) {
    _authViewModel = authViewModel;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final AuthViewModel _authViewModel;

  bool get isAuthenticating => _authViewModel.isLoading;

  /// Creates account and initial user document. Returns success or error message.
  Future<AuthResult> createAccount({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return AuthResult.failure(
        'The passwords entered do not match, try again.',
      );
    }

    final result = await _authViewModel
        .createUserWithEmailAndPassword(email: email, password: password);

    if (!result.success) return result;

    final user = _auth.currentUser;
    if (user == null) return AuthResult.failure('User not created');

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': name,
      'isAdmin': false,
      'isMasterDeletingActive': false,
      'isBlocked': false,
      'reportsList': [],
    });

    return const AuthResult.success();
  }
}
