import 'user_model.dart';

class Parent extends AppUser {
  final String parentID;
  final String studentID;

  Parent({
    required String userID,
    required String name,
    required String email,
    required this.parentID,
    required this.studentID,
  }) : super(userID: userID, name: name, email: email, role: 'parent');

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'parentID': parentID,
    'studentID': studentID,
  };

  factory Parent.fromMap(Map<String, dynamic> map) => Parent(
    userID: map['userID'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    parentID: map['parentID'] ?? '',
    studentID: map['studentID'] ?? '',
  );
}
