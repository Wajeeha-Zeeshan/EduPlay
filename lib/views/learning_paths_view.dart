import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/student_repository.dart';
import '../repositories/learning_path_repository.dart';
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
  final TextEditingController _controller = TextEditingController();

  bool _isChecking = false;
  bool? _hasExistingPath;
  String? _currentStudentId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkExistingPath(String studentId) async {
    setState(() => _isChecking = true);

    try {
      final aiRepo = AIRepository();
      final latestPath = await aiRepo.getLatestLearningPath(studentId);

      setState(() {
        _hasExistingPath = latestPath != null;
        _currentStudentId = studentId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _generateNewPath(String studentId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final aiRepo = AIRepository();
      await aiRepo.generateLearningPath(studentId);

      if (mounted) {
        Navigator.pop(context);
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
            (context) => ChangeNotifierProvider(
              create: (_) => LearningPathViewModel(),
              child: LearningPathsDetailView(
                studentId: studentId,
                isTeacher: widget.isTeacher,
                // For teachers only - replace with real auth user ID later
                currentUserId: widget.isTeacher ? "current_teacher_id" : null,
              ),
            ),
      ),
    );
  }

  Future<void> _onCheckButtonPressed() async {
    final studentId = _controller.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter Student ID")));
      return;
    }

    final studentRepo = StudentRepository();
    final exists = await studentRepo.studentExists(studentId);

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _checkExistingPath(studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          "Learning Paths",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded, size: 82, color: kPrimary),
                  const SizedBox(height: 24),
                  Text(
                    widget.isTeacher
                        ? "Manage Student Learning Path"
                        : "View Child's Learning Path",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter Student ID (e.g. STU001)",
                      filled: true,
                      fillColor: const Color(0xFFF8F1E3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_search,
                        color: kPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (_isChecking)
                    const CircularProgressIndicator(color: kPrimary)
                  else if (_hasExistingPath == null)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _onCheckButtonPressed,
                        child: const Text(
                          "Check Learning Path",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (_hasExistingPath == true) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              () => _navigateToDetail(_currentStudentId!),
                          child: const Text("View Latest Learning Path"),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary, width: 2.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _generateNewPath(_currentStudentId!),
                          child: const Text("Generate New Version"),
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _generateNewPath(_currentStudentId!),
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
