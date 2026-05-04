import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/logout_viewmodel.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LogoutViewModel(),
      child: Consumer<LogoutViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: kBg,
            appBar: AppBar(
              backgroundColor: kPrimary,
              elevation: 0,
              title: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w700, color: kWhite),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: kWhite),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body:
                vm.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
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
                              children: [
                                Text(
                                  "Are you sure you want to logout?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: kText,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "You will need to login again to access your account.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    color: kHint,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 70),

                          Row(
                            children: [
                              Expanded(
                                child: _secondaryButton(
                                  label: "Cancel",
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _primaryButton(
                                  label: "Yes, Logout",
                                  onPressed: () async {
                                    final success = await vm.logout();
                                    if (success) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (route) => false,
                                      );
                                    } else if (vm.errorMessage != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(vm.errorMessage!),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      vm.clearError();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          if (vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                vm.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
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
}
