import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/learning_path_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

/// Fully rewritten LearningPathsDetailView with proper approval system
class LearningPathsDetailView extends StatefulWidget {
  final String studentId;
  final bool isTeacher;
  final String? currentUserId; // Used for teacher approval tracking

  const LearningPathsDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
    this.currentUserId,
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
      context.read<LearningPathViewModel>().loadLearningPath(widget.studentId);
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LearningPathViewModel>();

    // Parent Access Control: Show pending message if not approved
    if (!widget.isTeacher && !viewModel.isApproved) {
      return Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kWhite),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Learning Path (${widget.studentId})",
            style: const TextStyle(fontWeight: FontWeight.w700, color: kWhite),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Learning path is pending teacher approval.\n\nPlease check back later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: kHint, height: 1.6),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Learning Path (${widget.studentId})",
          style: const TextStyle(fontWeight: FontWeight.w700, color: kWhite),
        ),
        centerTitle: true,
      ),
      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : viewModel.learningPath == "No learning path found yet." ||
                  viewModel.learningPath.isEmpty
              ? const Center(
                child: Text(
                  "No learning path found yet.\nPlease generate one from teacher panel.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.5, color: kHint),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    // Main Content Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildFormattedSections(
                          viewModel.learningPath,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Teacher Action Buttons
                    if (widget.isTeacher)
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              label:
                                  viewModel.isApproved
                                      ? "Approved ✓"
                                      : "Approve",
                              color:
                                  viewModel.isApproved
                                      ? Colors.green
                                      : kPrimary,
                              onPressed:
                                  viewModel.isApproved
                                      ? null
                                      : () => _approvePath(context, viewModel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _secondaryButton(
                              label: "Edit",
                              onPressed:
                                  () => _showEditDialog(context, viewModel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dangerButton(
                              label: "Delete",
                              onPressed:
                                  () => _showDeleteDialog(context, viewModel),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }

  // NEW: Approve Path Method
  void _approvePath(
    BuildContext context,
    LearningPathViewModel viewModel,
  ) async {
    if (widget.currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID not available")));
      return;
    }

    await viewModel.approvePath(widget.currentUserId!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Learning Path Approved for Parent"),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Widget> _buildFormattedSections(String text) {
    // Clean markdown symbols
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

      if (line.endsWith(":")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 12),
            child: Text(
              line.replaceAll(":", ""),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kText,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.startsWith("-")) {
        final content = line.replaceFirst("-", "").trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: kPrimary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16.5,
                      height: 1.65,
                      color: kText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Normal text
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            line,
            style: const TextStyle(fontSize: 16.5, height: 1.65, color: kText),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? kPrimary;
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _dangerButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 2.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, LearningPathViewModel viewModel) {
    _editController.text = viewModel.learningPath;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Edit Learning Path",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _editController,
                    maxLines: 16,
                    decoration: InputDecoration(
                      hintText: "Edit learning path content here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kPrimary, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimary,
                              side: const BorderSide(color: kPrimary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              final newText = _editController.text.trim();
                              if (newText.isNotEmpty) {
                                viewModel.updateLearningPath(newText);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Learning Path Updated Successfully!",
                                    ),
                                    backgroundColor: kPrimary,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
            backgroundColor: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Delete Learning Path?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "This action cannot be undone.\nAre you sure you want to delete?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: kWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            viewModel.deleteLearningPath(widget.studentId);
                            Navigator.pop(
                              context,
                            ); // Go back to previous screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Learning Path Deleted"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(fontWeight: FontWeight.w700),
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
  }
}
