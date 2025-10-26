import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/core/menu/menu_item.dart';
import 'package:wine_app/services/auth_service.dart';

class DrawerMenu extends StatefulWidget {
  final AuthService auth;

  const DrawerMenu({super.key, required this.auth});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  int _selectedIndex = 0;
 // AuthService auth = widget.auth;
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme; 
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        context.go(menu[index].path);
      },
      children: [
        const DrawerHeader(
          child: Column(
            children: [
              //Text('Menu'),
              CircleAvatar(
                radius: 48,
                child: Text('Wine App'),
                )
            ],
          ),
        ),
        ...menu
            .map(
              (item) => NavigationDrawerDestination(
                icon: Icon(item.icon),
                label: Text(item.title),
              ),
            )
            .toList(),
        const Divider(),
        _LogoutTile(textStyle: textStyle, auth: widget.auth),
        
      ],
    );
  }
}


class _LogoutTile extends StatelessWidget {
  const _LogoutTile({
    super.key,
    required this.textStyle,
    required this.auth,
  });

  final TextTheme textStyle;
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text('Log Out', style: textStyle.bodySmall),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign out?'),
            content: const Text('You will be signed out of this session. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ) ?? false;

        if (!confirmed) return;

        // Cerrar el Drawer si está abierto (por seguridad)
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold?.isDrawerOpen ?? false) {
          Navigator.of(context).pop(); // cierra el Drawer
        }

        auth.signOut();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Center(child: Text('Signed out successfully')),
            ),
          );

        context.go('/login'); // el redirect por auth igual te protege
      },
    );
  }
}


/* class _LogoutTile extends StatelessWidget {
  const _LogoutTile({
    super.key,
    required this.textStyle,
    required this.auth,
  });

  final TextTheme textStyle;
  
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text('Log Out', style: textStyle.bodySmall),
      onTap: () {
        auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Sesión cerrada correctamente'),
              ),
            ),
          );
          context.go('/login'); // redirect también te mandaría
      } ,
    );
  }
} */
