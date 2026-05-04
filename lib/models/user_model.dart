class AppUser {
  final String userID;
  final String name;
  final String email;
  final String role;

  AppUser({
    required this.userID,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
    'userID': userID,
    'name': name,
    'email': email,
    'role': role,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    userID: map['userID'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? '',
  );
}
