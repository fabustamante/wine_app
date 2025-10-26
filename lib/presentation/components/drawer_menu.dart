
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/core/menu/menu_item.dart';
import 'package:wine_app/services/auth_provider.dart';

class DrawerMenu extends ConsumerStatefulWidget {
  const DrawerMenu({super.key});

  @override
  ConsumerState<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends ConsumerState<DrawerMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final username = authState.user?.username ?? 'User';
    
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        context.go(menu[index].path);
      },
      children: [
        DrawerHeader(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                child: Text('Wine App'),
              ),
              const SizedBox(height: 8),
              Text(username, style: textStyle.titleMedium),
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
        _LogoutTile(textStyle: textStyle),
      ],
    );
  }
}


class _LogoutTile extends ConsumerWidget {
  const _LogoutTile({
    required this.textStyle,
  });

  final TextTheme textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        // Cerrar el Drawer si está abierto
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }

        // Cerrar sesión usando el provider
        ref.read(authProvider.notifier).signOut();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Center(child: Text('Signed out successfully')),
            ),
          );

        context.go('/login');
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
