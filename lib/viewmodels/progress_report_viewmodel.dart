// =========================== progress_report_viewmodel.dart ===========================

import 'package:flutter/material.dart';
import '../repositories/progress_report_repository.dart';

class ProgressReportViewModel extends ChangeNotifier {
  final ProgressReportRepository repo = ProgressReportRepository();

  bool isLoading = false;
  String report = "";
  String? currentDocId;
  String overallAccuracy = "0";
  int totalScore = 0;
  int gamesPlayed = 0;

  Future<void> generateReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    report = await repo.generateProgressReport(studentId);
    await loadReport(studentId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    final data = await repo.getLatestReport(studentId);

    if (data != null) {
      report = data['generatedReport'];
      currentDocId = data['docId'];
      overallAccuracy = data['overallAccuracy'];
      totalScore = data['totalScore'];
      gamesPlayed = data['gamesPlayed'];
    } else {
      report = "No report found.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateReport(String updatedReport) async {
    if (currentDocId == null) return;

    isLoading = true;
    notifyListeners();

    await repo.updateGeneratedReport(currentDocId!, updatedReport);
    report = updatedReport;

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    await repo.deleteReport(studentId);

    report = "";
    currentDocId = null;

    isLoading = false;
    notifyListeners();
  }

  Future<void> generateNewReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    final result = await repo.generateProgressReport(studentId);
    report = result;

    final data = await repo.getLatestReport(studentId);
    if (data != null) {
      currentDocId = data['docId'];
      overallAccuracy = data['overallAccuracy'];
      totalScore = data['totalScore'];
      gamesPlayed = data['gamesPlayed'];
    }

    isLoading = false;
    notifyListeners();
  }
}
