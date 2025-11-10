import '../wine.dart';

abstract class WinesRepository {
  Future<List<Wine>> getAll();
  Future<Wine?> getById(String id);
  Future<void> insert(Wine wine);
  Future<void> update(Wine wine);
  Future<void> delete(Wine wine);
  Future<void> deleteAll();
}