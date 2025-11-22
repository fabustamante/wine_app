import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/domain/user.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wine_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:wine_app/presentation/viewmodels/profile_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _ProfileView(user: user),
      drawer: const DrawerMenu(),
    );
  }
}

class _ProfileView extends ConsumerWidget {
  final User user;

  const _ProfileView({
    required this.user,
  });

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);
    
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x == null) return;

    // Usar el ViewModel para actualizar el avatar
    final success = await ref.read(profileProvider.notifier).updateAvatar(
      imagePath: x.path,
      currentUser: user,
    );

    if (success) {
      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Avatar actualizado exitosamente')));
    } else {
      final errorMessage = ref.read(profileProvider).errorMessage ?? 'Error al actualizar avatar';
      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _resetPass(BuildContext context) async {
    user.password = '1234';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Password is 1234')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final isUploading = profileState.avatarState == AvatarUpdateState.uploading;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: isUploading ? null : () async {
                      await _pickAvatar(context, ref);
                    },
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  if (isUploading)
                    Positioned.fill(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.black54,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(user.email),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _resetPass(context),
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}