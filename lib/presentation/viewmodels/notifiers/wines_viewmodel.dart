import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/wines_repository.dart';
import '../../../domain/wine.dart';
import '../../../data/providers.dart';

typedef AsyncWinesState = AsyncValue<List<Wine>>;

class WinesViewModel extends AsyncNotifier<List<Wine>> {
  @override
  FutureOr<List<Wine>> build() async {
    final repository = ref.watch(winesRepositoryProvider);
    return repository.getAll();
  }

  Future<void> addWine(Wine wine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(winesRepositoryProvider);
      await repository.insert(wine);
      return repository.getAll();
    });
  }

  Future<void> updateWine(Wine wine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(winesRepositoryProvider);
      await repository.update(wine);
      return repository.getAll();
    });
  }

  Future<void> deleteWine(Wine wine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(winesRepositoryProvider);
      await repository.delete(wine);
      return repository.getAll();
    });
  }
}

final winesViewModelProvider = AsyncNotifierProvider<WinesViewModel, List<Wine>>(
  () => WinesViewModel(),
);