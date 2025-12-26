import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

// Repos y entidades para seed inicial
import 'data/users_repository.dart';
import 'data/wines_repository.dart';
import 'domain/user.dart';
import 'domain/wine.dart';

Future<void> _initializeDatabase() async {
  final usersRepo = LocalUsersRepository();
  final winesRepo = LocalWinesRepository();

  // Seed inicial si las tablas están vacías
  // Usuarios
  final existingUsers = await usersRepo.getAll();
  if (existingUsers.isEmpty) {
    await usersRepo.insertMany(<User>[
      User(
        id: 1,
        username: 'admin',
        password: 'admin123',
        email: 'admin@gmail.com',
        age: 30,
      ),
      User(
        id: 2,
        username: 'guest',
        password: 'guest123',
        email: 'guest@gmail.com',
        age: 20,
      ),
      User(
        id: 3,
        username: 'user',
        password: 'password',
        email: 'user@gmail.com',
        age: 36,
      ),
    ]);
  }

  // Vinos
  final existingWines = await winesRepo.getAll();
  if (existingWines.isEmpty) {
    await winesRepo.insertMany(<Wine>[
      Wine(
        id: 'catena-malbec-2020',
        name: 'Catena Malbec',
        year: '2020',
        grapes: 'Malbec',
        country: 'Argentina',
        region: 'Mendoza',
        description: 'Malbec mendocino con fruta roja y buena estructura.',
        pictureUrl: null,
      ),
      Wine(
        id: 'trapiche-oak-cask-2019',
        name: 'Trapiche Oak Cask Malbec',
        year: '2019',
        grapes: 'Malbec',
        country: 'Argentina',
        region: 'Mendoza',
        description: 'Clásico Malbec con paso por roble.',
        pictureUrl: null,
      ),
    ]);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Precargar SharedPreferences (tema)
  final prefs = await SharedPreferences.getInstance();

  // Inicializar base de datos con datos de prueba
  await _initializeDatabase();

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const AppRoot(),
  ));
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme.getTheme(),
      routerConfig: router,
    );
  }
}
