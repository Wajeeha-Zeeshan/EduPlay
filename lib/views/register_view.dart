import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 0;
  String _role = 'Teacher';

  final _step0FormKey = GlobalKey<FormState>();
  final _step1FormKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _idCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _emailError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: kHint, fontSize: 15.5),
    filled: true,
    fillColor: kWhite,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: kPrimary, width: 2.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
  );

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
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
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    color: kWhite,
                    strokeWidth: 3.5,
                  ),
                )
                : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
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

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children:
            ['Teacher', 'Parent'].map((role) {
              final isSelected = _role == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _role = role),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? kWhite : kText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 15.5, color: kText.withOpacity(0.75)),
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Login",
                style: TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: kBg,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: kPrimary,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (_step > 0) {
                          setState(() => _step--);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    if (_step != 2)
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo1.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 31,
                                fontWeight: FontWeight.bold,
                                color: kText,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Join the EduPlay learning community",
                              style: TextStyle(
                                fontSize: 16.5,
                                color: kText.withOpacity(0.78),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_step != 2) const SizedBox(height: 40),

                    if (_step == 0) _buildStep0(vm),
                    if (_step == 1) _buildStep1(vm),
                    if (_step == 2) _buildStep2(context),

                    if (_step != 2) ...[
                      const SizedBox(height: 15),
                      _buildLoginLink(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep0(RegisterViewModel vm) {
    return Form(
      key: _step0FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: _fieldDecor("Full Name"),
            validator:
                (v) => (v?.trim().isEmpty ?? true) ? "Name is required" : null,
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecor(
              "Email Address",
            ).copyWith(errorText: _emailError),
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Email is required";
              if (!v.contains('@')) return "Enter a valid email";
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: _fieldDecor("Password").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: kHint,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator:
                (v) =>
                    v != null && v.length >= 6 ? null : "Minimum 6 characters",
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: _fieldDecor("Confirm Password").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: kHint,
                ),
                onPressed:
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v != _passwordCtrl.text) return "Passwords do not match";
              return null;
            },
          ),
          const SizedBox(height: 14),

          const Text(
            "Select your role",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleSelector(),

          const SizedBox(height: 15),

          _primaryButton(
            label: "Continue",
            onPressed: () {
              if (_step0FormKey.currentState!.validate()) {
                setState(() => _step = 1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(RegisterViewModel vm) {
    final bool isTeacher = _role == 'Teacher';

    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Verification",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTeacher
                ? "Please enter your Staff ID"
                : "Please enter your Child's Student ID",
            style: TextStyle(
              fontSize: 16.5,
              color: kText.withOpacity(0.78),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _idCtrl,
            decoration: _fieldDecor(
              isTeacher ? "Staff ID" : "Student ID",
            ).copyWith(
              errorText:
                  (vm.state == RegisterState.error &&
                          !vm.errorMessage.toLowerCase().contains("email"))
                      ? vm.errorMessage
                      : null,
            ),
            validator:
                (v) =>
                    (v?.trim().isEmpty ?? true)
                        ? "${isTeacher ? 'Staff' : 'Student'} ID is required"
                        : null,
          ),

          const SizedBox(height: 48),

          _primaryButton(
            label: "Complete Registration",
            isLoading: vm.isLoading,
            onPressed: () async {
              if (!_step1FormKey.currentState!.validate()) return;

              if (vm.state == RegisterState.error) vm.reset();

              if (isTeacher) {
                await vm.registerTeacher(
                  name: _nameCtrl.text.trim(),
                  email: _emailCtrl.text.trim(),
                  password: _passwordCtrl.text,
                  confirmPassword: _confirmCtrl.text,
                  staffID: _idCtrl.text.trim(),
                );
              } else {
                await vm.registerParent(
                  name: _nameCtrl.text.trim(),
                  email: _emailCtrl.text.trim(),
                  password: _passwordCtrl.text,
                  confirmPassword: _confirmCtrl.text,
                  studentID: _idCtrl.text.trim(),
                );
              }

              if (vm.state == RegisterState.success) {
                setState(() => _step = 2);
              } else if (vm.state == RegisterState.error) {
                if (vm.errorMessage!.toLowerCase().contains("email")) {
                  setState(() {
                    _emailError = vm.errorMessage;
                    _step = 0;
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _secondaryButton(
            label: "Back",
            onPressed: () => setState(() => _step = 0),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 90),

          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, double scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
          ),
          const SizedBox(height: 48),

          Text(
            "Welcome to EduPlay!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: kText,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPrimary.withOpacity(0.3), width: 1.5),
            ),
            child: Text(
              "Your account has been created successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kText.withOpacity(0.85),
              ),
            ),
          ),
          const SizedBox(height: 80),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kWhite,
                      elevation: 6,
                      shadowColor: kPrimaryDark.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      "Login Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary, width: 2.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
