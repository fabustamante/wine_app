import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import '../../domain/wine.dart';
import 'package:wine_app/services/wines_provider.dart';

class WineScreen extends ConsumerStatefulWidget {
  const WineScreen({super.key});

  @override
  ConsumerState<WineScreen> createState() => _WineScreenState();
}

class _WineScreenState extends ConsumerState<WineScreen> {
  late Future<List<Wine>> _futureWines;

  @override
  void initState() {
    super.initState();
    _futureWines = ref.read(winesRepositoryProvider).getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureWines = ref.read(winesRepositoryProvider).getAll();
    });
  }

  Future<void> _onAddWine() async {
    final bool? changed = await context.push<bool>('/add_item');
    if (!mounted || changed != true) return;
    
    await _refresh();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Wine added')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wines'),
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
          );
        },
      ),
      drawer: const DrawerMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWine,
        child: const Icon(Icons.add),
      ),
    );
  }
}
