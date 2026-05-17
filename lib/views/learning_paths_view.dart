import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/student_repository.dart';
import '../repositories/ai_repository.dart';
import '../viewmodels/learning_path_viewmodel.dart';
import 'learning_paths_detail_view.dart';

const Color kPrimary = Color(0xFFFFB300);
const Color kBg = Color(0xFFE0F7FA);

class LearningPathsPage extends StatelessWidget {
  final bool isTeacher;

  const LearningPathsPage({super.key, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: const Text("Learning Paths"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timeline, size: 70, color: kPrimary),

                  const SizedBox(height: 20),

                  const Text(
                    "Enter Student ID",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "e.g. STU001",
                      filled: true,
                      fillColor: const Color(0xFFF8F1E3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final studentId = controller.text.trim();

                        if (studentId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter Student ID"),
                            ),
                          );
                          return;
                        }

                        try {
                          final repo = StudentRepository();
                          final exists = await repo.studentExists(studentId);

                          if (!exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student not found"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Show Loading Dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          );

                          debugPrint("STARTING AI GENERATION");

                          // Generate Learning Path
                          final aiRepo = AIRepository();
                          await aiRepo.generateLearningPath(studentId);

                          debugPrint("AI GENERATION COMPLETE");

                          // Close loading dialog
                          Navigator.pop(context);

                          // Navigate to Detail Page with Provider
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChangeNotifierProvider(
                                    create: (_) => LearningPathViewModel(),
                                    child: LearningPathsDetailView(
                                      studentId: studentId,
                                      isTeacher: isTeacher,
                                    ),
                                  ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(
                            context,
                          ); // Close loading if error occurs

                          debugPrint("AI ERROR: $e");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("AI Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text("Access Learning Paths"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
