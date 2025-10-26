// lib/data/app_database.dart
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
  version: 1,
  entities: [User, Wine],
)
abstract class AppDatabase extends FloorDatabase {
  UsersDao get usersDao;
  WinesDao get winesDao;
}
