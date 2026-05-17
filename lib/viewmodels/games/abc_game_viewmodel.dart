import 'package:flutter/material.dart';
import '../../repositories/abc_game_repository.dart';
import '../../models/student_game_progress.dart';
import '../../models/reward_model.dart';
import '../../viewmodels/reward_viewmodel.dart';

class ABCGameViewModel extends ChangeNotifier {
  final GameRepository _repo = GameRepository();
  final RewardViewModel rewardVM = RewardViewModel();

  final List<String> letters = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  int currentLevel = 0;
  int score = 0;
  int levelScore = 0;

  String currentUpper = '';
  List<String> options = [];
  String correctAnswer = '';

  bool isLoading = true;
  String? studentId;

  Map<String, int> retries = {};

  String? feedbackMessage;
  bool isCorrect = true;

  List<Reward> earnedRewards = [];

  Future<void> init(String id) async {
    studentId = id;

    final progress = await _repo.getProgress(studentId!);
    await rewardVM.loadRewards(studentId!);

    earnedRewards = List.from(rewardVM.rewards);

    currentLevel = progress.currentLevel;
    score = progress.score;
    retries = Map.from(progress.retries);

    _loadLevel();

    isLoading = false;
    notifyListeners();
  }

  void _loadLevel() {
    if (currentLevel >= letters.length) return;

    levelScore = 0;
    currentUpper = letters[currentLevel];
    correctAnswer = currentUpper.toLowerCase();

    feedbackMessage = null;

    options = _generateOptions(correctAnswer);
  }

  List<String> _generateOptions(String correct) {
    List<String> all = List.generate(26, (i) => String.fromCharCode(97 + i));

    all.remove(correct);
    all.shuffle();

    List<String> wrong = all.take(2).toList();

    List<String> result = [...wrong, correct];
    result.shuffle();

    return result;
  }

  Future<void> selectAnswer(String selected) async {
    String levelKey = currentUpper;

    if (selected == correctAnswer) {
      feedbackMessage = "Correct! +10 points";
      isCorrect = true;

      score += 10;
      levelScore += 10;

      currentLevel++;

      await _save();

      if (currentLevel < letters.length) {
        _loadLevel();
      } else {
        await _giveFinalReward();
      }
    } else {
      feedbackMessage = "Wrong! Try again";
      isCorrect = false;

      score = (score - 5).clamp(0, double.infinity).toInt();
      levelScore = (levelScore - 5).clamp(0, double.infinity).toInt();

      retries[levelKey] = (retries[levelKey] ?? 0) + 1;

      await _save();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    if (studentId == null) return;

    await _repo.saveProgress(
      studentId!,
      StudentGameProgress(
        gameId: "ABC Recognition",
        currentLevel: currentLevel,
        score: score,
        totalLevels: 26,
        accuracy: ((score / 260) * 100).clamp(0, 100),
        totalRetries: getTotalRetries(),
        completedLevels: letters.take(currentLevel).toList(),
        retries: retries,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<void> _giveFinalReward() async {
    if (studentId == null) return;

    try {
      int totalRetries = getTotalRetries();

      double accuracy = (score / 260) * 100;

      String rewardType;

      if (score >= 250 || (accuracy >= 95 && totalRetries == 0)) {
        rewardType = "crown";
      } else if (score >= 200 || accuracy >= 80) {
        rewardType = "star";
      } else if (totalRetries <= 3) {
        rewardType = "gem";
      } else {
        rewardType = "candy";
      }

      await rewardVM.giveReward(studentId!, rewardType);

      earnedRewards = List.from(rewardVM.rewards);

      feedbackMessage = _getRewardMessage(rewardType);

      notifyListeners();
    } catch (e) {
      debugPrint("Final reward error: $e");
    }
  }

  String _getRewardMessage(String rewardType) {
    switch (rewardType) {
      case "crown":
        return "Perfect Mastery! Golden Crown Earned!";
      case "star":
        return "Excellent Work! Magic Star Earned!";
      case "gem":
        return "Great Job! Rainbow Gem Earned!";
      case "candy":
        return "Good Effort! Candy Coin Earned!";
      default:
        return "Keep Practicing!";
    }
  }

  String getRewardMessage() {
    if (!isCompleted()) return "";

    int totalRetries = getTotalRetries();

    if (score >= 250 || (score >= 240 && totalRetries == 0)) {
      return "Perfect Score!";
    }

    if (score >= 200) {
      return "Excellent Performance!";
    }

    if (score >= 150) {
      return "Great Job!";
    }

    if (score >= 100) {
      return "Good Effort!";
    }

    return "Keep Practicing!";
  }

  bool isCompleted() {
    return currentLevel >= letters.length;
  }

  int getTotalRetries() {
    return retries.values.fold(0, (sum, value) => sum + value);
  }
}
