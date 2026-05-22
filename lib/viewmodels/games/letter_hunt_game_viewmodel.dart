import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/student_game_progress.dart';
import '../../models/reward_model.dart';
import '../../repositories/letter_hunt_game_repository.dart';
import '../../viewmodels/reward_viewmodel.dart';

class LetterHuntViewModel extends ChangeNotifier {
  final LetterHuntRepository repo = LetterHuntRepository();
  final RewardViewModel rewardVM = RewardViewModel();
  final int totalLevels = 30;

  final List<Map<String, String>> levels = [
    {"sequence": "K L _", "answer": "M"},
    {"sequence": "A B _", "answer": "C"},
    {"sequence": "R S _", "answer": "T"},
    {"sequence": "D E _", "answer": "F"},
    {"sequence": "X Y _", "answer": "Z"},
    {"sequence": "M N _", "answer": "O"},
    {"sequence": "G H _", "answer": "I"},
    {"sequence": "P Q _", "answer": "R"},
    {"sequence": "B C _", "answer": "D"},
    {"sequence": "T U _", "answer": "V"},
    {"sequence": "F G _", "answer": "H"},
    {"sequence": "J K _", "answer": "L"},
    {"sequence": "L M _", "answer": "N"},
    {"sequence": "N O _", "answer": "P"},
    {"sequence": "Q R _", "answer": "S"},
    {"sequence": "S T _", "answer": "U"},
    {"sequence": "U V _", "answer": "W"},
    {"sequence": "V W _", "answer": "X"},
    {"sequence": "C D _", "answer": "E"},
    {"sequence": "E F _", "answer": "G"},
    {"sequence": "H I _", "answer": "J"},
    {"sequence": "I J _", "answer": "K"},
    {"sequence": "O P _", "answer": "Q"},
    {"sequence": "W X _", "answer": "Y"},
    {"sequence": "Y Z _", "answer": "A"},
    {"sequence": "Z A _", "answer": "B"},
    {"sequence": "P Q _", "answer": "R"},
    {"sequence": "D E _", "answer": "F"},
    {"sequence": "M N _", "answer": "O"},
    {"sequence": "T U _", "answer": "V"},
  ];

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
    if (currentLevel >= levels.length) return;

    feedbackMessage = null;

    currentSequence = levels[currentLevel]["sequence"]!;
    correctAnswer = levels[currentLevel]["answer"]!;

    options = _generateOptions(correctAnswer);
  }

  List<String> _generateOptions(String correct) {
    List<String> allLetters = List.generate(
      26,
      (i) => String.fromCharCode(65 + i),
    );

    allLetters.remove(correct);
    allLetters.shuffle();

    List<String> wrong = allLetters.take(2).toList();

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

      if (currentLevel < levels.length) {
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
        gameId: "Letter Hunt",
        currentLevel: currentLevel,
        score: score,
        totalLevels: totalLevels,
        accuracy: ((score / (totalLevels * 10)) * 100).clamp(0, 100),
        totalRetries: getTotalRetries(),
        completedLevels: List.generate(currentLevel, (i) => "Level ${i + 1}"),
        retries: retries,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<void> giveFinalReward() async {
    if (studentId == null) return;

    try {
      int totalRetries = getTotalRetries();
      double accuracy = (score / (totalLevels * 10)) * 100;

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

  bool isCompleted() => currentLevel >= totalLevels;

  int getTotalRetries() => retries.values.fold(0, (a, b) => a + b);
}
