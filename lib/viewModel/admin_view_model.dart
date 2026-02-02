import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for Admin Panel screen: master deleting state.
class AdminViewModel extends ChangeNotifier {
  AdminViewModel();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _masterDeletingState = false;
  bool get masterDeletingState => _masterDeletingState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadMasterDeletingState() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      _masterDeletingState = data?['isMasterDeletingActive'] as bool? ?? false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeMasterDeletingStatus(bool status) async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isMasterDeletingActive': status,
      });
      _masterDeletingState = status;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
