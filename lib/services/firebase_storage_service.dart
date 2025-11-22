import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

/// Servicio para manejar operaciones de Firebase Storage
/// Principalmente para subir y gestionar imágenes de perfil de usuarios
class FirebaseStorageService {
  final FirebaseStorage _storage;
  final auth.FirebaseAuth _firebaseAuth;

  FirebaseStorageService({
    FirebaseStorage? storage,
    auth.FirebaseAuth? firebaseAuth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  /// Sube una imagen de avatar del usuario y retorna la URL de descarga
  /// 
  /// [imagePath] - Ruta local del archivo de imagen
  /// Retorna la URL pública de la imagen subida
  /// Lanza una excepción si no hay usuario autenticado o si falla la subida
  Future<String> uploadUserAvatar(String imagePath) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      final File file = File(imagePath);
      
      // Verificar que el archivo existe
      if (!await file.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      // Crear una referencia única para el avatar del usuario
      final String fileName = 'avatar_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('user_avatars').child(fileName);

      // Configurar metadata para la imagen
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': currentUser.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir el archivo
      final UploadTask uploadTask = storageRef.putFile(file, metadata);

      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'Error al subir imagen: $e';
    }
  }

  /// Elimina el avatar anterior del usuario
  /// 
  /// [imageUrl] - URL de la imagen a eliminar
  Future<void> deleteUserAvatar(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } on FirebaseException catch (e) {
      // Si la imagen no existe, no es un error crítico
      if (e.code != 'object-not-found') {
        throw _handleStorageException(e);
      }
    } catch (e) {
      // Ignorar errores al eliminar, no es crítico
      // Error no crítico, se puede ignorar en producción
    }
  }

  /// Actualiza el avatar del usuario, eliminando el anterior si existe
  /// 
  /// [newImagePath] - Ruta local de la nueva imagen
  /// [oldImageUrl] - URL de la imagen anterior (puede ser null)
  /// Retorna la URL de la nueva imagen subida
  Future<String> updateUserAvatar({
    required String newImagePath,
    String? oldImageUrl,
  }) async {
    // Subir la nueva imagen primero
    final String newImageUrl = await uploadUserAvatar(newImagePath);

    // Si existe una imagen anterior, eliminarla
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      // Eliminar en segundo plano, no esperamos
      // Error no crítico, se ignora
      deleteUserAvatar(oldImageUrl).catchError((e) => null);
    }

    return newImageUrl;
  }

  /// Maneja excepciones de Firebase Storage
  String _handleStorageException(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'No tienes permisos para realizar esta acción';
      case 'canceled':
        return 'La subida fue cancelada';
      case 'unknown':
        return 'Error desconocido al procesar la imagen';
      case 'object-not-found':
        return 'La imagen no existe';
      case 'bucket-not-found':
        return 'Error de configuración del almacenamiento';
      case 'quota-exceeded':
        return 'Se excedió el límite de almacenamiento';
      case 'invalid-checksum':
        return 'La imagen está corrupta';
      case 'retry-limit-exceeded':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de almacenamiento: ${e.message}';
    }
  }
}
