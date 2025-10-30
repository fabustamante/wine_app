import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/domain/wine.dart';
import 'package:wine_app/services/wines_provider.dart';

class WineDetailScreen extends ConsumerStatefulWidget {
  const WineDetailScreen({
    super.key,
    required this.wineId,
  });

  final String wineId;

  @override
  ConsumerState<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends ConsumerState<WineDetailScreen> {
  late Future<Wine?> _futureWine;

  @override
  void initState() {
    super.initState();
    _futureWine = ref.read(winesRepositoryProvider).getById(widget.wineId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureWine = ref.read(winesRepositoryProvider).getById(widget.wineId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Wine?>(
      future: _futureWine,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final wine = snap.data;
        final textStyle = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(wine?.name ?? 'Wine detail'),
            actions: [
              IconButton(
                tooltip: 'Edit wine',
                icon: const Icon(Icons.edit),
                onPressed: wine == null
                    ? null
                    : () async {
                        final bool? changed =
                            await context.push<bool>('/add_item', extra: wine);
                        if (changed == true) await _reload();
                      },
              ),
              IconButton(
                tooltip: 'Delete wine',
                icon: const Icon(Icons.delete_outline),
                onPressed: wine == null
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete?'),
                            content: Text('Delete "${wine.name}" permanently?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok != true || !mounted) return;
                        
                        await ref.read(winesRepositoryProvider).delete(wine);
                        context.pop();
                      },
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : (wine == null)
                  ? const Center(child: Text('Wine not found'))
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: (wine.pictureUrl != null && wine.pictureUrl!.isNotEmpty)
                                  ? Image.network(
                                      wine.pictureUrl!,
                                      height: 400,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset('assets/images/default_wine.jpg', height: 400);
                                      },
                                    )
                                  : Image.asset('assets/images/default_wine.jpg', height: 400),
                            ),

                            const SizedBox(height: 20),
                            Text(wine.name, style: textStyle.headlineMedium, textAlign: TextAlign.center),
                            const SizedBox(height: 10),
                            Text('Grapes: ${wine.grapes}', style: textStyle.bodyMedium),
                            const SizedBox(height: 5),
                            Text('Country: ${wine.country}', style: textStyle.bodyMedium),
                            const SizedBox(height: 5),
                            Text('Year: ${wine.year}', style: textStyle.bodyMedium),
                            const SizedBox(height: 20),
                            Text(
                              wine.description,
                              style: textStyle.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }
}