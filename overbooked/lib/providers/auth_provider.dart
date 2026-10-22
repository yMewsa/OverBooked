import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Manages authentication state and exposes it to the widget tree via Provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    // Listen to Firebase auth state changes and rebuild UI accordingly.
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  /// Sets [errorMessage] on failure.
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new account with email and password.
  /// Sets [errorMessage] on failure.
  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Clears any stored error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
