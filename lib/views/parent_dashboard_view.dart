import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import '../models/parent_model.dart';

import 'profile_view.dart';
import '../views/learning_activities_view.dart';
import 'student_profile_parent_view.dart';

import 'learning_paths_detail_view.dart';
import '../viewmodels/learning_path_viewmodel.dart';
import 'reports_detail_view.dart';
import '../viewmodels/progress_report_viewmodel.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

  Future<AppUser?> _loadCurrentUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final repo = UserRepository();
      return await repo.getUser(firebaseUser.uid);
    } catch (e) {
      debugPrint('Error loading current user: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB300),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                final user = await _loadCurrentUser();
                if (user == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileView(user: user)),
                );
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFFFFB300), size: 28),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: FutureBuilder<AppUser?>(
            future: _loadCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(color: Color(0xFFFFB300)),
                  ),
                );
              }

              final parent = snapshot.data;
              final parentUser = parent is Parent ? parent : null;

              final displayName = parentUser?.name ?? 'Parent';
              final studentId = parentUser?.studentID ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(displayName),
                  const SizedBox(height: 50),

                  // Child Profile
                  _buildMenuCard(
                    title: 'Child Profile',
                    description: 'View your child\'s details',
                    icon: Icons.child_care,
                    iconColor: const Color(0xFF00ACC1),
                    onTap: () {
                      if (studentId.isEmpty) {
                        _showSnackBar(
                          context,
                          "No student linked to this account",
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => StudentProfileDetailsView(
                                studentId: studentId,
                              ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Learning Activities
                  _buildMenuCard(
                    title: 'Learning Activities',
                    description: 'View educational games',
                    icon: Icons.sports_esports,
                    iconColor: const Color(0xFF42A5F5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const LearningActivitiesPage(
                                isTeacher: false,
                              ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // LEARNING PATHS
                  _buildMenuCard(
                    title: 'Learning Paths',
                    description: 'View learning journey & recommendations',
                    icon: Icons.timeline,
                    iconColor: const Color(0xFFE53935),
                    onTap: () {
                      if (studentId.isEmpty) {
                        _showSnackBar(
                          context,
                          "No student linked to this account",
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider(
                                create: (_) => LearningPathViewModel(),
                                child: LearningPathsDetailView(
                                  studentId: studentId,
                                  isTeacher: false,
                                  currentUserId: null,
                                ),
                              ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // PROGRESS REPORTS
                  _buildMenuCard(
                    title: 'Progress Reports',
                    description: 'View detailed AI progress reports',
                    icon: Icons.menu_book,
                    iconColor: const Color(0xFF43A047),
                    onTap: () {
                      if (studentId.isEmpty) {
                        _showSnackBar(
                          context,
                          "No student linked to this account",
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider(
                                create: (_) => ProgressReportViewModel(),
                                child: ProgressReportDetailView(
                                  studentId: studentId,
                                  isTeacher: false,
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildWelcomeCard(String displayName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Stay updated with your child's learning journey",
            style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300), // Same as AppBar
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Stack(
            children: [
              // Dark overlay for better white text contrast
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 19.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 34),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
