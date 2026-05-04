class StudentGameProgress {
  final int currentLevel;
  final int score;
  final List<String> completedLevels;
  final Map<String, int> retries;

  StudentGameProgress({
    required this.currentLevel,
    required this.score,
    required this.completedLevels,
    required this.retries,
  });

  factory StudentGameProgress.fromMap(Map<String, dynamic> map) {
    return StudentGameProgress(
      currentLevel: map['currentLevel'] ?? 0,
      score: map['score'] ?? 0,
      completedLevels: List<String>.from(map['completedLevels'] ?? []),
      retries: Map<String, int>.from(map['retries'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentLevel': currentLevel,
      'score': score,
      'completedLevels': completedLevels,
      'retries': retries,
      'lastUpdated': DateTime.now(),
    };
  }
}
