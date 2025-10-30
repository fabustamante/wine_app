import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/domain/user.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wine_app/presentation/viewmodels/auth_viewmodel.dart';

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

class _ProfileView extends StatelessWidget {
  final User user;

  const _ProfileView({
    required this.user,
  });

  Future<void> _pickAvatar(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x == null) return;
    
    user.avatarPath = x.path;
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Avatar updated')));
  }

  Future<void> _resetPass(BuildContext context) async {
    user.password = '1234';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Password is 1234')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarExists = user.avatarPath != null && File(user.avatarPath!).existsSync();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await _pickAvatar(context);
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: avatarExists ? FileImage(File(user.avatarPath!)) : null,
                  child: avatarExists ? null : const Icon(Icons.person, size: 40),
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