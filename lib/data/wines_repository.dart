// lib/data/wines_repository.dart
import '../domain/wine.dart';
import 'app_database.dart';
import 'wines_dao.dart';

abstract class WinesRepository {
  Future<List<Wine>> getAll();
  Future<Wine?> getById(String id);
  Future<void> insert(Wine wine);
  Future<void> insertMany(List<Wine> seed);
  Future<void> update(Wine wine);
  Future<void> delete(Wine wine);
}

class LocalWinesRepository implements WinesRepository {
  AppDatabase? _db;
  WinesDao? _dao;

  Future<void> _init() async {
    _db ??= await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _dao ??= _db!.winesDao;
  }

  @override
  Future<List<Wine>> getAll() async {
    await _init();
    return _dao!.getAll();
  }

  @override
  Future<Wine?> getById(String id) async {
    await _init();
    return _dao!.getById(id);
  }

  @override
  Future<void> insert(Wine wine) async {
    await _init();
    return _dao!.insertOne(wine);
  }

  @override
  Future<void> insertMany(List<Wine> seed) async {
    await _init();
    return _dao!.insertMany(seed);
  }

  @override
  Future<void> update(Wine wine) async {
    await _init();
    return _dao!.updateOne(wine);
  }

  @override
  Future<void> delete(Wine wine) async {
    await _init();
    return _dao!.deleteOne(wine);
  }
}
