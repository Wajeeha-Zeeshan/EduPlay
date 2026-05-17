import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/student_repository.dart';
import '../repositories/ai_repository.dart';
import '../viewmodels/learning_path_viewmodel.dart';
import 'learning_paths_detail_view.dart';

const Color kPrimary = Color(0xFFFFB300);
const Color kBg = Color(0xFFE0F7FA);

class LearningPathsPage extends StatefulWidget {
  final bool isTeacher;
  const LearningPathsPage({super.key, required this.isTeacher});

  @override
  State<LearningPathsPage> createState() => _LearningPathsPageState();
}

class _LearningPathsPageState extends State<LearningPathsPage> {
  final TextEditingController controller = TextEditingController();
  bool isChecking = false;
  bool? hasExistingPath;
  String? currentStudentId;

  Future<void> checkExistingPath(String studentId) async {
    setState(() => isChecking = true);

    try {
      final aiRepo = AIRepository();
      final data = await aiRepo.getLatestLearningPathWithDocId(studentId);

      setState(() {
        hasExistingPath = data != null;
        currentStudentId = studentId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking path: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isChecking = false);
    }
  }

  Future<void> generateNewPath(String studentId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final aiRepo = AIRepository();
      await aiRepo.generateLearningPath(studentId);

      if (mounted) {
        Navigator.pop(context); // close loader
        _navigateToDetail(studentId);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDetail(String studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create: (_) => LearningPathViewModel(),
              child: LearningPathsDetailView(
                studentId: studentId,
                isTeacher: widget.isTeacher,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                  const SizedBox(height: 24),

                  if (isChecking)
                    const CircularProgressIndicator()
                  else if (hasExistingPath == null)
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

                          await checkExistingPath(studentId);
                        },
                        child: const Text("Check Learning Path"),
                      ),
                    )
                  else ...[
                    if (hasExistingPath == true) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _navigateToDetail(currentStudentId!),
                          child: const Text("View Latest Learning Path"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => generateNewPath(currentStudentId!),
                          child: const Text("Generate New Version"),
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => generateNewPath(currentStudentId!),
                          child: const Text("Generate Learning Path"),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
