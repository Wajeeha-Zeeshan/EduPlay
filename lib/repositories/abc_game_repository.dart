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
    } else {
      return StudentGameProgress(
        currentLevel: 0,
        score: 0,
        completedLevels: [],
        retries: {},
      );
    }
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
