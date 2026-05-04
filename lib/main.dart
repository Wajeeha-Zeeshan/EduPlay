import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/home_view.dart';
import 'views/register_view.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart';
import 'views/teacher_dashboard_view.dart';
import 'views/parent_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardView(),
        '/login': (context) => const LoginPage(),
        '/teacher-dashboard': (context) => TeacherDashboardPage(),
        '/parent-dashboard': (context) => ParentDashboardPage(),
      },
    );
  }
}
