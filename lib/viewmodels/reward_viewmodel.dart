import 'dart:math';
import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardRepository _repo = RewardRepository();

  List<Reward> rewards = [];

  Future<void> loadRewards(String studentId) async {
    rewards = await _repo.getRewards(studentId);
    notifyListeners();
  }

  Future<void> giveReward(String studentId, String type) async {
    try {
      final reward = _createReward(type);

      await _repo.addReward(studentId, reward);

      rewards.insert(0, reward);

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to add reward");
    }
  }

  Reward _createReward(String type) {
    switch (type) {
      case 'star':
        return Reward(
          id: _generateId(),
          type: 'star',
          name: 'Magic Star',
          value: 5,
          earnedAt: DateTime.now(),
        );

      case 'crown':
        return Reward(
          id: _generateId(),
          type: 'crown',
          name: 'Golden Crown',
          value: 1,
          earnedAt: DateTime.now(),
        );

      case 'gem':
        return Reward(
          id: _generateId(),
          type: 'gem',
          name: 'Rainbow Gem',
          value: 3,
          earnedAt: DateTime.now(),
        );

      case 'sticker':
        return Reward(
          id: _generateId(),
          type: 'sticker',
          name: 'Animal Sticker',
          value: 1,
          earnedAt: DateTime.now(),
        );

      default:
        return Reward(
          id: _generateId(),
          type: 'candy',
          name: 'Candy Coin',
          value: 10,
          earnedAt: DateTime.now(),
        );
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
  }

  List<Reward> getRewardsByType(String type) {
    return rewards.where((reward) => reward.type == type).toList();
  }

  int getTotalCandy() {
    return rewards
        .where((reward) => reward.type == 'candy')
        .fold(0, (sum, reward) => sum + reward.value);
  }

  int getTotalStars() {
    return rewards.where((reward) => reward.type == 'star').length;
  }

  int getTotalCrowns() {
    return rewards.where((reward) => reward.type == 'crown').length;
  }

  int getTotalGems() {
    return rewards.where((reward) => reward.type == 'gem').length;
  }

  int getTotalStickers() {
    return rewards.where((reward) => reward.type == 'sticker').length;
  }
}
