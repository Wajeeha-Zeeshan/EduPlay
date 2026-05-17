import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/learning_path_viewmodel.dart';

const Color kPrimary = Color(0xFFFFB300);

class LearningPathsDetailView extends StatefulWidget {
  final String studentId;
  final bool isTeacher;

  const LearningPathsDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
  });

  @override
  State<LearningPathsDetailView> createState() =>
      _LearningPathsDetailViewState();
}

class _LearningPathsDetailViewState extends State<LearningPathsDetailView> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningPathViewModel>().loadLearningPathWithDoc(
        widget.studentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LearningPathViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Learning Path (${widget.studentId})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions:
            widget.isTeacher
                ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Edit Learning Path",
                    onPressed: () => _showEditDialog(context, viewModel),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),

                    tooltip: "Delete Learning Path",

                    onPressed: () => _showDeleteDialog(context, viewModel),
                  ),
                ]
                : null,
      ),

      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.learningPath == "No learning path found yet." ||
                  viewModel.learningPath.isEmpty
              ? const Center(
                child: Text(
                  "No learning path found yet.\nPlease try again.",

                  textAlign: TextAlign.center,

                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16),

                children: _buildFormattedSections(viewModel.learningPath),
              ),
    );
  }

  List<Widget> _buildFormattedSections(String text) {
    text = text
        .replaceAll("***", "")
        .replaceAll("**", "")
        .replaceAll("*", "")
        .replaceAll("#", "");

    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    final List<Widget> widgets = [];

    for (String line in lines) {
      line = line.trim();

      // SECTION TITLES
      if (line.endsWith(":")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 14),

            child: Text(
              line.replaceAll(":", ""),

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        );

        continue;
      }

      // BULLET ITEMS
      if (line.startsWith("-")) {
        final content = line.replaceFirst("-", "").trim();

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 14),

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),

                  blurRadius: 10,

                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    content,

                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        continue;
      }

      // NORMAL TEXT CARD
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 14),

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),

                blurRadius: 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Text(
            line,

            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  void _showEditDialog(BuildContext context, LearningPathViewModel viewModel) {
    _editController.text = viewModel.learningPath;

    showDialog(
      context: context,

      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Text("Edit Learning Path"),

            content: SizedBox(
              width: double.maxFinite,

              child: TextField(
                controller: _editController,

                maxLines: 20,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(),

                  hintText: "Edit the learning path here...",
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),

                child: const Text("Cancel"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),

                onPressed: () {
                  Navigator.pop(context);

                  if (_editController.text.trim().isNotEmpty) {
                    viewModel.updateLearningPath(_editController.text.trim());

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Learning Path Updated")),
                    );
                  }
                },

                child: const Text("Save Changes"),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LearningPathViewModel viewModel,
  ) {
    showDialog(
      context: context,

      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Text("Delete Learning Path?"),

            content: const Text("This action cannot be undone."),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),

                child: const Text("Cancel"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                onPressed: () {
                  Navigator.pop(context);

                  viewModel.deleteLearningPath(widget.studentId);

                  Navigator.pop(context);
                },

                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }
}
