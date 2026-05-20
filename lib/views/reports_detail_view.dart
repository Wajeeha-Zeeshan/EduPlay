// =========================== progress_report_detail_view.dart ===========================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/progress_report_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class ProgressReportDetailView extends StatefulWidget {
  final String studentId;
  final bool isTeacher;

  const ProgressReportDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
  });

  @override
  State<ProgressReportDetailView> createState() =>
      _ProgressReportDetailViewState();
}

class _ProgressReportDetailViewState extends State<ProgressReportDetailView> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressReportViewModel>().loadReport(widget.studentId);
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressReportViewModel>();

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
          "Progress Report (${widget.studentId})",
          style: const TextStyle(fontWeight: FontWeight.w700, color: kWhite),
        ),
        centerTitle: true,
      ),
      body:
          vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    // Overall Stats Card
                    Container(
                      width: double.infinity,
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
                        children: [
                          const Text(
                            "Overall Performance",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kText,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _buildStatTile(
                            icon: Icons.analytics_rounded,
                            title: "Overall Accuracy",
                            value: "${vm.overallAccuracy}%",
                          ),

                          const SizedBox(height: 18),

                          _buildStatTile(
                            icon: Icons.emoji_events_rounded,
                            title: "Total Score",
                            value: "${vm.totalScore}",
                          ),

                          const SizedBox(height: 18),

                          _buildStatTile(
                            icon: Icons.sports_esports_rounded,
                            title: "Games Played",
                            value: "${vm.gamesPlayed}",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // AI Report Card
                    Container(
                      width: double.infinity,
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
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_awesome,
                                color: kPrimary,
                                size: 26,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "AI Generated Report",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: kText,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          if (vm.report.isEmpty)
                            const Center(
                              child: Text(
                                "No report available yet.",
                                style: TextStyle(fontSize: 16, color: kHint),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildFormattedSections(vm.report),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Teacher Buttons
                    if (widget.isTeacher)
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              label: "Edit",
                              onPressed: () => _showEditDialog(context, vm),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _dangerButton(
                              label: "Delete",
                              onPressed: () => _showDeleteDialog(context, vm),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: kPrimary, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
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

      if (line.endsWith(":")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
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
            padding: const EdgeInsets.only(bottom: 16),
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
                      height: 1.7,
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

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            line,
            style: const TextStyle(fontSize: 16.5, height: 1.7, color: kText),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 2.4),
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

  void _showEditDialog(BuildContext context, ProgressReportViewModel vm) {
    _editController.text = vm.report;

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
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Edit Progress Report",
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
                    maxLines: 18,
                    decoration: InputDecoration(
                      hintText: "Enter report content...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 1.5,
                        ),
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
                              elevation: 4,
                            ),
                            onPressed: () async {
                              final newText = _editController.text.trim();

                              if (newText.isNotEmpty) {
                                await vm.updateReport(newText);

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Progress Report Updated Successfully!",
                                      ),
                                      backgroundColor: kPrimary,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
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

  void _showDeleteDialog(BuildContext context, ProgressReportViewModel vm) {
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Delete Progress Report?",
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
                  "This action cannot be undone.\nAre you sure?",
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
                          onPressed: () async {
                            Navigator.pop(context);

                            await vm.deleteReport(widget.studentId);

                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Progress Report Deleted"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
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
