import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GameRepository {
  List<Game> getGames() {
    return [
      Game(
        id: "abc_recognition",

        title: "ABC Recognition Game",

        description:
            "A fun letter recognition activity where students match uppercase letters with lowercase letters. This game helps preschool students improve alphabet recognition, visual identification, and early reading skills.",

        icon: Icons.abc,

        type: GameType.abcRecognition,

        totalLevels: 26,
      ),

      Game(
        id: "letter_hunt",

        title: "Letter Hunt",

        description:
            "An interactive sequencing game where students identify the next letter in the alphabetical order. This activity strengthens alphabet sequencing, memory, and letter recognition abilities.",

        icon: Icons.search,

        type: GameType.letterHunt,

        totalLevels: 26,
      ),

      Game(
        id: "word_match",

        title: "Word Match",

        description:
            "An engaging vocabulary game where students match words with the correct images. This game supports vocabulary development, word association, and visual learning skills for preschool learners.",

        icon: Icons.image,

        type: GameType.wordMatch,

        totalLevels: 10,
      ),
    ];
  }
}
