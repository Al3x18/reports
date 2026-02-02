import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// ViewModel for Add New Report. Handles form state, image picker, upload and submit.
class AddReportViewModel extends ChangeNotifier {
  AddReportViewModel();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _nameOfUser = '';
  String get nameOfUser => _nameOfUser;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  String get currentDate =>
      DateFormat.yMMMd().add_Hm().format(DateTime.now());

  Future<void> loadCurrentUserName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _nameOfUser = data['name'] as String? ?? '';
      notifyListeners();
    }
  }

  Future<void> selectPhotoFromLibrary() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners();
    }
  }

  Future<void> takePhotoWithCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<String> _uploadImage(File imageFile) async {
    final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('reports/images/$imageName');
    final snapshot = await ref.putFile(imageFile).whenComplete(() => null);
    return snapshot.ref.getDownloadURL();
  }

  Future<String?> submitReport({
    required String title,
    required String place,
    required String reportDescription,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'User not authenticated';

    _isLoading = true;
    notifyListeners();
    try {
      String imageUrl = '';
      final image = _selectedImage;
      if (image != null) {
        imageUrl = await _uploadImage(image);
      }

      final newReport = <String, dynamic>{
        'title': title,
        'author': _nameOfUser,
        'place': place,
        'description': reportDescription,
        'dateOfSubmission': currentDate,
        'imageUrl': imageUrl,
        'userUID': user.uid,
      };

      await _firestore.collection('users').doc(user.uid).update({
        'reportsList': FieldValue.arrayUnion([newReport]),
      });
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
}
