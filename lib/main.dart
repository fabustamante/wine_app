import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'data/repositories/users_repository_firestore.dart';
import 'data/repositories/wines_repository_firestore.dart';
import 'firebase_options.dart';

// Entidades (para seed)
import 'domain/user.dart';
import 'domain/wine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  // Precargar SharedPreferences (tema)
  final prefs = await SharedPreferences.getInstance();

  // Seed inicial en Firestore si está vacío
  await _seedDataIfNeeded();

  final GoRouter appRouter = router;

  runApp(ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
    child: AppRoot(
      router: appRouter,
    ),
  ));
}

/// Seed de datos iniciales en Firestore (si no existen)
Future<void> _seedDataIfNeeded() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Revisar si ya hay usuarios en Firestore
    final usersSnap = await firestore.collection('users').limit(1).get();
    if (usersSnap.docs.isEmpty) {
      final usersRepo = UsersFirestoreRepository(firestore: firestore);
      await usersRepo.insertMany([
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
      print('✓ Usuarios seeded en Firestore');
    }

    // Revisar si hay vinos
    final winesSnap = await firestore.collection('wines').limit(1).get();
    if (winesSnap.docs.isEmpty) {
      final winesRepo = WinesFirestoreRepository(firestore: firestore);
      await winesRepo.insertMany([
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
      print('✓ Vinos seeded en Firestore');
    }
  } catch (e) {
    print('⚠️ Error seedeando datos: $e');
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme.getTheme(),
      routerConfig: router,
    );
  }
}
