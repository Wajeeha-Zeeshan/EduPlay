import 'package:flutter/material.dart';
import '../repositories/ai_repository.dart';

class LearningPathViewModel extends ChangeNotifier {
  final AIRepository repo = AIRepository();

  bool isLoading = false;
  String learningPath = "";
  String? currentDocId; // ← Important

  Future<void> generateAndLoad(String studentId) async {
    isLoading = true;
    notifyListeners();

    final result = await repo.generateLearningPath(studentId);
    learningPath = result;

    isLoading = false;
    notifyListeners();
  }

  // Load with Document ID
  // Temporary version (until index is created)
  Future<void> loadLearningPathWithDoc(String studentId) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await repo.getLatestLearningPathWithDocId(studentId);
      if (data != null) {
        learningPath = data['generatedPath'];
        currentDocId = data['docId'];
      } else {
        learningPath = "No learning path found yet.";
      }
    } catch (e) {
      print("Load Error: $e");
      learningPath = "Error loading learning path.";
    }

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

    isLoading = false;
    notifyListeners();
  }

  Future<void> generateNewPath(String studentId) async {
    isLoading = true;
    notifyListeners();

    final result = await repo.generateLearningPath(studentId);
    learningPath = result;
    // Reload docId after generation
    final data = await repo.getLatestLearningPathWithDocId(studentId);
    if (data != null) {
      currentDocId = data['docId'];
    }

    isLoading = false;
    notifyListeners();
  }
}
