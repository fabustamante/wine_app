// lib/data/wines_dao.dart
import 'package:floor/floor.dart';
import '../domain/wine.dart';

@dao
abstract class WinesDao {
  @Query('SELECT * FROM Wine')
  Future<List<Wine>> getAll();

  @Query('SELECT * FROM Wine WHERE id = :id')
  Future<Wine?> getById(String id);

  @insert
  Future<void> insertOne(Wine wine);

  @insert
  Future<void> insertMany(List<Wine> wines);

  @update
  Future<void> updateOne(Wine wine);

  @delete
  Future<void> deleteOne(Wine wine);
}
