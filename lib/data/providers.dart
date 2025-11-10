import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/wines_repository.dart';
import 'repositories/wines_repository_impl.dart';
import 'app_database.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be initialized first');
});

// Wine repository provider
final winesRepositoryProvider = Provider<WinesRepository>((ref) {
  return LocalWinesRepository(ref.read(databaseProvider));
});