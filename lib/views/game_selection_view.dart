import 'package:flutter/material.dart';
import '../repositories/game_repository.dart';
import '../models/game_model.dart';

import '../views/games/abc_game_view.dart';
import '../views/games/letter_hunt_view.dart';
import '../views/games/word__match_game_view.dart';

const Color kBg = Color(0xFFE0F7FA);
const Color kPrimary = Color(0xFFFFB300);
const Color kWhite = Colors.white;

class GameSelectionPage extends StatefulWidget {
  final String studentId;

  const GameSelectionPage({super.key, required this.studentId});

  @override
  State<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final GameRepository _repo = GameRepository();
  late List<Game> games;

  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    games = _repo.getGames();
  }

  void _openGame(Game game) {
    Widget page;

    switch (game.type) {
      case GameType.abcRecognition:
        page = ABCGamePage(studentId: widget.studentId);
        break;
      case GameType.letterHunt:
        page = LetterHuntPage(studentId: widget.studentId);
        break;
      case GameType.wordMatch:
        page = WordMatchPage(studentId: widget.studentId);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhite),
        title: const Text(
          "Choose a Game",
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final isExpanded = expandedIndex == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFFFFD74F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      expandedIndex = isExpanded ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(game.icon, color: kPrimary, size: 28),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: kWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tap to ${isExpanded ? "hide" : "play"} details",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kWhite.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: kWhite,
                              size: 28,
                            ),
                          ],
                        ),

                        // EXPANDED SECTION
                        if (isExpanded) ...[
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimary,
                                          foregroundColor: kWhite,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => _openGame(game),
                                        child: const Text(
                                          "Play Now",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
