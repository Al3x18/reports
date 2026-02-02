/// Domain model for a single report (maps from Firestore reportsList item).
class ReportModel {
  const ReportModel({
    required this.title,
    required this.author,
    required this.place,
    required this.description,
    required this.dateOfSubmission,
    required this.userUID,
    this.imageUrl = '',
  });

  final String title;
  final String author;
  final String place;
  final String description;
  final String dateOfSubmission;
  final String userUID;
  final String imageUrl;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      title: map['title'] as String? ?? 'No title',
      author: map['author'] as String? ?? '',
      place: map['place'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dateOfSubmission: map['dateOfSubmission'] as String? ?? '',
      userUID: map['userUID'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'place': place,
      'description': description,
      'dateOfSubmission': dateOfSubmission,
      'userUID': userUID,
      'imageUrl': imageUrl,
    };
  }
}
