import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../viewmodels/student_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
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
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {
      if (_viewModel.student != null) {
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
                child: Container(
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
                      _buildField("Student ID", student.studentID),
                      const Divider(height: 32),
                      _buildField("Name", student.name),
                      const Divider(height: 32),
                      _buildField("Age", student.age.toString()),
                      const Divider(height: 32),
                      _buildField("Class", student.studentClass),
                      const Divider(height: 32),
                      _buildField("Section", student.section),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: kHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17.5,
            color: kText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
