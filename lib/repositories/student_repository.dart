import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createStudent(Student student) async {
    final check =
        await _firestore
            .collection('students')
            .where('studentID', isEqualTo: student.studentID)
            .get();

    if (check.docs.isNotEmpty) {
      throw Exception('Student ID already in use');
    }

    await _firestore
        .collection('students')
        .doc(student.studentID)
        .set(student.toMap());
  }

  Future<Student?> getStudent(String studentID) async {
    final doc = await _firestore.collection('students').doc(studentID).get();

    if (!doc.exists) return null;

    return Student.fromMap(doc.data()!);
  }

  Future<bool> studentExists(String studentId) async {
    final doc = await _firestore.collection('students').doc(studentId).get();

    return doc.exists;
  }

  Future<void> updateStudent(Student student) async {
    final docRef = _firestore.collection('students').doc(student.studentID);

    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Student not found');
    }

    await docRef.update(student.toMap());
  }

  Future<void> deleteStudent(String studentID) async {
    final docRef = _firestore.collection('students').doc(studentID);

    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Student not found');
    }

    await docRef.delete();
  }
}
