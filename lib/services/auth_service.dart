import 'package:flutter/foundation.dart';
import '../domain/user.dart';
import 'firebase_auth_service.dart';

/// AuthService legacy - Ahora usa Firebase Authentication
/// Mantenido para compatibilidad con código existente
@Deprecated('Use FirebaseAuthService and AuthNotifier instead')
class AuthService extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService;
  
  AuthService(this._firebaseAuthService);

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Sign in con correo electrónico y contraseña
  Future<bool> signIn(String email, String password) async {
    try {
      final user = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _currentUser = user;
      notifyListeners();
      return user != null;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  /// Sign in con Google
  Future<bool> signInWithGoogle() async {
    try {
      final user = await _firebaseAuthService.signInWithGoogle();
      _currentUser = user;
      notifyListeners();
      return user != null;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
