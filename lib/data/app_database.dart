// lib/data/app_database.dart
// NOTA: Este archivo usa Floor (base de datos local) pero el proyecto actualmente usa Firestore
// Se mantiene comentado para referencia futura si se necesita soporte offline

/*
import 'dart:async';
import 'package:floor/floor.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

import '../domain/user.dart';
import '../domain/wine.dart';
import 'users_dao.dart';
import 'wines_dao.dart';

part 'app_database.g.dart';

@Database(
  version: 2,
  entities: [User, Wine],
)
abstract class AppDatabase extends FloorDatabase {
  UsersDao get usersDao;
  WinesDao get winesDao;
}

// Migración de versión 1 a 2: Renombrar columna avatarPath a avatarUrl
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE User RENAME COLUMN avatarPath TO avatarUrl');
});
*/
