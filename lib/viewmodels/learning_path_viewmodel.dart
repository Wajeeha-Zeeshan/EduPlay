import 'package:eduplay/repositories/learning_path_repository.dart';
import 'package:flutter/material.dart';
import '../repositories/learning_path_repository.dart';
import '../models/learning_path_model.dart';

class LearningPathViewModel extends ChangeNotifier {
  final AIRepository repo = AIRepository();

  bool isLoading = false;
  String learningPath = "";
  String? currentDocId; // ← Now stores real Firestore docId
  bool isApproved = false;
  String? approvedBy;

  Future<void> loadLearningPath(String studentId) async {
    isLoading = true;
    notifyListeners();

    final model = await repo.getLatestLearningPath(studentId);
    if (model != null) {
      learningPath = model.generatedPath;
      currentDocId = model.docId; // ← Critical fix
      isApproved = model.isApproved;
      approvedBy = model.approvedBy;
    } else {
      learningPath = "No learning path found yet.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> approvePath(String teacherId) async {
    if (currentDocId == null) return;

    isLoading = true;
    notifyListeners();

    await repo.approveLearningPath(currentDocId!, teacherId);
    isApproved = true;
    approvedBy = teacherId;

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateLearningPath(String newContent) async {
    if (currentDocId == null) return;

    isLoading = true;
    notifyListeners();

    await repo.updateLearningPath(currentDocId!, newContent);
    learningPath = newContent;

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLearningPath(String studentId) async {
    isLoading = true;
    notifyListeners();
    await repo.deleteLearningPath(studentId);
    learningPath = "Learning path has been deleted.";
    currentDocId = null;
    isApproved = false;
    isLoading = false;
    notifyListeners();
  }
}
