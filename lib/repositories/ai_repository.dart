import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<String> generateLearningPath(String studentId) async {
    try {
      print("AI FUNCTION STARTED");

      final performance = await _fetchStudentPerformance(studentId);

      final prompt = '''
You are an AI educational assistant for a preschool literacy learning app.

The app contains ONLY these educational games:

1. ABC Recognition Game
- Students match uppercase and lowercase letters
- Focus: letter recognition skills

2. Letter Hunt
- Students identify the next letter in alphabetical order
- Focus: alphabet sequencing skills

3. Word Match
- Students match words with images
- Focus: vocabulary and word association

IMPORTANT RULES:
- Recommend ONLY games from the list above
- Do NOT invent new games
- Keep responses short and structured
- Do NOT use markdown symbols like *, #, or **
- Use simple teacher-friendly language
- Give recommendations based on student performance
- If the student performs very well in ABC Recognition, suggest progressing to Letter Hunt
- If the student performs well in Letter Hunt, suggest progressing to Word Match
- If the student struggles, recommend revising current skills first

Return EXACTLY in this format:

Strengths:
- point

Weaknesses:
- point

Next Recommended Game:
- game name
- reason

Recommended Activities:
- activity

Teacher Guidance:
- guidance

Student Performance:
$performance
''';

      final response = await model.generateContent([Content.text(prompt)]);

      final generatedText = response.text ?? "No response generated.";

      print("AI RESPONSE RECEIVED");

      // SAVE TO FIRESTORE
      final docRef = await _db.collection('learningPaths').add({
        'studentId': studentId,
        'generatedPath': generatedText,

        // FIXED HERE
        'createdAt': Timestamp.now(),

        'modelUsed': 'gemini-2.5-flash',
      });

      print("DOCUMENT SAVED: ${docRef.id}");

      return generatedText;
    } catch (e, stack) {
      print("ERROR: $e");
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

      StringBuffer buffer = StringBuffer();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        buffer.writeln('''
Game: ${data['gameId'] ?? 'Unknown'}
Score: ${data['score'] ?? 'N/A'}
Accuracy: ${data['accuracy'] ?? 'N/A'}%
Current Level: ${data['currentLevel'] ?? 'N/A'} / ${data['totalLevels'] ?? 'N/A'}
Total Retries: ${data['totalRetries'] ?? 0}
---
''');
      }

      return buffer.toString();
    } catch (e) {
      print("FETCH ERROR: $e");
      return "Error fetching performance data.";
    }
  }

  Future<Map<String, dynamic>?> getLatestLearningPathWithDocId(
    String studentId,
  ) async {
    try {
      final snapshot =
          await _db
              .collection('learningPaths')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      print("FOUND DOCS: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;

      print("DOCUMENT ID: ${doc.id}");

      return {'docId': doc.id, 'generatedPath': doc['generatedPath']};
    } catch (e) {
      print("GET ERROR: $e");
      return null;
    }
  }

  Future<void> updateLearningPath(String docId, String newContent) async {
    try {
      await _db.collection('learningPaths').doc(docId).update({
        'generatedPath': newContent,
        'updatedAt': Timestamp.now(),
      });

      print("LEARNING PATH UPDATED");
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
        print("LEARNING PATH DELETED");
      }
    } catch (e) {
      print("DELETE ERROR: $e");
      rethrow;
    }
  }
}
