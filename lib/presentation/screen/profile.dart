import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wine_app/domain/user.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:wine_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService auth;

  const ProfileScreen({super.key, required this.auth});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  AuthService get auth => widget.auth;

  @override
  initState() {
    super.initState();
    user = widget.auth.currentUser;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        /* actions: [
          IconButton(
            tooltip: 'Salir',
            onPressed: () {
              auth.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text('Sesión cerrada correctamente'),
                  ),
                ),
              );
              context.go('/login'); // redirect también te mandaría
            },
            icon: const Icon(Icons.logout),
          ),
        ], */
      ),
      body: _ProfileView(user: user!,context: context),
      drawer: DrawerMenu(auth: auth),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final User user;
  
  final BuildContext context;

  const _ProfileView({
    super.key,
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
    if (user == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Password is 1234')),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _pickAvatar();
                  },
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        (user!.avatarPath != null &&
                            File(user!.avatarPath!).existsSync())
                        ? FileImage(File(user!.avatarPath!))
                        : null,
                    child:
                        (user!.avatarPath == null ||
                            !File(user!.avatarPath!).existsSync())
                        ? const Icon(Icons.person, size: 40)
                        : null,
                    
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user!.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user!.email),
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