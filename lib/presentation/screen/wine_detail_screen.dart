// lib/presentation/screens/wine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/wines_repository.dart';
import '../../domain/wine.dart';

class WineDetailScreen extends StatefulWidget {
  const WineDetailScreen({
    super.key,
    required this.auth,
    required this.winesRepo,
    required this.wineId,
  });

  final AuthService auth;
  final WinesRepository winesRepo;
  final String wineId;

  @override
  State<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends State<WineDetailScreen> {
  late Future<Wine?> _futureWine;

  @override
  void initState() {
    super.initState();
    _futureWine = widget.winesRepo.getById(widget.wineId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureWine = widget.winesRepo.getById(widget.wineId);
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
              // Editar: reusar AddEditItemScreen
              IconButton(
                tooltip: 'Edit wine',
                icon: const Icon(Icons.edit),
                onPressed: wine == null
                    ? null
                    : () async {
                        // Pasamos el wine en extra -> AddEditItem precarga con datos reales
                        final bool? changed =
                            await context.push<bool>('/add_item', extra: wine);
                        if (changed == true) {
                          await _reload();
                        }
                      },
              ),
              // (Opcional) borrar
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
                        if (ok == true) {
                          await widget.winesRepo.delete(wine);
                          if (mounted) context.pop(); // volver a la lista
                        }
                      },
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : (wine == null)
                  ? const Center(child: Text('Wine not found')) 
                  :  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* if (wine.pictureUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(wine.pictureUrl!, height: 200),
                              ), */
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
                            Text(wine.name, style: textStyle.headlineMedium,textAlign:  TextAlign.center),
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
                    ),/* Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          if (wine.pictureUrl != null && wine.pictureUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Image.network(wine.pictureUrl!, height: 220, fit: BoxFit.cover),
                            ),
                          Text(wine.name, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text('${wine.region}, ${wine.country} • ${wine.year}'),
                          const SizedBox(height: 8),
                          Text('Grapes: ${wine.grapes}'),
                          const Divider(height: 32),
                          Text(wine.description),
                        ],
                      ),
                    ), */
        );
      },
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/domain/wine.dart';

class WineDetailScreen extends StatefulWidget {
  final Wine wine;

  const WineDetailScreen({super.key, required this.wine});

  @override
  State<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends State<WineDetailScreen> {
  //final Wine wine;
  late Wine _wine;

  @override
  void initState() {
    super.initState();
    _wine = widget.wine;
  }
  Future<void> _edit() async {
    final updated = await context.push<Wine>('/edit_item', extra: _wine);
    if (updated != null) {
      setState(() => _wine = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Wine updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_wine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
        ],
      ),
      body: _WineDetailView(wine: _wine),
    );
  }
}

class _WineDetailView extends StatelessWidget {
  const _WineDetailView({super.key, required this.wine});

  final Wine wine;
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (wine.pictureUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(wine.pictureUrl!, height: 200),
              ),
            const SizedBox(height: 20),
            Text(wine.name, style: textStyle.headlineMedium,textAlign:  TextAlign.center),
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
    );
  }
}
 */