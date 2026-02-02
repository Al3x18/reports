import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for Manage User screen. Handles block, admin, master deleting, delete user.
class ManageUserViewModel extends ChangeNotifier {
  ManageUserViewModel({required Map<String, dynamic> userDetails}) {
    _userDetails = userDetails;
    _isAdmin = userDetails['isAdmin'] as bool? ?? false;
    _isBlocked = userDetails['isBlocked'] as bool? ?? false;
  }

  late final Map<String, dynamic> _userDetails;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late bool _isAdmin;
  bool get isAdmin => _isAdmin;

  late bool _isBlocked;
  bool get isBlocked => _isBlocked;

  Map<String, dynamic> get userDetails => Map.unmodifiable(_userDetails);

  String get userUid => _userDetails['uid'] as String? ?? '';

  bool get isCurrentUser => _auth.currentUser?.uid == userUid;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> updateBlocked(bool status) async {
    _errorMessage = null;
    try {
      await _firestore.collection('users').doc(userUid).update({
        'isBlocked': status,
      });
      _isBlocked = status;
      _userDetails['isBlocked'] = status;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAdmin(bool status) async {
    _errorMessage = null;
    try {
      await _firestore.collection('users').doc(userUid).update({
        'isAdmin': status,
      });
      _isAdmin = status;
      _userDetails['isAdmin'] = status;
      if (!status) {
        await forceMasterDeletingToFalse();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> forceMasterDeletingToFalse() async {
    _errorMessage = null;
    try {
      await _firestore.collection('users').doc(userUid).update({
        'isMasterDeletingActive': false,
      });
      _userDetails['isMasterDeletingActive'] = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deleteUser() async {
    if (isCurrentUser) return false;
    _errorMessage = null;
    try {
      await _firestore.collection('users').doc(userUid).delete();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
