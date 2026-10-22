import 'package:firebase_auth/firebase_auth.dart';

/// Handles all Firebase Authentication operations.
/// This is a plain service class (not a ChangeNotifier).
/// State observation is handled by [AuthProvider].
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream that emits the current user on auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Signs in with email and password.
  /// Throws a localized [Exception] on failure.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// Creates a new account with email and password.
  /// Throws a localized [Exception] on failure.
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// Signs the current user out.
  Future<void> signOut() => _auth.signOut();

  /// Maps Firebase error codes to Portuguese user-facing messages.
  String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'Senha incorreta. Verifique e tente novamente.',
        'user-not-found' => 'Nenhuma conta encontrada com este e-mail.',
        'email-already-in-use' =>
          'Este e-mail já está cadastrado. Faça login.',
        'weak-password' => 'Senha muito fraca. Use pelo menos 6 caracteres.',
        'invalid-email' => 'Endereço de e-mail inválido.',
        'network-request-failed' =>
          'Sem conexão com a internet. Verifique sua rede.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um momento e tente de novo.',
        _ => 'Ocorreu um erro inesperado. Tente novamente.',
      };
}
