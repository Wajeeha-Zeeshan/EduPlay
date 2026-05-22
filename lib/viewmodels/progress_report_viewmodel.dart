import 'package:flutter/material.dart';
import '../repositories/progress_report_repository.dart';
import '../models/progress_report_model.dart';

class ProgressReportViewModel extends ChangeNotifier {
  final ProgressReportRepository repo = ProgressReportRepository();

  bool isLoading = false;
  String report = "";
  String? currentDocId;
  bool isApproved = false;
  String? approvedBy;

  String overallAccuracy = "0";
  int totalScore = 0;
  int gamesPlayed = 0;

  Future<void> loadReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    final model = await repo.getLatestReport(studentId);
    if (model != null) {
      report = model.generatedReport;
      currentDocId = model.docId;
      isApproved = model.isApproved;
      approvedBy = model.approvedBy;
      overallAccuracy = model.overallAccuracy;
      totalScore = model.totalScore;
      gamesPlayed = model.gamesPlayed;
    } else {
      report = "No progress report found yet.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> approveReport(String teacherId) async {
    if (currentDocId == null) return;
    isLoading = true;
    notifyListeners();

    await repo.approveReport(currentDocId!, teacherId);
    isApproved = true;
    approvedBy = teacherId;

    isLoading = false;
    notifyListeners();
  }

  Future<void> generateReport(String studentId) async {
    isLoading = true;
    notifyListeners();

    await repo.generateProgressReport(studentId);
    await loadReport(studentId);

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
    report = "Report has been deleted.";
    currentDocId = null;
    isLoading = false;
    notifyListeners();
  }
}
