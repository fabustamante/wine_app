import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_provider.dart';
import '../../services/wines_provider.dart';
import '../../domain/wine.dart';
import '../../presentation/screen/add_edit_item.dart';
import '../../presentation/screen/login.dart';
import '../../presentation/screen/profile.dart';
import '../../presentation/screen/settings.dart';
import '../../presentation/screen/wine_detail_screen.dart';
import '../../presentation/screen/wine_screen.dart';
import 'router_notifier.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final winesRepo = ref.watch(winesRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final authStatus = ref.read(authProvider);
      final loggedIn = authStatus.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/wines';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/wines',
        builder: (context, state) => WineScreen(winesRepo: winesRepo),
      ),
      GoRoute(
        path: '/add_item',
        builder: (context, state) {
          final Wine? initial = state.extra as Wine?;
          return AddEditItemScreen(
            initialWine: initial,
            prefillExample: initial == null,
          );
        },
      ),
      GoRoute(
        path: '/wine/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WineDetailScreen(
            winesRepo: winesRepo,
            wineId: id,
          );
        },
      ),
    ],
  );
});