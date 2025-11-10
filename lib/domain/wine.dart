import 'package:floor/floor.dart';

@entity
class Wine {
  @primaryKey
  final String id;
  final String name;
  final String year;
  final String grapes;
  final String country;
  final String region;
  final String description;
  final String? pictureUrl;

  Wine({
    required this.id,
    required this.name,
    required this.year,
    required this.grapes,
    required this.country,
    required this.region,
    required this.description,
    this.pictureUrl,
  });

  Wine copyWith({
    String? id,
    String? name,
    String? year,
    String? grapes,
    String? country,
    String? region,
    String? description,
    String? pictureUrl,
  }) {
    return Wine(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      grapes: grapes ?? this.grapes,
      country: country ?? this.country,
      region: region ?? this.region,
      description: description ?? this.description,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'grapes': grapes,
        'country': country,
        'region': region,
        'description': description,
        'pictureUrl': pictureUrl,
      };

  factory Wine.fromJson(Map<String, dynamic> json) => Wine(
        id: json['id'] as String,
        name: json['name'] as String,
        year: json['year'] as String,
        grapes: json['grapes'] as String,
        country: json['country'] as String,
        region: json['region'] as String,
        description: json['description'] as String,
        pictureUrl: json['pictureUrl'] as String?,
      );
}
