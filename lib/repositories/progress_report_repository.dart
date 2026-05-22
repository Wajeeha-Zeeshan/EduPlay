import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/progress_report_model.dart';

class ProgressReportRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generate AI progress report
  Future<String> generateProgressReport(String studentId) async {
    try {
      print("📊 PROGRESS REPORT GENERATION STARTED: $studentId");

      final performance = await _fetchStudentPerformance(studentId);

      final prompt = '''
You are an AI preschool educational assistant generating professional student progress reports.

The preschool literacy application contains ONLY these educational games:

1. ABC Recognition - Letter recognition skills
2. Letter Hunt - Alphabet sequencing skills
3. Word Match - Vocabulary and image-word association skills

Below is the COMPLETE student analytics data:

$performance

IMPORTANT RULES:
- This is a student progress report.
- DO NOT invent information. Use only the provided analytics.
- Keep language professional, warm, encouraging, and concise.
- No markdown symbols.

Return EXACTLY in this format:

Student Progress Report

Overall AI Assessment:
- summary
- overall accuracy
- total score

Strengths:
- point
- point

Areas for Improvement:
- point
- point

Game Performance:
- ABC Recognition: comment
- Letter Hunt: comment
- Word Match: comment

Learning Behaviour:
- retry observation
- consistency observation

Participation & Engagement:
- participation summary

Comments:
- constructive and encouraging comments

Conclusion:
- short professional summary
''';

      final generatedText = await _generateWithRetry(prompt);

      final analytics = await _getAnalyticsSummary(studentId);

      final docRef = await _db.collection('progressReports').add({
        'studentId': studentId,
        'generatedReport': generatedText,
        'overallAccuracy': analytics['overallAccuracy'],
        'totalScore': analytics['totalScore'],
        'gamesPlayed': analytics['gamesPlayed'],
        'createdAt': Timestamp.now(),
        'isApproved': false,
        'approvedBy': null,
        'approvedAt': null,
        'modelUsed': 'gemini-2.5-flash',
      });

      print("✅ REPORT SAVED: ${docRef.id}");
      return generatedText;
    } catch (e, stack) {
      print("❌ REPORT GENERATION ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  Future<String> _generateWithRetry(String prompt, {int maxRetries = 3}) async {
    final models = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
    ];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      for (final modelName in models) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: dotenv.env['GEMINI_API_KEY']!,
          );

          final response = await model.generateContent([Content.text(prompt)]);
          final text = response.text?.trim();

          if (text != null && text.isNotEmpty) {
            return text;
          }
        } catch (e) {
          print("⚠️ MODEL FAILED: $e");
          if (e.toString().contains("503") ||
              e.toString().contains("UNAVAILABLE") ||
              e.toString().contains("high demand")) {
            await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
            continue;
          } else {
            rethrow;
          }
        }
      }
    }
    throw Exception("AI service unavailable. Please try again later.");
  }

  Future<String> _fetchStudentPerformance(String studentId) async {
    try {
      final snapshot =
          await _db
              .collection('students')
              .doc(studentId)
              .collection('gameProgress')
              .get();

      if (snapshot.docs.isEmpty) {
        return "No performance data available.";
      }

      double totalAccuracy = 0;
      int totalScore = 0;
      int totalRetries = 0;
      int gamesPlayed = snapshot.docs.length;

      String strongestGame = "None";
      String weakestGame = "None";
      double highestAccuracy = 0;
      double lowestAccuracy = 999;

      StringBuffer gameDetails = StringBuffer();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final gameId = data['gameId'] ?? 'Unknown';
        final accuracy = double.tryParse(data['accuracy'].toString()) ?? 0;
        final score = int.tryParse(data['score'].toString()) ?? 0;
        final retries = int.tryParse(data['totalRetries'].toString()) ?? 0;

        totalAccuracy += accuracy;
        totalScore += score;
        totalRetries += retries;

        if (accuracy > highestAccuracy) {
          highestAccuracy = accuracy;
          strongestGame = gameId;
        }
        if (accuracy < lowestAccuracy) {
          lowestAccuracy = accuracy;
          weakestGame = gameId;
        }

        gameDetails.writeln("""
Game: $gameId
Accuracy: ${accuracy.toStringAsFixed(1)}%
Score: $score
Retries: $retries
Current Level: ${data['currentLevel'] ?? 0}
""");
      }

      final overallAccuracy =
          gamesPlayed > 0
              ? (totalAccuracy / gamesPlayed).toStringAsFixed(1)
              : "0";

      return """
Games Played: $gamesPlayed
Overall Accuracy: $overallAccuracy%
Total Score: $totalScore
Total Retries: $totalRetries

Strongest Game: $strongestGame
Weakest Game: $weakestGame

$gameDetails
""";
    } catch (e) {
      print("❌ FETCH ERROR: $e");
      return "Error fetching performance.";
    }
  }

  Future<Map<String, dynamic>> _getAnalyticsSummary(String studentId) async {
    final snapshot =
        await _db
            .collection('students')
            .doc(studentId)
            .collection('gameProgress')
            .get();

    double totalAccuracy = 0;
    int totalScore = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalAccuracy += double.tryParse(data['accuracy'].toString()) ?? 0;
      totalScore += int.tryParse(data['score'].toString()) ?? 0;
    }

    final gamesPlayed = snapshot.docs.length;
    final overallAccuracy = gamesPlayed > 0 ? totalAccuracy / gamesPlayed : 0;

    return {
      'overallAccuracy': overallAccuracy.toStringAsFixed(1),
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
    };
  }

  Future<ProgressReport?> getLatestReport(String studentId) async {
    try {
      final snapshot =
          await _db
              .collection('progressReports')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return ProgressReport.fromMap(doc.id, doc.data());
    } catch (e) {
      print("GET REPORT ERROR: $e");
      return null;
    }
  }

  Future<void> approveReport(String docId, String teacherId) async {
    try {
      await _db.collection('progressReports').doc(docId).update({
        'isApproved': true,
        'approvedBy': teacherId,
        'approvedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      print("Report approved: $docId");
    } catch (e) {
      print("APPROVE REPORT ERROR: $e");
      rethrow;
    }
  }

  Future<void> updateGeneratedReport(String docId, String updatedReport) async {
    try {
      await _db.collection('progressReports').doc(docId).update({
        'generatedReport': updatedReport,
        'updatedAt': Timestamp.now(),
      });
      print("Report updated: $docId");
    } catch (e) {
      print("UPDATE REPORT ERROR: $e");
      rethrow;
    }
  }

  Future<void> deleteReport(String studentId) async {
    try {
      final snapshot =
          await _db
              .collection('progressReports')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      print("DELETE REPORT ERROR: $e");
      rethrow;
    }
  }
}
