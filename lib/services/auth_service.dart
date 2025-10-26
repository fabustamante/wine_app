import 'package:flutter/foundation.dart';
import '../domain/user.dart';
import '../data/users_repository.dart';

class AuthService extends ChangeNotifier {
  final UsersRepository _repo;
  AuthService(this._repo);

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> signIn(String username, String password) async {
    final user = await _repo.findByCredentials(username.trim(), password.trim());
    _currentUser = user;
    notifyListeners();        // <- go_router se refresca con esto
    return user != null;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
