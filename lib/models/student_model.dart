class Student {
  final String studentID;
  final String name;
  final int age;
  final String section;
  final String studentClass;
  final String assignedGame;
  final bool initialGameCompleted;

  Student({
    required this.studentID,
    required this.name,
    required this.age,
    required this.section,
    required this.studentClass,

    this.assignedGame = '',
    this.initialGameCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'studentID': studentID,
    'name': name,
    'age': age,
    'section': section,
    'studentClass': studentClass,

    'assignedGame': assignedGame,
    'initialGameCompleted': initialGameCompleted,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    studentID: map['studentID'] ?? '',
    name: map['name'] ?? '',
    age: map['age'] ?? 0,
    section: map['section'] ?? '',
    studentClass: map['studentClass'] ?? '',
    assignedGame: map['assignedGame'] ?? '',

    initialGameCompleted: map['initialGameCompleted'] ?? false,
  );
}
