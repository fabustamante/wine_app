// lib/data/users_repository.dart
import '../domain/user.dart';
import 'app_database.dart';
import 'users_dao.dart';

abstract class UsersRepository {
  Future<User?> findByCredentials(String username, String password);
  Future<List<User>> getAll();
  Future<void> insertMany(List<User> seed);
}

class LocalUsersRepository implements UsersRepository {
  AppDatabase? _db;
  UsersDao? _dao;

  Future<void> _init() async {
    _db ??= await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _dao ??= _db!.usersDao;
  }

  @override
  Future<User?> findByCredentials(String username, String password) async {
    await _init();
    return _dao!.findByCredentials(username, password);
  }

  @override
  Future<List<User>> getAll() async {
    await _init();
    return _dao!.getAll();
  }

  @override
  Future<void> insertMany(List<User> seed) async {
    await _init();
    return _dao!.insertMany(seed);
  }
}


/* import '../domain/user.dart';
import 'dart:async';
import 'package:collection/collection.dart';

abstract class UsersRepository {
  /// Devuelve el usuario si username/password coinciden; null si no.
  Future<User?> findByCredentials(String username, String password);
}

class InMemoryUsersRepository implements UsersRepository {
  final List<User> _users;
  InMemoryUsersRepository(this._users);

  @override
  Future<User?> findByCredentials(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return _users.firstWhereOrNull(
      (u) => u.username == username && u.password == password,
    );
  }
} */
