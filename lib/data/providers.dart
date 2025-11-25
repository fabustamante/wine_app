import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/wines_repository.dart';
import 'repositories/wines_repository_firestore.dart';

/// Provider for WinesRepository (Firestore implementation)
final winesRepositoryProvider = Provider<WinesRepository>((ref) {
  return WinesFirestoreRepository();
});
