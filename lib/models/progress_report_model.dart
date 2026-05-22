import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressReport {
  final String docId;
  final String studentId;
  final String generatedReport;
  final String overallAccuracy;
  final int totalScore;
  final int gamesPlayed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;

  ProgressReport({
    required this.docId,
    required this.studentId,
    required this.generatedReport,
    required this.overallAccuracy,
    required this.totalScore,
    required this.gamesPlayed,
    required this.createdAt,
    this.updatedAt,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
  });

  factory ProgressReport.fromMap(String docId, Map<String, dynamic> map) {
    return ProgressReport(
      docId: docId,
      studentId: map['studentId'] ?? '',
      generatedReport: map['generatedReport'] ?? '',
      overallAccuracy: map['overallAccuracy']?.toString() ?? '0',
      totalScore: map['totalScore'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
      isApproved: map['isApproved'] ?? false,
      approvedBy: map['approvedBy'],
      approvedAt:
          map['approvedAt'] != null
              ? (map['approvedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
