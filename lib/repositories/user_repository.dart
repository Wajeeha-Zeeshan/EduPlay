import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../models/parent_model.dart';
import '../models/teacher_model.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      final role = userData['role'];

      if (role == 'teacher') {
        final teacherDoc =
            await _firestore.collection('teachers').doc(userId).get();
        return Teacher.fromMap({...userData, ...?teacherDoc.data()});
      }

      if (role == 'parent') {
        final parentDoc =
            await _firestore.collection('parents').doc(userId).get();
        return Parent.fromMap({...userData, ...?parentDoc.data()});
      }

      return AppUser.fromMap(userData);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<Teacher> createTeacher({
    required String name,
    required String email,
    required String password,
    required String staffID,
  }) async {
    final staffCheck =
        await _firestore
            .collection('teachers')
            .where('staffID', isEqualTo: staffID)
            .get();
    if (staffCheck.docs.isNotEmpty) {
      throw Exception('Staff ID already in use.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'userID': uid,
      'name': name,
      'email': email,
      'role': 'teacher',
    });

    final teacher = Teacher(
      userID: uid,
      name: name,
      email: email,
      staffID: staffID,
    );

    await _firestore.collection('teachers').doc(uid).set({
      'userID': uid,
      'staffID': staffID,
      'students': teacher.students,
      'manageLearningPaths': teacher.manageLearningPaths,
      'managedReports': teacher.managedReports,
    });

    return teacher;
  }

  Future<Parent> createParent({
    required String name,
    required String email,
    required String password,
    required String studentID,
  }) async {
    try {
      final studentQuery =
          await _firestore
              .collection('students')
              .where('studentID', isEqualTo: studentID)
              .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception('Student ID not found.');
      }

      final studentData = studentQuery.docs.first.data();
      final studentName = studentData['name'] ?? 'Student';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'userID': uid,
        'name': name,
        'email': email,
        'role': 'parent',
      });

      final parent = Parent(
        userID: uid,
        parentID: uid,
        name: name,
        email: email,
        studentID: studentID,
      );

      await _firestore.collection('parents').doc(uid).set({
        'userID': uid,
        'studentID': studentID,
        'viewGames': [],
        'viewLearningPaths': [],
        'viewReports': [],
      });

      print("Parent registered successfully with student: $studentName");

      return parent;
    } catch (e) {
      throw Exception('Parent registration failed: $e');
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('User data not found.');

      final userData = userDoc.data()!;
      final role = userData['role'];

      if (role == 'teacher') {
        final teacherDoc =
            await _firestore.collection('teachers').doc(uid).get();
        return Teacher.fromMap({...userData, ...?teacherDoc.data()});
      }

      if (role == 'parent') {
        final parentDoc = await _firestore.collection('parents').doc(uid).get();
        return Parent.fromMap({...userData, ...?parentDoc.data()});
      }

      return AppUser.fromMap(userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Invalid email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email.');
      } else {
        throw Exception('Login failed.');
      }
    } catch (e) {
      throw Exception('Login failed.');
    }
  }

  Future<void> updateTeacherProfile(Teacher teacher) async {
    try {
      await _firestore.collection('users').doc(teacher.userID).update({
        'name': teacher.name,
        'email': teacher.email,
      });

      await _firestore.collection('teachers').doc(teacher.userID).update({
        'staffID': teacher.staffID,
        'students': teacher.students,
        'manageLearningPaths': teacher.manageLearningPaths,
        'managedReports': teacher.managedReports,
      });
    } catch (e) {
      throw Exception('Failed to update teacher profile: $e');
    }
  }

  Future<void> updateParentProfile(Parent parent) async {
    try {
      await _firestore.collection('users').doc(parent.userID).update({
        'name': parent.name,
        'email': parent.email,
      });

      await _firestore.collection('parents').doc(parent.userID).update({
        'studentID': parent.studentID,
      });
    } catch (e) {
      throw Exception('Failed to update parent profile: $e');
    }
  }

  Future<void> deleteTeacherProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _firestore.collection('teachers').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete teacher profile: $e');
    }
  }

  Future<void> deleteParentProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _firestore.collection('parents').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete parent profile: $e');
    }
  }
}
