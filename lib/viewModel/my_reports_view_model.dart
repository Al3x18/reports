import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for My Reports screen. Exposes stream of current user's reports and delete action.
class MyReportsViewModel extends ChangeNotifier {
  MyReportsViewModel();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserUid => _auth.currentUser?.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>> get currentUserReportsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> deleteReport(Map<String, dynamic> report) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'reportsList': FieldValue.arrayRemove([report]),
    });
    notifyListeners();
  }
}
