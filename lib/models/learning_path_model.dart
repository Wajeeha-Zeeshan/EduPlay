class LearningPathModel {
  final String studentId;
  final String generatedPath;
  final DateTime createdAt;

  LearningPathModel({
    required this.studentId,
    required this.generatedPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'generatedPath': generatedPath,
      'createdAt': createdAt,
    };
  }

  factory LearningPathModel.fromMap(Map<String, dynamic> map) {
    return LearningPathModel(
      studentId: map['studentId'] ?? '',
      generatedPath: map['generatedPath'] ?? '',
      createdAt: map['createdAt'].toDate(),
    );
  }
}
