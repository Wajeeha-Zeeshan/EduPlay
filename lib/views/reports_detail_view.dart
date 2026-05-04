import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFFFFB300);

class ReportsDetailView extends StatelessWidget {
  final String studentId;
  final bool isTeacher;

  const ReportsDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reports = [
      {
        "title": "Alphabet Recognition",
        "summary": "Good progress in identifying letters",
      },
      {
        "title": "Word Matching",
        "summary": "Needs improvement in vocabulary skills",
      },
      {
        "title": "Reading Skills",
        "summary": "Steady improvement in reading fluency",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: Text("Reports ($studentId)"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.insights, color: kPrimary),
              title: Text(report["title"]!),
              subtitle: Text(report["summary"]!),

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
