import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/student_game_progress.dart';
import '../../models/reward_model.dart';
import '../../repositories/letter_hunt_game_repository.dart';
import '../../viewmodels/reward_viewmodel.dart';

class LetterHuntViewModel extends ChangeNotifier {
  final LetterHuntRepository repo = LetterHuntRepository();
  final RewardViewModel rewardVM = RewardViewModel();

  final List<String> letters = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  int currentLevel = 0;
  int score = 0;

  String currentSequence = '';
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

    final progress = await repo.getProgress(studentId!);
    await rewardVM.loadRewards(studentId!);

    earnedRewards = List.from(rewardVM.rewards);

    currentLevel = progress.currentLevel;
    score = progress.score;
    retries = Map.from(progress.retries);

    loadLevel();

    isLoading = false;
    notifyListeners();
  }

  void loadLevel() {
    if (currentLevel >= 26) return;

    feedbackMessage = null;

    final startIndex = Random().nextInt(24);

    final first = letters[startIndex];
    final second = letters[startIndex + 1];
    correctAnswer = letters[startIndex + 2];

    currentSequence = "$first $second _";

    options = _generateOptions(correctAnswer);
  }

  List<String> _generateOptions(String correct) {
    List<String> all = List.from(letters);

    all.remove(correct);
    all.shuffle();

    List<String> wrong = all.take(2).toList();

    List<String> result = [...wrong, correct];
    result.shuffle();

    return result;
  }

  Future<void> selectAnswer(String selected) async {
    String levelKey = "Level${currentLevel + 1}";

    if (selected == correctAnswer) {
      feedbackMessage = "Correct! +10 points";
      isCorrect = true;

      score += 10;
      currentLevel++;

      await save();

      if (currentLevel < 26) {
        loadLevel();
      } else {
        await giveFinalReward();
      }
    } else {
      feedbackMessage = "Wrong! Try again";
      isCorrect = false;

      score = (score - 5).clamp(0, double.infinity).toInt();

      retries[levelKey] = (retries[levelKey] ?? 0) + 1;

      await save();
    }

    notifyListeners();
  }

  Future<void> save() async {
    if (studentId == null) return;

    await repo.saveProgress(
      studentId!,
      StudentGameProgress(
        currentLevel: currentLevel,
        score: score,
        completedLevels: List.generate(currentLevel, (i) => "Level ${i + 1}"),
        retries: retries,
      ),
    );
  }

  Future<void> giveFinalReward() async {
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

      // Random surprise reward for kids
      if (Random().nextInt(6) == 0) {
        rewardType = "sticker";
      }

      await rewardVM.giveReward(studentId!, rewardType);

      earnedRewards = List.from(rewardVM.rewards);

      feedbackMessage = _getRewardMessage(rewardType);

      notifyListeners();
    } catch (e) {
      debugPrint("Reward error: $e");
    }
  }

  String _getRewardMessage(String type) {
    switch (type) {
      case "crown":
        return "Perfect Mastery! Golden Crown Earned!";
      case "star":
        return "Excellent Work! Magic Star Earned!";
      case "gem":
        return "Great Job! Rainbow Gem Earned!";
      case "candy":
        return "Good Effort! Candy Coin Earned!";
      case "sticker":
        return "Surprise! Special Sticker Unlocked!";
      default:
        return "Well Done!";
    }
  }

  String getOverallRewardMessage() {
    if (!isCompleted()) return "";

    int totalRetries = getTotalRetries();

    if (score >= 250 || (score >= 240 && totalRetries == 0)) {
      return "Perfect Score! Outstanding!";
    }

    if (score >= 200) return "Excellent Performance!";
    if (score >= 150) return "Great Job!";
    if (score >= 100) return "Good Effort!";

    return "Keep Practicing!";
  }

  bool isCompleted() => currentLevel >= 26;

  int getTotalRetries() => retries.values.fold(0, (a, b) => a + b);
}
