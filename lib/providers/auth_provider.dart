import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  AuthProvider() {
    _authService.authStateChanges().listen((firebaseUser) {
      user = firebaseUser;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authService.login(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authService.register(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authService.sendPasswordReset(email);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
