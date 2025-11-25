/// Resultado del análisis de imagen de vino usando AI
class WineAnalysisResult {
  final bool isWine;
  final String? name;
  final String? year;
  final String? grapes;
  final String? country;
  final String? region;
  final String? description;
  final double confidence; // 0.0 - 1.0
  final String? errorMessage;

  const WineAnalysisResult({
    required this.isWine,
    this.name,
    this.year,
    this.grapes,
    this.country,
    this.region,
    this.description,
    this.confidence = 0.0,
    this.errorMessage,
  });

  /// Crea un resultado de error
  factory WineAnalysisResult.error(String message) {
    return WineAnalysisResult(
      isWine: false,
      confidence: 0.0,
      errorMessage: message,
    );
  }

  /// Crea un resultado cuando no es un vino
  factory WineAnalysisResult.notWine() {
    return const WineAnalysisResult(
      isWine: false,
      confidence: 0.0,
    );
  }

  bool get hasData =>
      name != null ||
      year != null ||
      grapes != null ||
      country != null ||
      region != null ||
      description != null;

  @override
  String toString() {
    return 'WineAnalysisResult(isWine: $isWine, name: $name, year: $year, '
        'grapes: $grapes, country: $country, region: $region, confidence: $confidence)';
  }
}
