// lib/presentation/screens/add_edit_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/wine.dart';
import '../../config/api_keys.dart';
import 'package:wine_app/presentation/viewmodels/notifiers/wines_viewmodel.dart';
import 'package:wine_app/presentation/viewmodels/add_edit_wine_viewmodel.dart';

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

    // Inicializar el ViewModel según el modo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit) {
        // Modo edición: cargar imagen existente
        final w = widget.initialWine!;
        ref.read(addEditWineProvider.notifier).initializeWithImage(w.pictureUrl);
      } else {
        // Modo agregar nuevo: limpiar completamente el estado
        ref.read(addEditWineProvider.notifier).reset();
      }
    });

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
    // Resetear el estado del ViewModel al salir
    ref.read(addEditWineProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Generar ID temporal para el vino nuevo
    final wineId = isEdit
        ? widget.initialWine!.id
        : DateTime.now().microsecondsSinceEpoch.toString();

    // Subir imagen si hay una seleccionada
    final imageViewModel = ref.read(addEditWineProvider.notifier);
    final imageUrl = await imageViewModel.uploadImage(wineId: wineId);

    // Si hubo un error subiendo la imagen, mostrar mensaje
    final imageState = ref.read(addEditWineProvider);
    if (imageState.imageState == WineImageState.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(imageState.errorMessage ?? 'Error al subir imagen')),
      );
      return;
    }

    final wine = Wine(
      id: wineId,
      name: _nameCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      grapes: _grapesCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      region: _regionCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      pictureUrl: imageUrl,
    );

    final winesVm = ref.read(winesViewModelProvider.notifier);
    if (isEdit) {
      await winesVm.updateWine(wine);
    } else {
      await winesVm.addWine(wine);
    }

    if (mounted) context.pop(true); // devolvemos "hubo cambios"
  }

  Future<void> _pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (image != null) {
      ref.read(addEditWineProvider.notifier).setLocalImage(image.path);
      // Analizar la imagen automáticamente
      await _analyzeImage();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (image != null) {
      ref.read(addEditWineProvider.notifier).setLocalImage(image.path);
      // Analizar la imagen automáticamente
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    final result = await ref.read(addEditWineProvider.notifier).analyzeImage(ApiKeys.geminiApiKey);
    
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo analizar la imagen')),
      );
      return;
    }

    if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
      return;
    }

    if (!result.isWine) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se detectó un vino en la imagen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Autocompletar campos si se detectó un vino
    if (result.hasData) {
      if (result.name != null) _nameCtrl.text = result.name!;
      if (result.year != null) _yearCtrl.text = result.year!;
      if (result.grapes != null) _grapesCtrl.text = result.grapes!;
      if (result.country != null) _countryCtrl.text = result.country!;
      if (result.region != null) _regionCtrl.text = result.region!;
      if (result.description != null) _descCtrl.text = result.description!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Vino detectado! Confianza: ${(result.confidence * 100).toStringAsFixed(0)}%'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(addEditWineProvider);
    
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
              // Preview de imagen
              _buildImagePreview(imageState),
              const SizedBox(height: 16),
              
              // Botones para seleccionar imagen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      onPressed: (imageState.isUploading || imageState.isAnalyzing) 
                          ? null 
                          : _pickImageFromCamera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      onPressed: (imageState.isUploading || imageState.isAnalyzing) 
                          ? null 
                          : _pickImageFromGallery,
                    ),
                  ),
                ],
              ),
              
              // Indicador de análisis
              if (imageState.isAnalyzing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      const Text('Analizando imagen con IA...'),
                    ],
                  ),
                ),

              // Mostrar resultado del análisis
              if (imageState.hasAnalysisResult)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¡Vino detectado! Campos autocompletados',
                            style: TextStyle(color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (imageState.hasImage)
                TextButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar imagen'),
                  onPressed: (imageState.isUploading || imageState.isAnalyzing) 
                      ? null 
                      : () => ref.read(addEditWineProvider.notifier).removeImage(),
                ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
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
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: (imageState.isUploading || imageState.isAnalyzing)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(imageState.isAnalyzing
                    ? 'Analizando...'
                    : imageState.isUploading 
                        ? 'Subiendo imagen...' 
                        : (isEdit ? 'Save changes' : 'Add')),
                onPressed: (imageState.isUploading || imageState.isAnalyzing) ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(AddEditWineState imageState) {
    if (!imageState.hasImage) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wine_bar, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('Sin imagen', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: imageState.localImagePath != null
                  ? FileImage(File(imageState.localImagePath!))
                  : NetworkImage(imageState.imageUrl!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (imageState.isUploading || imageState.isAnalyzing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      imageState.isAnalyzing ? 'Analizando con IA...' : 'Subiendo...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

