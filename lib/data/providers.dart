import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repositories/wines_repository.dart';
import 'repositories/users_repository.dart';
import 'repositories/wines_repository_firestore.dart';
import 'repositories/users_repository_firestore.dart';

// Firestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Wine repository provider (using Firestore)
final winesRepositoryProvider = Provider<WinesRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return WinesFirestoreRepository(firestore: firestore);
});

// Users repository provider (using Firestore)
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UsersFirestoreRepository(firestore: firestore);
});