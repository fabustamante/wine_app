import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import '../viewmodels/notifiers/wines_viewmodel.dart';

class WineScreen extends ConsumerStatefulWidget {
  const WineScreen({super.key});

  @override
  ConsumerState<WineScreen> createState() => _WineScreenState();
}

class _WineScreenState extends ConsumerState<WineScreen> {
  Future<void> _refreshWines() async {
    // Force a refresh of the wines list
    ref.invalidate(winesViewModelProvider);
  }

  Future<void> _onAddWine() async {
    final bool? changed = await context.push<bool>('/add_item');
    if (!mounted || changed != true) return;
    
    await _refreshWines();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Wine added')));
  }

  @override
  Widget build(BuildContext context) {
    final winesState = ref.watch(winesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wines'),
      ),
      body: winesState.when(
        data: (List<dynamic> wines) => wines.isEmpty 
          ? const Center(child: Text('No wines yet'))
          : RefreshIndicator(
            onRefresh: _refreshWines,
            child: ListView.builder(
              itemCount: wines.length,
              itemBuilder: (context, index) {
                final wine = wines[index];
                return GestureDetector(
                  onTap: () =>
                    context.push('/wine/${wine.id}').then((_) => _refreshWines()),
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
              },
            ),
          ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: _refreshWines,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      drawer: const DrawerMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWine,
        child: const Icon(Icons.add),
      ),
    );
  }
}
