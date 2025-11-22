// lib/data/users_repository.dart
import '../../domain/user.dart';
// import '../app_database.dart'; // Comentado - usando Firestore
// import '../users_dao.dart'; // Comentado - usando Firestore

abstract class UsersRepository {
  Future<User?> findByCredentials(String username, String password);
  Future<List<User>> getAll();
  Future<void> insertMany(List<User> seed);
}

// NOTA: LocalUsersRepository usa Floor (base de datos local)
// El proyecto actualmente usa UsersFirestoreRepository
// Se mantiene comentado para referencia futura si se necesita soporte offline
/*
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
*/

