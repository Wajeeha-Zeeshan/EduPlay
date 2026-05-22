import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/learning_path_model.dart';

class AIRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final GenerativeModel model;

  AIRepository() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env file');
    }
    model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<String> generateLearningPath(
    String studentId, {
    String? teacherId,
  }) async {
    try {
      print("AI FUNCTION STARTED for student: $studentId");

      final performance = await _fetchStudentPerformance(studentId);
      final prompt =
          ''' You are an expert AI educational assistant for a preschool literacy learning app. The app contains ONLY these 3 educational games: 1. ABC Recognition Game - Students match uppercase and lowercase letters - Focus: Letter recognition skills 2. Letter Hunt - Students identify the next letter in alphabetical order - Focus: Alphabet sequencing skills 3. Word Match - Students match words with images - Focus: Vocabulary and word association A student has played one or more games. Here is their complete performance data: $performance IMPORTANT RULES: - Analyze ALL games the student has played. - Recommend ONLY games from the list above. - Do NOT invent new games. - Keep response short, clear and structured. - Do NOT use markdown symbols like *, #, **. - Use simple teacher-friendly language. - If student performs well in ABC Recognition → suggest Letter Hunt. - If student performs well in Letter Hunt → suggest Word Match. - If struggling in any game → recommend revising that game first. Return EXACTLY in this format: Strengths: - point 1 - point 2 Weaknesses: - point 1 - point 2 Next Recommended Game: - game name - reason Recommended Activities: - activity 1 - activity 2 Teacher Guidance: - guidance Student Performance: $performance ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final generatedText = response.text?.trim() ?? "No response generated.";

      // Save with approval status (default false)
      final docRef = await _db.collection('learningPaths').add({
        'studentId': studentId,
        'generatedPath': generatedText,
        'createdAt': Timestamp.now(),
        'updatedAt': null,
        'isApproved': false,
        'approvedBy': null,
        'approvedAt': null,
        'modelUsed': 'gemini-2.5-flash',
      });

      print("Learning path created: ${docRef.id}");
      return generatedText;
    } catch (e, stack) {
      print("ERROR in generateLearningPath: $e");
      print(stack);
      rethrow;
    }
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
        return "No performance data available yet.";
      }

      final buffer = StringBuffer();
      buffer.writeln("=== STUDENT PERFORMANCE SUMMARY ===\n");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        buffer.writeln("Game: ${data['gameId'] ?? 'Unknown'}");
        buffer.writeln("Score: ${data['score'] ?? 'N/A'}");
        buffer.writeln("Accuracy: ${data['accuracy'] ?? 'N/A'}%");
        buffer.writeln(
          "Current Level: ${data['currentLevel'] ?? 'N/A'} / ${data['totalLevels'] ?? 'N/A'}",
        );
        buffer.writeln("Total Retries: ${data['totalRetries'] ?? 0}");
        if (data['lastPlayed'] != null) {
          buffer.writeln("Last Played: ${data['lastPlayed']}");
        }
        buffer.writeln("---\n");
      }
      return buffer.toString();
    } catch (e) {
      print("FETCH PERFORMANCE ERROR: $e");
      return "Error fetching performance data.";
    }
  }

  // NEW: Get latest learning path with full details

  Future<LearningPathModel?> getLatestLearningPath(String studentId) async {
    try {
      final snapshot =
          await _db
              .collection('learningPaths')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return LearningPathModel.fromMap(doc.id, doc.data());
    } catch (e) {
      print("GET LATEST PATH ERROR: $e");
      return null;
    }
  }

  // NEW: Approve learning path (Teacher only)
  Future<void> approveLearningPath(String docId, String teacherId) async {
    try {
      await _db.collection('learningPaths').doc(docId).update({
        'isApproved': true,
        'approvedBy': teacherId,
        'approvedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      print("Learning path approved by teacher: $teacherId");
    } catch (e) {
      print("APPROVE ERROR: $e");
      rethrow;
    }
  }

  Future<void> updateLearningPath(String docId, String newContent) async {
    try {
      await _db.collection('learningPaths').doc(docId).update({
        'generatedPath': newContent,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("UPDATE ERROR: $e");
      rethrow;
    }
  }

  Future<void> deleteLearningPath(String studentId) async {
    try {
      final snapshot =
          await _db
              .collection('learningPaths')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      print("DELETE ERROR: $e");
      rethrow;
    }
  }
}
