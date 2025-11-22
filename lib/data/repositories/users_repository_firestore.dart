import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';
import 'users_repository.dart';

/// Firestore implementation of UsersRepository
class UsersFirestoreRepository implements UsersRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _col;

  UsersFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _col = (firestore ?? FirebaseFirestore.instance).collection('users');

  /// Convert Firestore DocumentSnapshot to User domain model
  User _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: (data['id'] as num?)?.toInt() ?? doc.id.hashCode,
      username: data['username'] as String? ?? '',
      password: data['password'] as String? ?? '',
      email: data['email'] as String? ?? '',
      age: (data['age'] as num?)?.toInt(),
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  /// Convert User domain model to Firestore map
  Map<String, dynamic> _toDoc(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'password': user.password,
      'email': user.email,
      'age': user.age,
      'avatarUrl': user.avatarUrl,
    };
  }

  @override
  Future<User?> findByCredentials(String username, String password) async {
    final snapshot = await _col
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return _fromDoc(snapshot.docs.first);
  }

  @override
  Future<List<User>> getAll() async {
    final snapshot = await _col.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> insertMany(List<User> users) async {
    final batch = _firestore.batch();
    for (final u in users) {
      final docRef = _col.doc(u.username); // Use username as doc ID for simplicity
      batch.set(docRef, _toDoc(u));
    }
    await batch.commit();
  }
}

