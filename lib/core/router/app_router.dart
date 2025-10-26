// core/router/app_router.dart (fragmento)
import 'package:go_router/go_router.dart';
import 'package:wine_app/presentation/screen/add_edit_item.dart';
import 'package:wine_app/presentation/screen/login.dart';
import 'package:wine_app/presentation/screen/profile.dart';
import 'package:wine_app/presentation/screen/settings.dart';
import 'package:wine_app/presentation/screen/wine_detail_screen.dart';
import 'package:wine_app/presentation/screen/wine_screen.dart';
import '../../services/auth_service.dart';
import '../../data/wines_repository.dart';
import '../../domain/wine.dart';


class AppRouter {
  AppRouter(this.auth, this.winesRepo);

  final AuthService auth;
  final WinesRepository winesRepo;

  late final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(auth: auth),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(auth: auth),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(auth: auth),
      ),
      GoRoute(
        path: '/wines',
        builder: (context, state) => WineScreen(auth: auth, winesRepo: winesRepo),
      ),
      GoRoute(
        path: '/add_item',
        builder: (context, state) {
          final Wine? initial = state.extra as Wine?;
          return AddEditItemScreen(
            auth: auth,
            winesRepo: winesRepo,
            initialWine: initial,
            // Si no viene initial => se llamó desde la lista: precargar ejemplo
            prefillExample: initial == null,
          );
        },
      ),
      GoRoute(
        path: '/wine/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WineDetailScreen(
            auth: auth,
            winesRepo: winesRepo,
            wineId: id,
          );
        },
      ),
    ],
  );
}



/* import 'package:go_router/go_router.dart';
import 'package:wine_app/domain/wine.dart';
import 'package:wine_app/presentation/screen/add_edit_item.dart';
import 'package:wine_app/presentation/screen/home.dart';
import 'package:wine_app/presentation/screen/login.dart';
import 'package:wine_app/presentation/screen/profile.dart';
import 'package:wine_app/presentation/screen/settings.dart';
import 'package:wine_app/presentation/screen/wine_detail_screen.dart';
import 'package:wine_app/presentation/screen/wine_screen.dart';
import 'package:wine_app/services/auth_service.dart';

class AppRouter {
  AppRouter(this.auth);

  final AuthService auth;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: auth, // <- se reconstruye si cambia el login
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(auth: auth),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(auth: auth),
      ),
      GoRoute(
        path: '/wine_list',
        builder: (context, state) => WineScreen(auth: auth),
      ),
      GoRoute(
        path: '/wine_detail',
        builder:(context, state) => WineDetailScreen(wine: state.extra as Wine), 
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(auth: auth),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(auth: auth),
      ),
      GoRoute(
        path: '/add_item',
        builder: (context, state) {
        // Si quisieras, podés pasar bool en extra para prellenar ejemplo
        final prefill = (state.extra as bool?) ?? false;
        return AddEditItemScreen(prefillExample: prefill, auth: auth);
        },
      ),
      GoRoute(
        path: '/edit_item',
        builder: (context, state) {
        final wine = state.extra as Wine;
        return AddEditItemScreen(initialWine: wine, auth: auth);
        }
      )
    ],
  );
}
 */