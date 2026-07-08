import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/progress_report_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class ProgressReportDetailView extends StatefulWidget {
  final String studentId;
  final bool isTeacher;
  final String? currentUserId;

  const ProgressReportDetailView({
    super.key,
    required this.studentId,
    required this.isTeacher,
    this.currentUserId,
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

    // Parent Access Control
    if (!widget.isTeacher && !vm.isApproved) {
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
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Progress Report is pending teacher approval.\n\nPlease check back later.",
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
                    // Overall Performance Stats
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
                            Icons.analytics_rounded,
                            "Overall Accuracy",
                            "${vm.overallAccuracy}%",
                          ),
                          const SizedBox(height: 18),
                          _buildStatTile(
                            Icons.emoji_events_rounded,
                            "Total Score",
                            "${vm.totalScore}",
                          ),
                          const SizedBox(height: 18),
                          _buildStatTile(
                            Icons.sports_esports_rounded,
                            "Games Played",
                            "${vm.gamesPlayed}",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // AI Report Content
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
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_awesome,
                                color: kPrimary,
                                size: 26,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "AI Generated Report",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (vm.report.isEmpty ||
                              vm.report == "No report found.")
                            const Center(
                              child: Text(
                                "No report available yet.",
                                style: TextStyle(fontSize: 16, color: kHint),
                              ),
                            )
                          else
                            Column(
                              children: _buildFormattedSections(vm.report),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Teacher Controls
                    if (widget.isTeacher)
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              vm.isApproved ? "Approved" : "Approve",
                              vm.isApproved
                                  ? null
                                  : () => _showApproveDialog(context, vm),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _secondaryButton(
                              "Edit",
                              () => _showEditDialog(context, vm),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dangerButton(
                              "Delete",
                              () => _showDeleteDialog(context, vm),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }

  void _showApproveDialog(BuildContext context, ProgressReportViewModel vm) {
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
                    "Approve Progress Report?",
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
                  "This will make the progress report visible to the parent.\n\nAre you sure?",
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
                            backgroundColor: kPrimary,
                            foregroundColor: kWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _approveReport(context, vm);
                          },
                          child: const Text(
                            "Approve",
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
  // ==================== HELPER METHODS ====================

  Widget _buildStatTile(IconData icon, String title, String value) {
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

  Widget _secondaryButton(
    String label,
    VoidCallback? onPressed, {
    Color? color,
  }) {
    final buttonColor = color ?? kPrimary;

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _dangerButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 2.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  void _approveReport(BuildContext context, ProgressReportViewModel vm) async {
    if (widget.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teacher ID not available"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (vm.currentDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Document ID not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await vm.approveReport(widget.currentUserId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Progress Report Approved for Parent"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Approve failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                    maxLines: 16,
                    decoration: InputDecoration(
                      hintText: "Edit report content here...",
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
                              final newText = _editController.text.trim();
                              if (newText.isNotEmpty) {
                                vm.updateReport(newText);
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                          onPressed: () {
                            Navigator.pop(context);
                            vm.deleteReport(widget.studentId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Progress Report Deleted"),
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
