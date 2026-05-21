import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../models/student_model.dart';

import '../repositories/game_repository.dart';
import '../repositories/student_repository.dart';

import '../views/games/abc_game_view.dart';
import '../views/games/letter_hunt_view.dart';
import '../views/games/word__match_game_view.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kWhite = Colors.white;

class GameSelectionPage extends StatefulWidget {
  final String studentId;

  const GameSelectionPage({super.key, required this.studentId});

  @override
  State<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final GameRepository _gameRepo = GameRepository();

  final StudentRepository _studentRepo = StudentRepository();

  late List<Game> games;

  Student? student;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    games = _gameRepo.getGames();

    _loadStudent();
  }

  Future<void> _loadStudent() async {
    student = await _studentRepo.getStudent(widget.studentId);

    setState(() {
      loading = false;
    });
  }

  bool canAccessGame(String gameId) {
    if (student == null) {
      return false;
    }

    if (!student!.initialGameCompleted) {
      return gameId == student!.assignedGame;
    }

    return true;
  }

  void _openGame(Game game) {
    Widget page;

    switch (game.id) {
      case "abc_recognition":
        page = ABCGamePage(studentId: student!.studentID);
        break;

      case "letter_hunt":
        page = LetterHuntPage(studentId: student!.studentID);
        break;

      case "word_match":
        page = WordMatchPage(studentId: student!.studentID);
        break;

      default:
        page = const Scaffold(body: Center(child: Text("Game not found")));
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: kBg,

      appBar: AppBar(
        backgroundColor: kPrimary,
        iconTheme: const IconThemeData(color: kWhite),

        title: Text(
          "Welcome ${student?.name ?? ''}",
          style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: games.length,

        itemBuilder: (context, index) {
          final game = games[index];

          final accessible = canAccessGame(game.id);

          final isAssignedGame = game.id == student?.assignedGame;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: accessible ? kPrimary : Colors.grey.shade400,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Icon(game.icon, color: kWhite, size: 30),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        game.title,

                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  game.description,

                  style: const TextStyle(color: kWhite, height: 1.4),
                ),

                const SizedBox(height: 16),

                if (isAssignedGame && !student!.initialGameCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.orange,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Text(
                      "Assigned Initial Game",

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWhite,

                      foregroundColor: kPrimary,

                      padding: const EdgeInsets.symmetric(vertical: 14),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    onPressed:
                        accessible
                            ? () async {
                              if (!student!.initialGameCompleted &&
                                  game.id == student!.assignedGame) {
                                await _studentRepo.completeInitialGame(
                                  student!.studentID,
                                );

                                await _loadStudent();
                              }

                              _openGame(game);
                            }
                            : null,

                    child: Text(
                      accessible ? "Play Game" : "Locked",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
