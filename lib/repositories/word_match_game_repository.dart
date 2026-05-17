import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_game_progress.dart';

class WordMatchRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<StudentGameProgress> getProgress(String studentId) async {
    final doc =
        await db
            .collection('students')
            .doc(studentId)
            .collection('gameProgress')
            .doc('wordMatch')
            .get();

    if (doc.exists && doc.data() != null) {
      return StudentGameProgress.fromMap(doc.data()!);
    }

    return StudentGameProgress(
      gameId: "Word Match",
      currentLevel: 0,
      score: 0,
      totalLevels: 10,
      accuracy: 0,
      totalRetries: 0,
      completedLevels: [],
      retries: {},
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> saveProgress(
    String studentId,
    StudentGameProgress progress,
  ) async {
    await db
        .collection('students')
        .doc(studentId)
        .collection('gameProgress')
        .doc('wordMatch')
        .set(progress.toMap());
  }
}
