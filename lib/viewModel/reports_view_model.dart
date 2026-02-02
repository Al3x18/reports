import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:reports/model/app_user_model.dart';

/// ViewModel for the main Reports screen: user profile, users stream, connectivity, selected tab.
class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel() {
    _initConnectivity();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String _nameOfUser = '';
  String get nameOfUser => _nameOfUser;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  bool _isUserAdmin = false;
  bool get isUserAdmin => _isUserAdmin;

  bool _isUserBlocked = false;
  bool get isUserBlocked => _isUserBlocked;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  String? get currentUserUid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> get usersStream =>
      _firestore.collection('users').snapshots();

  void _initConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final connected = result.any((r) => r != ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }

  Future<void> loadCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      final user = AppUserModel.fromMap(data);
      _nameOfUser = user.name;
      _isUserAdmin = user.isAdmin;
      _isUserBlocked = user.isBlocked;
      notifyListeners();
    }
  }

  void checkConnectivity() {
    _connectivity.checkConnectivity().then((result) {
      final connected = result.any((r) => r != ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }

  void logout() {
    _auth.signOut();
    notifyListeners();
  }

  void cancelConnectivitySubscription() {
    _connectivitySubscription?.cancel();
  }
}
