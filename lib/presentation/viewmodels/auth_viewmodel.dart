import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user.dart';
import '../../services/firebase_auth_service.dart';

enum AuthState {
  initial,
  authenticating,
  authenticated,
  error,
}

class AuthStatus {
  final AuthState state;
  final User? user;
  final String? errorMessage;

  const AuthStatus({
    this.state = AuthState.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => state == AuthState.authenticated && user != null;
  bool get isAuthenticating => state == AuthState.authenticating;

  AuthStatus copyWith({
    AuthState? state,
    User? user,
    String? errorMessage,
  }) {
    return AuthStatus(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider del servicio de Firebase Auth
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    return const AuthStatus();
  }

  /// Iniciar sesión con correo y contraseña
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(state: AuthState.authenticating);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (user != null) {
        state = AuthStatus(state: AuthState.authenticated, user: user);
        return true;
      } else {
        state = const AuthStatus(
          state: AuthState.error,
          errorMessage: 'Usuario o contraseña incorrectos',
        );
        return false;
      }
    } catch (e) {
      state = AuthStatus(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(state: AuthState.authenticating);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithGoogle();
      if (user != null) {
        state = AuthStatus(state: AuthState.authenticated, user: user);
        return true;
      } else {
        // Usuario canceló el sign-in
        state = const AuthStatus(state: AuthState.initial);
        return false;
      }
    } catch (e) {
      state = AuthStatus(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Registrar nuevo usuario
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    int? age,
  }) async {
    state = state.copyWith(state: AuthState.authenticating);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        username: username.trim(),
        age: age,
      );
      if (user != null) {
        state = AuthStatus(state: AuthState.authenticated, user: user);
        return true;
      } else {
        state = const AuthStatus(
          state: AuthState.error,
          errorMessage: 'Error al crear la cuenta',
        );
        return false;
      }
    } catch (e) {
      state = AuthStatus(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signOut();
      state = const AuthStatus();
    } catch (e) {
      state = AuthStatus(
        state: AuthState.error,
        errorMessage: 'Error al cerrar sesión: $e',
      );
    }
  }

  // Método legacy para compatibilidad (usar email en lugar de username)
  @Deprecated('Use signInWithEmailAndPassword instead')
  Future<bool> signIn(String email, String password) async {
    return signInWithEmailAndPassword(email, password);
  }

  /// Actualizar información del usuario actual
  void updateUser(User updatedUser) {
    if (state.user != null) {
      state = state.copyWith(user: updatedUser);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
