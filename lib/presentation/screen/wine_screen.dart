// lib/presentation/screens/wine_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import '../../services/auth_service.dart';
import '../../data/wines_repository.dart';
import '../../domain/wine.dart';

class WineScreen extends StatefulWidget {
  const WineScreen({super.key, required this.auth, required this.winesRepo});
  final AuthService auth;
  final WinesRepository winesRepo;

  @override
  State<WineScreen> createState() => _WineScreenState();
}

class _WineScreenState extends State<WineScreen> {
  late Future<List<Wine>> _futureWines;

  @override
  void initState() {
    super.initState();
    _futureWines = widget.winesRepo.getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureWines = widget.winesRepo.getAll();
    });
  }

  Future<void> _onAddWine() async {
    // Abrimos /add_item SIN extra => AddEditItemScreen precarga ejemplo
    final bool? changed = await context.push<bool>('/add_item');
    if (changed == true) {
      await _refresh();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Wine added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wines'),
        /* actions: [
          IconButton(
            tooltip: 'Add wine',
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Abrimos /add_item SIN extra => AddEditItemScreen precarga ejemplo
              final bool? changed = await context.push<bool>('/add_item');
              if (changed == true) {
                await _refresh();
              }
            },
          ),
        ], */
      ),
      body: FutureBuilder<List<Wine>>(
        future: _futureWines,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final wines = snap.data ?? <Wine>[];
          if (wines.isEmpty) {
            return const Center(child: Text('No wines yet'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: wines.length,
              itemBuilder: (context, index) {
              final w = wines[index];
                return GestureDetector(
                  onTap: () =>
                    context.push('/wine/${w.id}').then((_) => _refresh()),
                  child: Card(
                    child: ListTile(
                      title: Text(w.name),
                      subtitle: Text('${w.grapes} - ${w.country}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      leading: w.pictureUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                w.pictureUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.wine_bar),
                    ),
                  ),
                );
              },
            ),

            /* child: ListView.separated(
              itemCount: wines.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final w = wines[i];
                return ListTile(
                  leading: const Icon(Icons.local_bar),
                  title: Text(w.name),
                  subtitle: Text('${w.region}, ${w.country} • ${w.year}'),
                  onTap: () =>
                      context.push('/wine/${w.id}').then((_) => _refresh()),
                );
              },
            ), */
          );
        },
      ),
      drawer: DrawerMenu(auth: widget.auth),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWine,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/domain/wine.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:wine_app/services/auth_service.dart';

class WineScreen extends StatefulWidget {
  WineScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<WineScreen> createState() => _WineScreenState();
}

class _WineScreenState extends State<WineScreen> {
  late List<Wine> _wines;
  @override
  void initState() {
    super.initState();
    _wines = List<Wine>.of(winesList); // si partís de una semilla
  }
  Future<void> _onAddWine() async {
    // Pasamos extra=true para que la screen precargue un ejemplo
    final newWine = await context.push<Wine>('/add_item', extra: true);
    if (newWine != null) {
      setState(() => _wines.insert(0, newWine));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Wine added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wine List')),
      body: _WinesView(wines: _wines),
      drawer: DrawerMenu(auth: widget.auth),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWine,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WinesView extends StatelessWidget {
  const _WinesView({super.key, required this.wines});
  final List<Wine> wines;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: wines.length,
      itemBuilder: (context, index) {
        return _WineItem(wine: wines[index]);
      },
    );
  }
}

class _WineItem extends StatelessWidget {
  const _WineItem({super.key, required this.wine});
  final Wine wine;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/wine_detail', extra: wine),
      child: Card(
        child: ListTile(
          title: Text(wine.name),
          subtitle: Text('${wine.grapes} - ${wine.country}'),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: wine.pictureUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    wine.pictureUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.wine_bar),
        ),
      ),
    );
  }
}
 */
