// lib/presentation/screens/add_edit_item_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/wine.dart';
import 'package:wine_app/services/wines_provider.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  const AddEditItemScreen({
    super.key,
    this.initialWine,
    this.prefillExample = false,
  });

  final Wine? initialWine;
  final bool prefillExample;

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _grapesCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageUrlCtrl;

  bool get isEdit => widget.initialWine != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _yearCtrl = TextEditingController();
    _grapesCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _regionCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _imageUrlCtrl = TextEditingController();

    if (isEdit) {
      final w = widget.initialWine!;
      _nameCtrl.text = w.name;
      _yearCtrl.text = w.year;
      _grapesCtrl.text = w.grapes;
      _countryCtrl.text = w.country;
      _regionCtrl.text = w.region;
      _descCtrl.text = w.description;
      _imageUrlCtrl.text = w.pictureUrl ?? '';
    } else if (widget.prefillExample) {
      // Ejemplo cuando se llama desde la lista
      _nameCtrl.text = 'Catena Malbec';
      _yearCtrl.text = '2020';
      _grapesCtrl.text = 'Malbec';
      _countryCtrl.text = 'Argentina';
      _regionCtrl.text = 'Mendoza';
      _descCtrl.text = 'Malbec mendocino con fruta roja y buena estructura.';
      _imageUrlCtrl.text = '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    _grapesCtrl.dispose();
    _countryCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final wine = Wine(
      id: isEdit
          ? widget.initialWine!.id
          : DateTime.now().microsecondsSinceEpoch.toString(), // id nuevo
      name: _nameCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      grapes: _grapesCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      region: _regionCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      pictureUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
    );

    final winesRepo = ref.read(winesRepositoryProvider);
    if (isEdit) {
      await winesRepo.update(wine);
    } else {
      await winesRepo.insert(wine);
    }

    if (mounted) context.pop(true); // devolvemos "hubo cambios"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit wine' : 'Add wine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _grapesCtrl,
                decoration: const InputDecoration(labelText: 'Grapes'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _regionCtrl,
                decoration: const InputDecoration(labelText: 'Region'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Save changes' : 'Add'),
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

