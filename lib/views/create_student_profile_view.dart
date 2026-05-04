import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../viewmodels/student_viewmodel.dart';

class CreateStudentProfileView extends StatefulWidget {
  const CreateStudentProfileView({super.key});

  @override
  State<CreateStudentProfileView> createState() =>
      _CreateStudentProfileViewState();
}

class _CreateStudentProfileViewState extends State<CreateStudentProfileView> {
  final StudentViewModel vm = StudentViewModel();

  final _formKey = GlobalKey<FormState>();
  final studentIDController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final classController = TextEditingController();
  final sectionController = TextEditingController();

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      studentID: studentIDController.text.trim(),
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      studentClass: classController.text.trim(),
      section: sectionController.text.trim(),
    );

    try {
      await vm.createStudent(student);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFFF4D4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFD180), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFB300), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB300),
        elevation: 0,
        title: const Text(
          'Create Student',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Student Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: studentIDController,
                  decoration: _inputDecoration('Student ID'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration('Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: ageController,
                  decoration: _inputDecoration('Age'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: classController,
                  decoration: _inputDecoration('Class'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: sectionController,
                  decoration: _inputDecoration('Section'),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: submitForm,
                    child: const Text('Create Student'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
