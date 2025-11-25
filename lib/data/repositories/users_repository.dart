// lib/data/users_repository.dart
import '../../domain/user.dart';

abstract class UsersRepository {
  Future<User?> findByCredentials(String username, String password);
  Future<List<User>> getAll();
  Future<void> insertMany(List<User> seed);
}
