import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GameRepository {
  List<Game> getGames() {
    return [
      Game(
        id: "abc_recognition",
        title: "ABC Recognition Game",
        description:
            "A letter recognition game where students match uppercase letters with lowercase letters. Improves letter identification skills.",
        icon: Icons.abc,
        type: GameType.abcRecognition,
        totalLevels: 26,
      ),
      Game(
        id: "letter_hunt",
        title: "Letter Hunt",
        description:
            "A sequencing game where students identify the next letter in the alphabetical order. Builds alphabet sequencing skills.",
        icon: Icons.search,
        type: GameType.letterHunt,
        totalLevels: 26,
      ),
      Game(
        id: "word_match",
        title: "Word Match",
        description:
            "A vocabulary game where students match words with correct images. Strengthens word association skills.",
        icon: Icons.image,
        type: GameType.wordMatch,
        totalLevels: 10,
      ),
    ];
  }
}
