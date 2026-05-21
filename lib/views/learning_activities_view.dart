import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../repositories/game_repository.dart';
import '../repositories/student_repository.dart';

const Color kBg = Color(0xFFE0F7FA);
const Color kPrimary = Color(0xFFFFB300);
const Color kWhite = Colors.white;

class LearningActivitiesPage extends StatefulWidget {
  final bool isTeacher;

  const LearningActivitiesPage({super.key, required this.isTeacher});

  @override
  State<LearningActivitiesPage> createState() => _LearningActivitiesPageState();
}

class _LearningActivitiesPageState extends State<LearningActivitiesPage> {
  final GameRepository _repo = GameRepository();

  late List<Game> games;

  int? expandedIndex;

  @override
  void initState() {
    super.initState();

    games = _repo.getGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,

      appBar: AppBar(
        backgroundColor: kPrimary,
        iconTheme: const IconThemeData(color: kWhite),

        elevation: 0,

        title: const Text(
          "Learning Activities",

          style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: games.length,

        itemBuilder: (context, index) {
          final game = games[index];

          final isExpanded = expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, Color(0xFFFFD54F)],

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
                      // ==========================
                      // HEADER
                      // ==========================
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
                                  "Tap to ${isExpanded ? "hide" : "view"} details",

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

                      // ==========================
                      // EXPANDED CONTENT
                      // ==========================
                      if (isExpanded) ...[
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(20),

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
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              if (widget.isTeacher)
                                SizedBox(
                                  width: double.infinity,

                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,

                                      foregroundColor: kWhite,

                                      elevation: 3,

                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),

                                    onPressed: () {
                                      _assignGame(game);
                                    },

                                    child: const Text(
                                      "Assign Initial Game",

                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
    );
  }

  // ==========================
  // ASSIGN GAME DIALOG
  // ==========================

  void _assignGame(Game game) {
    final TextEditingController studentIdController = TextEditingController();

    final StudentRepository repo = StudentRepository();

    showDialog(
      context: context,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: kWhite,

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==========================
                // HEADER
                // ==========================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.15),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Icon(game.icon, color: kPrimary, size: 28),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Text(
                        "Assign Initial Game",

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==========================
                // GAME TITLE
                // ==========================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: kBg,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Text(
                    game.title,

                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================
                // LABEL
                // ==========================
                const Text(
                  "Enter Student ID",

                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================
                // TEXTFIELD
                // ==========================
                TextField(
                  controller: studentIdController,

                  decoration: InputDecoration(
                    hintText: "e.g. STU001",

                    filled: true,

                    fillColor: Colors.grey.shade100,

                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: kPrimary,
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(color: kPrimary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==========================
                // BUTTONS
                // ==========================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,

                          side: BorderSide(color: Colors.grey.shade400),

                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: const Text(
                          "Cancel",

                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,

                          foregroundColor: kWhite,

                          elevation: 3,

                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () async {
                          final studentId = studentIdController.text.trim();

                          if (studentId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter Student ID"),
                              ),
                            );

                            return;
                          }

                          final exists = await repo.studentExists(studentId);

                          if (!exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student ID not found"),
                              ),
                            );

                            return;
                          }

                          await repo.assignInitialGame(
                            studentId: studentId,

                            gameId: game.id,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,

                              behavior: SnackBarBehavior.floating,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),

                              content: Text(
                                "${game.title} assigned to $studentId",
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "Assign",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
