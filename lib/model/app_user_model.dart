/// Domain model for app user profile (from Firestore users collection).
class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.isAdmin,
    required this.isBlocked,
    required this.isMasterDeletingActive,
    required this.reportsList,
  });

  final String uid;
  final String email;
  final String name;
  final bool isAdmin;
  final bool isBlocked;
  final bool isMasterDeletingActive;
  final List<Map<String, dynamic>> reportsList;

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isAdmin: map['isAdmin'] as bool? ?? false,
      isBlocked: map['isBlocked'] as bool? ?? false,
      isMasterDeletingActive: map['isMasterDeletingActive'] as bool? ?? false,
      reportsList: List<Map<String, dynamic>>.from(
        map['reportsList'] as List<dynamic>? ?? [],
      ),
    );
  }
}
