// =========================== game_model.dart ===========================

import 'package:flutter/material.dart';

enum GameType { abcRecognition, letterHunt, wordMatch }

class Game {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final GameType type;
  final int totalLevels;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.totalLevels,
  });
}
