// =========================== progress_report.dart ===========================

class ProgressReport {
  final String studentId;
  final String generatedReport;
  final String overallAccuracy;
  final int totalScore;
  final int gamesPlayed;
  final DateTime createdAt;

  ProgressReport({
    required this.studentId,
    required this.generatedReport,
    required this.overallAccuracy,
    required this.totalScore,
    required this.gamesPlayed,
    required this.createdAt,
  });

  factory ProgressReport.fromMap(Map<String, dynamic> map) {
    return ProgressReport(
      studentId: map['studentId'] ?? '',
      generatedReport: map['generatedReport'] ?? '',
      overallAccuracy: map['overallAccuracy']?.toString() ?? '0',
      totalScore: map['totalScore'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      createdAt:
          map['createdAt'] != null ? map['createdAt'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'generatedReport': generatedReport,
      'overallAccuracy': overallAccuracy,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'createdAt': createdAt,
    };
  }
}
