import 'user_model.dart';

class Teacher extends AppUser {
  final String staffID;
  final List<String> students;
  final List<String> manageLearningPaths;
  final List<String> managedReports;

  Teacher({
    required String userID,
    required String name,
    required String email,
    required this.staffID,
    this.students = const [],
    this.manageLearningPaths = const [],
    this.managedReports = const [],
  }) : super(userID: userID, name: name, email: email, role: 'teacher');

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'staffID': staffID,
    'students': students,
    'manageLearningPaths': manageLearningPaths,
    'managedReports': managedReports,
  };

  factory Teacher.fromMap(Map<String, dynamic> map) => Teacher(
    userID: map['userID'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    staffID: map['staffID'] ?? '',
    students: List<String>.from(map['students'] ?? []),
    manageLearningPaths: List<String>.from(map['manageLearningPaths'] ?? []),
    managedReports: List<String>.from(map['managedReports'] ?? []),
  );
}
