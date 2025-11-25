import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/wine_analysis_result.dart';
import '../../services/wine_image_analysis_service.dart';
import 'profile_viewmodel.dart'; // Para usar firebaseStorageServiceProvider

/// Estados del proceso de gestión de imágenes de vinos
enum WineImageState {
  idle,
  analyzing, // Nuevo estado para análisis con AI
  uploading,
  success,
  error,
}

/// Estado del ViewModel de AddEditWine
class AddEditWineState {
  final WineImageState imageState;
  final String? imageUrl;
  final String? localImagePath;
  final String? errorMessage;
  final WineAnalysisResult? analysisResult; // Resultado del análisis AI

  const AddEditWineState({
    this.imageState = WineImageState.idle,
    this.imageUrl,
    this.localImagePath,
    this.errorMessage,
    this.analysisResult,
  });

  bool get hasImage => imageUrl != null || localImagePath != null;
  bool get isUploading => imageState == WineImageState.uploading;
  bool get isAnalyzing => imageState == WineImageState.analyzing;
  bool get hasAnalysisResult => analysisResult != null && analysisResult!.isWine;

  AddEditWineState copyWith({
    WineImageState? imageState,
    String? imageUrl,
    String? localImagePath,
    String? errorMessage,
    WineAnalysisResult? analysisResult,
  }) {
    return AddEditWineState(
      imageState: imageState ?? this.imageState,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
      analysisResult: analysisResult ?? this.analysisResult,
    );
  }
}

/// ViewModel para la pantalla de agregar/editar vino
class AddEditWineNotifier extends Notifier<AddEditWineState> {
  @override
  AddEditWineState build() {
    return const AddEditWineState();
  }

  /// Inicializa el estado con una URL de imagen existente (para edición)
  void initializeWithImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      state = AddEditWineState(imageUrl: imageUrl);
    }
  }

  /// Establece la imagen local seleccionada (antes de subirla)
  void setLocalImage(String imagePath) {
    state = state.copyWith(
      localImagePath: imagePath,
      imageState: WineImageState.idle,
      errorMessage: null,
    );
  }

  /// Sube la imagen local a Firebase Storage
  /// Retorna la URL si tiene éxito, null si falla
  Future<String?> uploadImage({required String wineId}) async {
    if (state.localImagePath == null) {
      return state.imageUrl; // Retorna la URL existente si no hay imagen nueva
    }

    state = state.copyWith(imageState: WineImageState.uploading);

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      
      // Subir la imagen
      final imageUrl = await storageService.uploadWineImage(
        imagePath: state.localImagePath!,
        wineId: wineId,
      );

      // Eliminar imagen anterior si existe y es diferente
      if (state.imageUrl != null && state.imageUrl != imageUrl) {
        storageService.deleteWineImage(state.imageUrl!).catchError((e) => null);
      }

      state = AddEditWineState(
        imageState: WineImageState.success,
        imageUrl: imageUrl,
      );

      return imageUrl;
    } catch (e) {
      state = state.copyWith(
        imageState: WineImageState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Elimina la imagen actual (local o remota)
  void removeImage() {
    final oldImageUrl = state.imageUrl;
    
    state = const AddEditWineState();

    // Si había una imagen remota, intentar eliminarla
    if (oldImageUrl != null) {
      final storageService = ref.read(firebaseStorageServiceProvider);
      storageService.deleteWineImage(oldImageUrl).catchError((e) => null);
    }
  }

  /// Resetea completamente el estado (sin eliminar imágenes remotas)
  void reset() {
    state = const AddEditWineState();
  }

  /// Analiza la imagen local usando AI para extraer información del vino
  /// Retorna el resultado del análisis
  Future<WineAnalysisResult?> analyzeImage(String apiKey) async {
    if (state.localImagePath == null) {
      return null;
    }

    state = state.copyWith(imageState: WineImageState.analyzing);

    try {
      final analysisService = WineImageAnalysisService(apiKey: apiKey);
      final result = await analysisService.analyzeWineImage(state.localImagePath!);

      if (result.errorMessage != null) {
        state = state.copyWith(
          imageState: WineImageState.error,
          errorMessage: result.errorMessage,
        );
        return result;
      }

      state = state.copyWith(
        imageState: WineImageState.idle,
        analysisResult: result,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        imageState: WineImageState.error,
        errorMessage: 'Error al analizar imagen: $e',
      );
      return null;
    }
  }
}

// Provider del servicio de análisis (requiere API key)
// Nota: La API key se debería obtener de forma segura (ver Paso 6)
final wineAnalysisServiceProvider = Provider<WineImageAnalysisService>((ref) {
  // TODO: Obtener API key de forma segura
  const apiKey = 'TU_API_KEY_AQUI'; // Placeholder
  return WineImageAnalysisService(apiKey: apiKey);
});

final addEditWineProvider = NotifierProvider<AddEditWineNotifier, AddEditWineState>(
  AddEditWineNotifier.new,
);
