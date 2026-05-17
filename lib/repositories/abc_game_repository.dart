import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_game_progress.dart';

class GameRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<StudentGameProgress> getProgress(String studentId) async {
    final doc =
        await _db
            .collection('students')
            .doc(studentId)
            .collection('gameProgress')
            .doc('abcGame')
            .get();

    if (doc.exists && doc.data() != null) {
      return StudentGameProgress.fromMap(doc.data()!);
    }

    return StudentGameProgress(
      gameId: "ABC Recognition",
      currentLevel: 0,
      score: 0,
      totalLevels: 26,
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
    await _db
        .collection('students')
        .doc(studentId)
        .collection('gameProgress')
        .doc('abcGame')
        .set(progress.toMap());
  }
}
