// lib/domain/user.dart
import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final int id;
  final String username;
  String password;
  final String email;
  final int? age;
  String? avatarPath;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.age,
    this.avatarPath,
  });
}

// Si usabas una lista "users" de ejemplo, podés conservarla temporalmente
// para seedear o para debug, pero ya no será la fuente de verdad.


List <User> users = [
  User(
      id: 1,
      username: 'user',
      password: 'password',
      email: 'user@gmail.com',
      age: 25),
  User(
      id: 2,
      username: 'admin',
      password: 'admin123',
      email: 'admin@gmail.com',
      age: 30),
  User(
      id: 3,
      username: 'guest',
      password: 'guest123',
      email: 'guest@gmail.com',
      age: 20)
];
  