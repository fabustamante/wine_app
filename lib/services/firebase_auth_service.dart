import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user.dart' as domain;

/// Servicio de autenticación con Firebase
/// Soporta autenticación con correo/contraseña y Google
class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream del estado de autenticación
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Usuario actual de Firebase
  auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Registrar nuevo usuario con correo y contraseña
  Future<domain.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    int? age,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Crear documento de usuario en Firestore
        final user = domain.User(
          id: credential.user!.uid.hashCode,
          username: username,
          email: email,
          password: '', // No almacenar contraseña en Firestore
          age: age,
        );

        await _firestore.collection('users').doc(credential.user!.uid).set({
          'id': user.id,
          'username': username,
          'email': email,
          'age': age,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  /// Iniciar sesión con correo y contraseña
  Future<domain.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await _getUserFromFirestore(credential.user!.uid);
      }
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  /// Iniciar sesión con Google
  Future<domain.User?> signInWithGoogle() async {
    try {
      // Trigger el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el sign-in
        return null;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credencial de Firebase
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in a Firebase con la credencial de Google
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Verificar si el usuario ya existe en Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Crear nuevo documento si no existe
          final user = domain.User(
            id: userCredential.user!.uid.hashCode,
            username: googleUser.displayName ?? googleUser.email.split('@')[0],
            email: googleUser.email,
            password: '',
            avatarPath: googleUser.photoUrl,
          );

          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'avatarPath': user.avatarPath,
            'createdAt': FieldValue.serverTimestamp(),
          });

          return user;
        } else {
          return await _getUserFromFirestore(userCredential.user!.uid);
        }
      }
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error al iniciar sesión con Google: $e';
    }
    return null;
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Obtener datos de usuario desde Firestore
  Future<domain.User?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return domain.User(
      id: (data['id'] as num?)?.toInt() ?? uid.hashCode,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      password: '',
      age: (data['age'] as num?)?.toInt(),
      avatarPath: data['avatarPath'] as String?,
    );
  }

  /// Manejar excepciones de Firebase Auth
  String _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'user-not-found':
        return 'No se encontró usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
