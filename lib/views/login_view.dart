import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    return Expanded(
      child: SizedBox(
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
      ),
    );
  }

  void _handleLogin(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    vm.reset();
    await vm.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (vm.state == LoginState.success) {
      final user = vm.loggedInUser;
      if (user?.role == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
      } else if (user?.role == 'parent') {
        Navigator.pushReplacementNamed(context, '/parent-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else if (vm.state == LoginState.error && vm.errorMessage.isNotEmpty) {
      if (vm.errorType == LoginErrorType.email) {
        setState(() => _emailError = vm.errorMessage);
      } else if (vm.errorType == LoginErrorType.password) {
        setState(() => _passwordError = vm.errorMessage);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
      }
    }
  }

  // ==================== THEMED FORGOT PASSWORD DIALOG ====================
  void _handleForgotPassword(LoginViewModel vm) async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }

    final shouldSend = await showDialog<bool>(
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
                // Header with primary color
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Reset Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "A password reset link will be sent to your registered email address.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5, color: kText),
                ),

                const SizedBox(height: 32),

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
                          onPressed: () => Navigator.pop(context, false),
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
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Send Link",
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

    if (shouldSend == true) {
      await vm.forgotPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage),
            backgroundColor:
                vm.errorType == LoginErrorType.none ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: kBg,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo1.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 31,
                                fontWeight: FontWeight.bold,
                                color: kText,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Login to continue to EduPlay",
                              style: TextStyle(
                                fontSize: 16.5,
                                color: kText.withOpacity(0.78),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecor(
                          "Email Address",
                        ).copyWith(errorText: _emailError),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "Email is required"
                                    : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _fieldDecor("Password").copyWith(
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: kHint,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _handleForgotPassword(vm),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [
                          _primaryButton(
                            label: "Login",
                            isLoading: vm.isLoading,
                            onPressed: () => _handleLogin(vm),
                          ),
                          const SizedBox(width: 16),
                          _primaryButton(
                            label: "Cancel",
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/',
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              ),
                          child: Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: kPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
