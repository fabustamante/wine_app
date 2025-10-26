// lib/data/users_dao.dart
import 'package:floor/floor.dart';
import '../domain/user.dart';

@dao
abstract class UsersDao {
  @Query('SELECT * FROM User')
  Future<List<User>> getAll();

  @Query('SELECT * FROM User WHERE id = :id')
  Future<User?> getById(int id);

  @Query('SELECT * FROM User WHERE username = :username AND password = :password LIMIT 1')
  Future<User?> findByCredentials(String username, String password);

  @insert
  Future<void> insertOne(User user);

  @insert
  Future<void> insertMany(List<User> users);

  @update
  Future<void> updateOne(User user);

  @delete
  Future<void> deleteOne(User user);
}
