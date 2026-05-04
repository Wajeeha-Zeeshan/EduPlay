import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../repositories/student_repository.dart';

class StudentViewModel extends ChangeNotifier {
  final StudentRepository repo = StudentRepository();

  bool isLoading = false;
  String errorMessage = '';
  Student? student;

  Future<void> createStudent(Student s) async {
    try {
      isLoading = true;
      notifyListeners();

      await repo.createStudent(s);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getStudent(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      student = await repo.getStudent(id);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch student';
      notifyListeners();
    }
  }

  Future<void> editStudent(Student s) async {
    try {
      isLoading = true;
      notifyListeners();

      await repo.updateStudent(s);

      student = s;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentID) async {
    try {
      isLoading = true;
      notifyListeners();

      await repo.deleteStudent(studentID);

      student = null;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
