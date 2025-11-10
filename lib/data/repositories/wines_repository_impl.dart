import '../../domain/wine.dart';
import '../../domain/repositories/wines_repository.dart';
import '../app_database.dart';

class LocalWinesRepository implements WinesRepository {
  final AppDatabase _db;

  LocalWinesRepository(this._db);

  @override
  Future<void> delete(Wine wine) => _db.winesDao.deleteOne(wine);

  @override
  Future<void> deleteAll() async {
    final wines = await getAll();
    for (final wine in wines) {
      await delete(wine);
    }
  }

  @override
  Future<List<Wine>> getAll() => _db.winesDao.getAll();

  @override
  Future<Wine?> getById(String id) => _db.winesDao.getById(id);

  @override
  Future<void> insert(Wine wine) => _db.winesDao.insertOne(wine);

  @override
  Future<void> update(Wine wine) => _db.winesDao.updateOne(wine);
}