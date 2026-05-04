import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../viewmodels/student_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class StudentProfileDetailsView extends StatefulWidget {
  final String studentId;
  const StudentProfileDetailsView({super.key, required this.studentId});

  @override
  State<StudentProfileDetailsView> createState() =>
      _StudentProfileDetailsViewState();
}

class _StudentProfileDetailsViewState extends State<StudentProfileDetailsView> {
  final StudentViewModel _viewModel = StudentViewModel();

  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _classController;
  late TextEditingController _sectionController;

  @override
  void initState() {
    super.initState();
    _viewModel.getStudent(widget.studentId);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _disposeControllers();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {
      if (_viewModel.student != null && !_isEditing) {
        _initializeControllers(_viewModel.student!);
      }
    });
  }

  void _initializeControllers(Student student) {
    _nameController = TextEditingController(text: student.name);
    _ageController = TextEditingController(text: student.age.toString());
    _classController = TextEditingController(text: student.studentClass);
    _sectionController = TextEditingController(text: student.section);
  }

  void _disposeControllers() {
    _nameController.dispose();
    _ageController.dispose();
    _classController.dispose();
    _sectionController.dispose();
  }

  Future<void> _saveChanges() async {
    if (_viewModel.student == null) return;

    final updatedStudent = Student(
      studentID: _viewModel.student!.studentID,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? _viewModel.student!.age,
      studentClass: _classController.text.trim(),
      section: _sectionController.text.trim(),
    );

    try {
      await _viewModel.editStudent(updatedStudent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: kPrimary,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await _showDeleteDialog();

    if (confirm == true) {
      try {
        await _viewModel.deleteStudent(_viewModel.student!.studentID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: kPrimary,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<bool?> _showDeleteDialog() async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Are you sure you want to delete this student?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
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
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Yes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _viewModel.student;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        title: const Text(
          "Student Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: kWhite,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _viewModel.errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _viewModel.errorMessage,
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              )
              : student == null
              ? const Center(
                child: Text(
                  'Student not found.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                child: Column(
                  children: [
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
                          _buildEditableField(
                            label: "Student ID",
                            value: student.studentID,
                            enabled: false,
                          ),
                          const Divider(height: 32),
                          _buildEditableField(
                            label: "Name",
                            controller: _nameController,
                            enabled: _isEditing,
                          ),
                          const Divider(height: 32),
                          _buildEditableField(
                            label: "Age",
                            controller: _ageController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.number,
                          ),
                          const Divider(height: 32),
                          _buildEditableField(
                            label: "Class",
                            controller: _classController,
                            enabled: _isEditing,
                          ),
                          const Divider(height: 32),
                          _buildEditableField(
                            label: "Section",
                            controller: _sectionController,
                            enabled: _isEditing,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: _primaryButton(
                              label: "Save Changes",
                              onPressed: _saveChanges,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _secondaryButton(
                              label: "Cancel",
                              onPressed: () {
                                setState(() => _isEditing = false);
                                _initializeControllers(student); // Reset values
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              label: "Edit Profile",
                              onPressed:
                                  () => setState(() => _isEditing = true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _dangerButton(
                              label: "Delete Student",
                              onPressed: _handleDelete,
                            ),
                          ),
                        ],
                      ),

                    if (_viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          _viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildEditableField({
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: kHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: enabled ? const OutlineInputBorder() : InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 17.5,
            color: kText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kWhite,
          elevation: 6,
          shadowColor: kPrimaryDark.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
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
}
