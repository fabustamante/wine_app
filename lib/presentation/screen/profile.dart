import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/domain/user.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:wine_app/services/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

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
      body: _ProfileView(user: user, context: context),
      drawer: const DrawerMenu(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final User user;
  
  final BuildContext context;

  const _ProfileView({
    required this.user,
    required this.context,
  });

  Future<void> _pickAvatar() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x == null) return;
    // Aquí deberías guardar la imagen en algún lugar y actualizar el path en el usuario
    // Por simplicidad, solo actualizamos el path temporalmente
    user.avatarPath = x.path;
  }
  Future<void> _resetPass() async {
    user.password = '1234';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Password is 1234')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      (user.avatarPath != null &&
                          File(user.avatarPath!).existsSync())
                          ? FileImage(File(user.avatarPath!))
                          : null,
                  child:
                      (user.avatarPath == null ||
                          !File(user.avatarPath!).existsSync())
                          ? const Icon(Icons.person, size: 40)
                          : null,
                ),
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
                onPressed: _resetPass,
                child: const Text('Reset Password'),
              ),
              ],
            ),
          ),
        ],
      );
  }
}