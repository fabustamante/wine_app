import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../services/firebase_storage_service.dart';
import '../../domain/user.dart';
import 'auth_viewmodel.dart';

/// Estados del proceso de actualización de avatar
enum AvatarUpdateState {
  idle,
  uploading,
  success,
  error,
}

/// Estado del ViewModel de Profile
class ProfileState {
  final AvatarUpdateState avatarState;
  final String? errorMessage;
  final bool isUpdatingProfile;

  const ProfileState({
    this.avatarState = AvatarUpdateState.idle,
    this.errorMessage,
    this.isUpdatingProfile = false,
  });

  ProfileState copyWith({
    AvatarUpdateState? avatarState,
    String? errorMessage,
    bool? isUpdatingProfile,
  }) {
    return ProfileState(
      avatarState: avatarState ?? this.avatarState,
      errorMessage: errorMessage ?? this.errorMessage,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
    );
  }
}

/// Provider del servicio de Firebase Storage
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

/// ViewModel para la pantalla de perfil
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  /// Actualiza el avatar del usuario
  /// Sube la imagen a Firebase Storage y actualiza Firestore
  Future<bool> updateAvatar({
    required String imagePath,
    required User currentUser,
  }) async {
    state = state.copyWith(avatarState: AvatarUpdateState.uploading);

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      
      // Subir la nueva imagen a Firebase Storage
      final newAvatarUrl = await storageService.updateUserAvatar(
        newImagePath: imagePath,
        oldImageUrl: currentUser.avatarUrl,
      );

      // Actualizar el documento del usuario en Firestore
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'avatarUrl': newAvatarUrl,
      });

      // Actualizar el usuario local
      final updatedUser = currentUser.copyWith(avatarUrl: newAvatarUrl);
      
      // Notificar al AuthViewModel que el usuario cambió
      ref.read(authProvider.notifier).updateUser(updatedUser);

      state = state.copyWith(avatarState: AvatarUpdateState.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        avatarState: AvatarUpdateState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resetea el estado del avatar a idle
  void resetAvatarState() {
    state = state.copyWith(avatarState: AvatarUpdateState.idle);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
