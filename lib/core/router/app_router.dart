import 'package:go_router/go_router.dart';
import 'package:wine_app/presentation/screen/add_edit_item.dart';
import 'package:wine_app/presentation/screen/login.dart';
import 'package:wine_app/presentation/screen/profile.dart';
import 'package:wine_app/presentation/screen/settings.dart';
import 'package:wine_app/presentation/screen/wine_detail_screen.dart';
import 'package:wine_app/presentation/screen/wine_screen.dart';
import '../../domain/wine.dart';

final router = GoRouter(
  initialLocation: '/login',
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
      builder: (context, state) => const WineScreen(),
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
          wineId: id,
        );
      },
    ),
  ],
);