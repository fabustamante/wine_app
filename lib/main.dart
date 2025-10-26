import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tema dinámico (sin provider)
import 'core/theme/theme_controller.dart';
import 'core/theme/theme_scope.dart';
import 'core/router/app_router.dart';

// Auth y repos
import 'services/auth_service.dart';
import 'data/users_repository.dart';     // <-- trae LocalUsersRepository
import 'data/wines_repository.dart';     // <-- trae LocalWinesRepository

// Entidades (para seed)
import 'domain/user.dart';
import 'domain/wine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Precargar SharedPreferences (tema)
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final colorIndex = prefs.getInt('selectedColor') ?? 0;

  final themeController = ThemeController.preloaded(
    prefs,
    isDarkMode: isDark,
    selectedColor: colorIndex,
  );

  // Inicializar repos basados en Floor
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

  // AuthService con repo de usuarios en DB
  final auth = AuthService(usersRepo);

  final GoRouter appRouter = AppRouter(auth, winesRepo).router;

  runApp(AppRoot(
    themeController: themeController,
    router: appRouter,
  ));
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    required this.themeController,
    required this.router,
  });

  final ThemeController themeController;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (_, __) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: themeController.themeData,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
