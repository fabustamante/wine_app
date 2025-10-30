import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wines_repository.dart';

final winesRepositoryProvider = Provider<WinesRepository>((ref) {
  return LocalWinesRepository();
});
