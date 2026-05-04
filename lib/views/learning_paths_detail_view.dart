import 'package:eduplay/views/register_view.dart';
import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFFFFB300);

class LearningPathsDetailView extends StatelessWidget {
  final String studentId;
  final bool isTeacher;

  const LearningPathsDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> paths = [
      "Alphabet Mastery Path",
      "Vocabulary Building Path",
      "Reading Readiness Path",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: Text("Learning Path ($studentId)"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paths.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.auto_stories, color: kPrimary),
              title: Text(paths[index]),
              subtitle: const Text("AI-generated learning path"),

              trailing:
                  isTeacher
                      ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 10),
                          Icon(Icons.delete, color: Colors.red),
                        ],
                      )
                      : const Icon(Icons.visibility),
            ),
          );
        },
      ),
    );
  }
}
