/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final textStyle = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Wine App'), 
      ),
      body: GestureDetector(
        onTap: () => context.go('/wine_list'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Card(
                child: Text(
                  user != null
                      ? '¡Bienvenido, ${user.username}!\nEmail: ${user.email}'
                      : 'Sin usuario',
                  textAlign: TextAlign.center,
                  style: textStyle.headlineMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */
