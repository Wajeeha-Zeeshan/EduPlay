import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/teacher_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'logout_view.dart';
import 'home_view.dart';

const Color kBg = Color(0xFFFFF4D4);
const Color kPrimary = Color(0xFFFFB300);
const Color kPrimaryDark = Color(0xFFFB8C00);
const Color kText = Color(0xFF2C3E50);
const Color kHint = Color(0xFF757575);
const Color kWhite = Colors.white;

class ProfileView extends StatelessWidget {
  final AppUser user;
  const ProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(user: user),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final bool isTeacher = vm.user is Teacher;
          final nameController = TextEditingController(text: vm.user.name);
          final emailController = TextEditingController(text: vm.user.email);
          final idController = TextEditingController(
            text: isTeacher ? (vm.user as Teacher).staffID : "",
          );

          return Scaffold(
            backgroundColor: kBg,
            appBar: AppBar(
              backgroundColor: kPrimary,
              elevation: 0,
              title: const Text(
                "Profile",
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
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kWhite,
                                border: Border.all(color: kPrimary, width: 5),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 68,
                                color: kHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
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
                                  label: "Name",
                                  controller: nameController,
                                  enabled: vm.isEditing,
                                ),
                                const Divider(height: 32),
                                _buildEditableField(
                                  label: "Email",
                                  controller: emailController,
                                  enabled: vm.isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const Divider(height: 32),
                                if (isTeacher)
                                  _buildEditableField(
                                    label: "Staff ID",
                                    controller: idController,
                                    enabled: vm.isEditing,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          if (vm.isEditing)
                            Row(
                              children: [
                                Expanded(
                                  child: _primaryButton(
                                    label: "Save Changes",
                                    onPressed: () async {
                                      await vm.updateProfile(
                                        name: nameController.text,
                                        email: emailController.text,
                                        staffID:
                                            isTeacher
                                                ? idController.text
                                                : null,
                                      );
                                      if (vm.errorMessage == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Profile updated successfully!",
                                            ),
                                            backgroundColor: kPrimary,
                                          ),
                                        );
                                        vm.toggleEditing();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _secondaryButton(
                                    label: "Cancel",
                                    onPressed: () {
                                      vm.toggleEditing();
                                      vm.clearError();
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
                                    onPressed: vm.toggleEditing,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _dangerButton(
                                    label: "Delete Profile",
                                    onPressed:
                                        () => _showDeleteDialog(context, vm),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 30),
                          if (!vm.isEditing)
                            _primaryButton(
                              label: "Logout",
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LogoutView(),
                                    ),
                                  ),
                            ),
                          if (vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                vm.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
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

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
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

  void _showDeleteDialog(BuildContext context, ProfileViewModel vm) async {
    final confirm = await showDialog<bool>(
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
                    "Are you sure you want to delete profile?",
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

    if (confirm == true) {
      await vm.deleteProfile();
      if (vm.errorMessage == null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
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
                        "Profile Deleted",
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
                      "Your profile was deleted successfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "OK",
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
        );
      }
    }
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 58,
      width: double.infinity,
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
