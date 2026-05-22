import 'package:flutter/material.dart';
import '../../models/student_game_progress.dart';
import '../../models/reward_model.dart';
import '../../repositories/word_match_game_repository.dart';
import '../reward_viewmodel.dart';
import 'dart:math';

class WordMatchViewModel extends ChangeNotifier {
  final WordMatchRepository repo = WordMatchRepository();
  final RewardViewModel rewardVM = RewardViewModel();

  int currentLevel = 0;
  int score = 0;

  bool isLoading = true;
  String? studentId;

  Map<String, int> retries = {};

  String? feedbackMessage;
  bool isCorrect = true;

  List<Reward> earnedRewards = [];

  final List<Map<String, dynamic>> levels = [
    {
      "word": "Tree",
      "correct": "assets/images/tree.png",
      "options": [
        "assets/images/book.png",
        "assets/images/tree.png",
        "assets/images/cake.png",
      ],
    },
    {
      "word": "Ball",
      "correct": "assets/images/ball.png",
      "options": [
        "assets/images/dog.png",
        "assets/images/ball.png",
        "assets/images/pizza.png",
      ],
    },
    {
      "word": "Rabbit",
      "correct": "assets/images/rabbit.png",
      "options": [
        "assets/images/rabbit.png",
        "assets/images/car.png",
        "assets/images/fish.png",
      ],
    },
    {
      "word": "Apple",
      "correct": "assets/images/apple.png",
      "options": [
        "assets/images/moon.png",
        "assets/images/apple.png",
        "assets/images/hat.png",
      ],
    },
    {
      "word": "Clock",
      "correct": "assets/images/clock.png",
      "options": [
        "assets/images/star.png",
        "assets/images/clock.png",
        "assets/images/banana.png",
      ],
    },
    {
      "word": "Dog",
      "correct": "assets/images/dog.png",
      "options": [
        "assets/images/pencil.png",
        "assets/images/sun.png",
        "assets/images/dog.png",
      ],
    },
    {
      "word": "Pizza",
      "correct": "assets/images/pizza.png",
      "options": [
        "assets/images/cake.png",
        "assets/images/pizza.png",
        "assets/images/boat.png",
      ],
    },
    {
      "word": "Cat",
      "correct": "assets/images/cat.png",
      "options": [
        "assets/images/book.png",
        "assets/images/cat.png",
        "assets/images/tree.png",
      ],
    },
    {
      "word": "Bird",
      "correct": "assets/images/bird.png",
      "options": [
        "assets/images/bird.png",
        "assets/images/apple.png",
        "assets/images/clock.png",
      ],
    },
    {
      "word": "Sun",
      "correct": "assets/images/sun.png",
      "options": [
        "assets/images/moon.png",
        "assets/images/rabbit.png",
        "assets/images/sun.png",
      ],
    },
    {
      "word": "Boat",
      "correct": "assets/images/boat.png",
      "options": [
        "assets/images/fish.png",
        "assets/images/boat.png",
        "assets/images/banana.png",
      ],
    },
    {
      "word": "Fish",
      "correct": "assets/images/fish.png",
      "options": [
        "assets/images/pizza.png",
        "assets/images/fish.png",
        "assets/images/hat.png",
      ],
    },
    {
      "word": "Book",
      "correct": "assets/images/book.png",
      "options": [
        "assets/images/book.png",
        "assets/images/star.png",
        "assets/images/car.png",
      ],
    },
    {
      "word": "Moon",
      "correct": "assets/images/moon.png",
      "options": [
        "assets/images/moon.png",
        "assets/images/tree.png",
        "assets/images/dog.png",
      ],
    },
    {
      "word": "Cake",
      "correct": "assets/images/cake.png",
      "options": [
        "assets/images/cake.png",
        "assets/images/apple.png",
        "assets/images/pencil.png",
      ],
    },
    {
      "word": "Car",
      "correct": "assets/images/car.png",
      "options": [
        "assets/images/clock.png",
        "assets/images/car.png",
        "assets/images/bird.png",
      ],
    },
    {
      "word": "Hat",
      "correct": "assets/images/hat.png",
      "options": [
        "assets/images/banana.png",
        "assets/images/hat.png",
        "assets/images/ball.png",
      ],
    },
    {
      "word": "Banana",
      "correct": "assets/images/banana.png",
      "options": [
        "assets/images/banana.png",
        "assets/images/rabbit.png",
        "assets/images/book.png",
      ],
    },
    {
      "word": "Pencil",
      "correct": "assets/images/pencil.png",
      "options": [
        "assets/images/star.png",
        "assets/images/pencil.png",
        "assets/images/cat.png",
      ],
    },
    {
      "word": "Star",
      "correct": "assets/images/star.png",
      "options": [
        "assets/images/boat.png",
        "assets/images/star.png",
        "assets/images/sun.png",
      ],
    },
  ];

  Future<void> init(String id) async {
    studentId = id;

    final progress = await repo.getProgress(studentId!);
    await rewardVM.loadRewards(studentId!);

    earnedRewards = List.from(rewardVM.rewards);

    currentLevel = progress.currentLevel;
    score = progress.score;
    retries = Map.from(progress.retries);

    isLoading = false;
    notifyListeners();
  }

  String get currentWord => levels[currentLevel]["word"];
  String get correctAnswer => levels[currentLevel]["correct"];
  List<String> get options =>
      List<String>.from(levels[currentLevel]["options"]);

  Future<void> selectAnswer(String selected) async {
    String levelKey = "Level${currentLevel + 1}";

    if (selected == correctAnswer) {
      feedbackMessage = "Correct! +10 points";
      isCorrect = true;

      score += 10;
      currentLevel++;

      await save();

      if (currentLevel >= levels.length) {
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
        gameId: "Word Match",
        currentLevel: currentLevel,
        score: score,
        totalLevels: 20,
        accuracy: ((score / 100) * 100).clamp(0, 100),
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
      double accuracy = (score / 100).clamp(0, 100);

      String rewardType;

      if (score >= 90 && totalRetries == 0) {
        rewardType = "crown";
      } else if (score >= 70) {
        rewardType = "star";
      } else if (totalRetries <= 2) {
        rewardType = "gem";
      } else {
        rewardType = "candy";
      }

      // Surprise reward for kids
      if (Random().nextInt(5) == 0) {
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
        return "Perfect Match! Golden Crown Earned!";
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

  String getRewardMessage() {
    if (!isCompleted()) return "";

    int totalRetries = getTotalRetries();

    if (score >= 90 && totalRetries == 0) {
      return "Perfect Score!";
    }

    if (score >= 70) return "Great Performance!";
    if (score >= 50) return "Good Job!";
    return "Keep Practicing!";
  }

  Future<void> retryLevel() async {
    feedbackMessage = null;
    notifyListeners();
  }

  bool isCompleted() => currentLevel >= levels.length;

  int getTotalRetries() => retries.values.fold(0, (sum, value) => sum + value);
}
