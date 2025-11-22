import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final int id;
  final String username;
  String password;
  final String email;
  final int? age;
  String? avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.age,
    this.avatarUrl,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    int? age,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'email': email,
        'age': age,
        'avatarUrl': avatarUrl,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        password: json['password'] as String,
        email: json['email'] as String,
        age: json['age'] as int?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
  