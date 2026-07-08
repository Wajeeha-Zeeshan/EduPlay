import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart' as models;

enum LoginState { idle, loading, success, error }

enum LoginErrorType { none, email, password, general }

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  LoginState _state = LoginState.idle;
  String _errorMessage = '';
  LoginErrorType _errorType = LoginErrorType.none;
  bool _isLoading = false;
  models.AppUser? _loggedInUser;

  LoginState get state => _state;
  String get errorMessage => _errorMessage;
  LoginErrorType get errorType => _errorType;
  bool get isLoading => _isLoading;
  models.AppUser? get loggedInUser => _loggedInUser;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      _setError("Please fill in all fields.", type: LoginErrorType.general);
      return;
    }
    if (!_isValidEmail(email)) {
      _setError("Invalid email format.", type: LoginErrorType.email);
      return;
    }

    _setState(LoginState.loading);

    try {
      final user = await _userRepository.login(
        email: email,
        password: password,
      );
      _loggedInUser = user;
      _setState(LoginState.success);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('email')) {
        _setError(msg, type: LoginErrorType.email);
      } else if (msg.toLowerCase().contains('password')) {
        _setError(msg, type: LoginErrorType.password);
      } else {
        _setError(
          msg.isEmpty ? "Login failed. Please try again." : msg,
          type: LoginErrorType.general,
        );
      }
    }
  }

  /// **New: Forgot Password**
  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      _setError("Please enter your email.", type: LoginErrorType.email);
      return;
    }
    if (!_isValidEmail(email)) {
      _setError("Invalid email format.", type: LoginErrorType.email);
      return;
    }

    _setState(LoginState.loading);

    try {
      await _userRepository.sendPasswordResetEmail(email);
      _errorMessage = "Password reset link sent to your email.";
      _errorType = LoginErrorType.none; // success message
      _state = LoginState.idle;
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _setError(msg, type: LoginErrorType.email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setState(LoginState s) {
    _state = s;
    _isLoading = s == LoginState.loading;
    notifyListeners();
  }

  void _setError(
    String message, {
    LoginErrorType type = LoginErrorType.general,
  }) {
    _errorMessage = message;
    _errorType = type;
    _state = LoginState.error;
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _state = LoginState.idle;
    _errorMessage = '';
    _errorType = LoginErrorType.none;
    _isLoading = false;
    _loggedInUser = null;
    notifyListeners();
  }
}
