import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/users_repository.dart';
import '../domain/user.dart';

// Provider para el repositorio de usuarios
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return LocalUsersRepository();
});

// Estados posibles de autenticación
enum AuthState {
  initial,
  authenticating,
  authenticated,
  error,
}

// Estado de autenticación con user y estado actual
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

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    return const AuthStatus();
  }

  Future<bool> signIn(String username, String password) async {
    state = state.copyWith(state: AuthState.authenticating);
    
    try {
      final repo = ref.read(usersRepositoryProvider);
      final user = await repo.findByCredentials(username.trim(), password.trim());
      
      if (user != null) {
        state = AuthStatus(
          state: AuthState.authenticated,
          user: user,
        );
        return true;
      } else {
        state = AuthStatus(
          state: AuthState.error,
          errorMessage: 'Usuario o contraseña incorrectos',
        );
        return false;
      }
    } catch (e) {
      state = AuthStatus(
        state: AuthState.error,
        errorMessage: 'Error al intentar iniciar sesión',
      );
      return false;
    }
  }

  void signOut() {
    state = const AuthStatus();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);