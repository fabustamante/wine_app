// lib/domain/wine.dart
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
}

/* class Wine {
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
}

List<Wine> winesList = [
  Wine(
    id: '1',
    name: 'Chateau Margaux',
    year: '2015',
    grapes: 'Cabernet Sauvignon, Merlot',
    country: 'France',
    region: 'Bordeaux',
    description:
        'A rich and complex wine with notes of blackberry, plum, and oak.',
    pictureUrl:
        'https://www.wine-searcher.com/images/labels/48/46/10934846.jpg',
  ),
  Wine(
    id: '2',
    name: 'Screaming Eagle',
    year: '2016',
    grapes: 'Cabernet Sauvignon',
    country: 'USA',
    region: 'Napa Valley',
    description:
        'An exquisite wine with flavors of dark fruit, chocolate, and spice.',
    pictureUrl:
        'https://www.wine-searcher.com/images/labels/90/78/10399078.jpg',
  ),
  // Add more sample wines as needed
]; */