// lib/presentation/screens/add_edit_item_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/wines_repository.dart';
import '../../domain/wine.dart';

class AddEditItemScreen extends StatefulWidget {
  const AddEditItemScreen({
    super.key,
    required this.auth,
    required this.winesRepo,
    this.initialWine,
    this.prefillExample = false,
  });

  final AuthService auth;
  final WinesRepository winesRepo;
  final Wine? initialWine;
  final bool prefillExample;

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
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

    if (isEdit) {
      await widget.winesRepo.update(wine);
    } else {
      await widget.winesRepo.insert(wine);
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

/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/domain/wine.dart';
import 'package:wine_app/services/auth_service.dart';


class AddEditItemScreen extends StatefulWidget {
  const AddEditItemScreen({
    super.key,
    required this.auth,
    this.initialWine,
    this.prefillExample = false,
  });

  /// Si viene un Wine, estamos en modo edición.
  final Wine? initialWine;

  /// Si no viene Wine y esto es true, precarga un ejemplo.
  final bool prefillExample;
  
  final AuthService auth;

  bool get isEditing => initialWine != null;

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _grapesCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // Precargar con el wine recibido
      final w = widget.initialWine!;
      _nameCtrl.text = w.name;
      _yearCtrl.text = w.year;
      _grapesCtrl.text = w.grapes;
      _countryCtrl.text = w.country;
      _regionCtrl.text = w.region;
      _descCtrl.text = w.description;
      _imageUrlCtrl.text = w.pictureUrl ?? '';
    } else if (widget.prefillExample) {
      // Precargar con un ejemplo
      _nameCtrl.text = 'Trapiche Oak Cask Malbec';
      _yearCtrl.text = '2021';
      _grapesCtrl.text = 'Malbec';
      _countryCtrl.text = 'Argentina';
      _regionCtrl.text = 'Mendoza';
      _descCtrl.text = 'Red wine with ripe plum and subtle oak notes.';
      _imageUrlCtrl.text = 'https://maxiconsumo.com/media/catalog/product/cache/dee42de555cd0e5c071d2951391ded3b/2/6/26519.jpg';
    } else {
      // Defaults para alta "vacía"
      _countryCtrl.text = 'Argentina';
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.isEditing
        ? widget.initialWine!.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final wine = Wine(
      id: id,
      name: _nameCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      grapes: _grapesCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      region: _regionCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      pictureUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
    );

    // Devolvemos el Wine (nuevo o actualizado)
    context.pop<Wine>(wine);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Wine' : 'Add Wine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Catena Malbec',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              gap,
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., 2021',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Required';
                  if (!RegExp(r'^\d{4}$').hasMatch(s)) return 'Enter a 4-digit year';
                  return null;
                },
              ),
              gap,
              TextFormField(
                controller: _grapesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Grapes *',
                  hintText: 'e.g., Malbec',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              gap,
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  hintText: 'e.g., Argentina',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              gap,
              TextFormField(
                controller: _regionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Region *',
                  hintText: 'e.g., Mendoza',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              gap,
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Short tasting notes or description',
                ),
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              gap,
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://…',
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: Text(widget.isEditing ? 'Save changes' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */