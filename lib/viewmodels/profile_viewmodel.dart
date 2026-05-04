import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../models/parent_model.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'package:email_validator/email_validator.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  AppUser user;
  bool isEditing = false;
  bool isLoading = false;
  String? errorMessage;

  ProfileViewModel({required this.user});

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? staffID,
  }) async {
    if (name.isEmpty ||
        email.isEmpty ||
        (user is Teacher && (staffID?.isEmpty ?? true))) {
      errorMessage = "All required fields must be filled.";
      notifyListeners();
      return;
    }

    if (!EmailValidator.validate(email.trim())) {
      errorMessage = "Enter a valid email";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (user is Teacher) {
        final teacher = user as Teacher;
        final updatedTeacher = Teacher(
          userID: teacher.userID,
          name: name.trim(),
          email: email.trim(),
          staffID: staffID!.trim(),
          students: teacher.students,
          manageLearningPaths: teacher.manageLearningPaths,
          managedReports: teacher.managedReports,
        );
        await _userRepo.updateTeacherProfile(updatedTeacher);
        user = updatedTeacher;
      } else if (user is Parent) {
        final parent = user as Parent;
        final updatedParent = Parent(
          userID: parent.userID,
          name: name.trim(),
          email: email.trim(),
          parentID: parent.parentID,
          studentID: parent.studentID,
        );
        await _userRepo.updateParentProfile(updatedParent);
        user = updatedParent;
      }
      isEditing = false;
    } catch (e) {
      errorMessage = "Failed to update profile: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (user is Teacher) {
        await _userRepo.deleteTeacherProfile(user.userID);
      } else if (user is Parent) {
        await _userRepo.deleteParentProfile(user.userID);
      }
    } catch (e) {
      errorMessage = "Failed to delete profile: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
