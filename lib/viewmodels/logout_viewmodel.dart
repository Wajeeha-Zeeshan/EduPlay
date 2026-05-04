import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> logout() async {
    try {
      isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signOut();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to logout. Try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
