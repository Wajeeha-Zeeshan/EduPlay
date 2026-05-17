class StudentGameProgress {
  final String gameId;
  final int currentLevel;
  final int score;
  final int totalLevels;
  final double accuracy;
  final int totalRetries;
  final List<String> completedLevels;
  final Map<String, int> retries;
  final DateTime lastUpdated;

  StudentGameProgress({
    required this.gameId,
    required this.currentLevel,
    required this.score,
    required this.totalLevels,
    required this.accuracy,
    required this.totalRetries,
    required this.completedLevels,
    required this.retries,
    required this.lastUpdated,
  });

  factory StudentGameProgress.fromMap(Map<String, dynamic> map) {
    return StudentGameProgress(
      gameId: map['gameId'] ?? '',
      currentLevel: map['currentLevel'] ?? 0,
      score: map['score'] ?? 0,
      totalLevels: map['totalLevels'] ?? 0,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      totalRetries: map['totalRetries'] ?? 0,
      completedLevels: List<String>.from(map['completedLevels'] ?? []),
      retries: Map<String, int>.from(map['retries'] ?? {}),
      lastUpdated:
          map['lastUpdated'] != null
              ? map['lastUpdated'].toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'currentLevel': currentLevel,
      'score': score,
      'totalLevels': totalLevels,
      'accuracy': accuracy,
      'totalRetries': totalRetries,
      'completedLevels': completedLevels,
      'retries': retries,
      'lastUpdated': lastUpdated,
    };
  }
}
