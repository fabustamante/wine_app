import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/wine_analysis_result.dart';

/// Servicio para analizar imágenes de vino usando Google Gemini AI
class WineImageAnalysisService {
  final String apiKey;
  late final GenerativeModel _model;

  WineImageAnalysisService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Analiza una imagen para detectar si es un vino y extraer información
  Future<WineAnalysisResult> analyzeWineImage(String imagePath) async {
    try {
      // Leer la imagen como bytes
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return WineAnalysisResult.error('La imagen no existe');
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Crear el prompt para Gemini
      const prompt = '''
Analiza esta imagen y determina si es una botella de vino o una etiqueta de vino.

Si ES un vino, extrae la siguiente información en formato JSON exacto:
{
  "isWine": true,
  "name": "nombre completo del vino",
  "year": "año de cosecha (solo números, ejemplo: 2020)",
  "grapes": "variedad de uva (ejemplo: Malbec, Cabernet Sauvignon, etc.)",
  "country": "país de origen",
  "region": "región vitivinícola",
  "description": "descripción breve del vino",
  "confidence": 0.95
}

Si NO es un vino, responde:
{
  "isWine": false,
  "confidence": 0.0
}

IMPORTANTE:
- Solo responde con el JSON, sin texto adicional
- Si no puedes identificar algún campo, usa null
- El año debe ser solo números (ejemplo: "2020", no "Cosecha 2020")
- La confianza debe ser un número entre 0.0 y 1.0
''';

      // Crear el contenido con la imagen
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generar la respuesta
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      if (responseText.isEmpty) {
        return WineAnalysisResult.error('No se pudo analizar la imagen');
      }

      // Parsear el JSON de la respuesta
      return _parseResponse(responseText);
    } catch (e) {
      return WineAnalysisResult.error('Error al analizar imagen: $e');
    }
  }

  /// Parsea la respuesta de Gemini a WineAnalysisResult
  WineAnalysisResult _parseResponse(String responseText) {
    try {
      // Limpiar la respuesta (a veces Gemini incluye ```json o ``` al inicio/final)
      String cleanedJson = responseText.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      }
      if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      cleanedJson = cleanedJson.trim();

      // Parsear manualmente el JSON simple
      final isWineMatch = RegExp(r'"isWine"\s*:\s*(true|false)').firstMatch(cleanedJson);
      final isWine = isWineMatch?.group(1) == 'true';

      if (!isWine) {
        return WineAnalysisResult.notWine();
      }

      // Extraer campos usando RegExp
      final name = _extractField(cleanedJson, 'name');
      final year = _extractField(cleanedJson, 'year');
      final grapes = _extractField(cleanedJson, 'grapes');
      final country = _extractField(cleanedJson, 'country');
      final region = _extractField(cleanedJson, 'region');
      final description = _extractField(cleanedJson, 'description');
      
      final confidenceMatch = RegExp(r'"confidence"\s*:\s*([0-9.]+)').firstMatch(cleanedJson);
      final confidence = double.tryParse(confidenceMatch?.group(1) ?? '0.5') ?? 0.5;

      return WineAnalysisResult(
        isWine: true,
        name: name,
        year: year,
        grapes: grapes,
        country: country,
        region: region,
        description: description,
        confidence: confidence,
      );
    } catch (e) {
      return WineAnalysisResult.error('Error al procesar la respuesta: $e');
    }
  }

  /// Extrae un campo del JSON usando RegExp
  String? _extractField(String json, String fieldName) {
    final pattern = RegExp('"$fieldName"\\s*:\\s*"([^"]*)"');
    final match = pattern.firstMatch(json);
    final value = match?.group(1);
    return (value == null || value.isEmpty || value.toLowerCase() == 'null') 
        ? null 
        : value;
  }
}
