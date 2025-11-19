import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/wine.dart';
import '../../domain/repositories/wines_repository.dart';

/// Firestore implementation of WinesRepository
class WinesFirestoreRepository implements WinesRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _col;

  WinesFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _col = (firestore ?? FirebaseFirestore.instance).collection('wines');

  /// Convert Firestore DocumentSnapshot to Wine domain model
  Wine _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Wine(
      id: doc.id,
      name: data['name'] as String? ?? '',
      year: data['year'] as String? ?? '',
      grapes: data['grapes'] as String? ?? '',
      country: data['country'] as String? ?? '',
      region: data['region'] as String? ?? '',
      description: data['description'] as String? ?? '',
      pictureUrl: data['pictureUrl'] as String?,
    );
  }

  /// Convert Wine domain model to Firestore map
  Map<String, dynamic> _toDoc(Wine wine) {
    return {
      'name': wine.name,
      'year': wine.year,
      'grapes': wine.grapes,
      'country': wine.country,
      'region': wine.region,
      'description': wine.description,
      'pictureUrl': wine.pictureUrl,
    };
  }

  @override
  Future<void> delete(Wine wine) {
    return _col.doc(wine.id).delete();
  }

  @override
  Future<List<Wine>> getAll() async {
    final snapshot = await _col.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<Wine?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<void> insert(Wine wine) async {
    final id = wine.id;
    if (id.isEmpty) {
      // Let Firestore generate the ID
      await _col.add(_toDoc(wine));
    } else {
      // Use the provided ID
      await _col.doc(id).set(_toDoc(wine));
    }
  }

  @override
  Future<void> update(Wine wine) {
    return _col.doc(wine.id).update(_toDoc(wine));
  }

  @override
  Future<void> deleteAll() async {
    final wines = await getAll();
    for (final w in wines) {
      await delete(w);
    }
  }

  /// Batch insert multiple wines (useful for seeding)
  Future<void> insertMany(List<Wine> wines) async {
    final batch = _firestore.batch();
    for (final w in wines) {
      final docRef = _col.doc(w.id);
      batch.set(docRef, _toDoc(w));
    }
    await batch.commit();
  }
}
