import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

enum RegisterState { idle, loading, success, error }

class RegisterViewModel extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  RegisterState _state = RegisterState.idle;
  String _errorMessage = '';
  AppUser? _registeredUser;

  RegisterState get state => _state;
  String get errorMessage => _errorMessage;
  AppUser? get registeredUser => _registeredUser;
  bool get isLoading => _state == RegisterState.loading;

  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String staffID,
  }) async {
    if (password != confirmPassword) {
      _setError('Passwords not matching.');
      return;
    }
    _setState(RegisterState.loading);
    try {
      final teacher = await _repo.createTeacher(
        name: name,
        email: email,
        password: password,
        staffID: staffID,
      );
      _registeredUser = teacher;
      _setState(RegisterState.success);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError('Email already in use.');
      } else if (e.code == 'network-request-failed') {
        _setError('Network issue. Check your connection.');
      } else {
        _setError('Failed to create account.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Staff ID already in use')) {
        _setError('Staff ID already in use.');
      } else if (msg.toLowerCase().contains('network')) {
        _setError('Network issue. Check your connection.');
      } else {
        _setError('Failed to create account.');
      }
    }
  }

  Future<void> registerParent({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String studentID,
  }) async {
    if (password != confirmPassword) {
      _setError('Passwords not matching.');
      return;
    }
    _setState(RegisterState.loading);
    try {
      final parent = await _repo.createParent(
        name: name,
        email: email,
        password: password,
        studentID: studentID,
      );
      _registeredUser = parent;
      _setState(RegisterState.success);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError('Email already in use.');
      } else if (e.code == 'network-request-failed') {
        _setError('Network issue. Check your connection.');
      } else {
        _setError('Failed to create account.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Student ID not found')) {
        _setError('Student ID not found. ');
      } else if (msg.toLowerCase().contains('network')) {
        _setError('Network issue. Check your connection.');
      } else {
        _setError('Failed to create account.');
      }
    }
  }

  void reset() {
    _state = RegisterState.idle;
    _errorMessage = '';
    _registeredUser = null;
    notifyListeners();
  }

  void _setState(RegisterState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = RegisterState.error;
    notifyListeners();
  }
}
