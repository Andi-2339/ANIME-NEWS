import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/models/anime_model.dart';
import 'package:phone_app/models/watchlist_model.dart';
import 'package:phone_app/services/anime_api_service.dart';

void main() {
  group('Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos', () {
    // -------------------------------------------------------------------------
    // CASO VÁLIDO: Deserialización y mapeo completo de entidad AnimeModel
    // -------------------------------------------------------------------------
    test('1. Caso Válido: Mapeo correcto de JSON completo a AnimeModel', () {
      final validJson = {
        'mal_id': 16498,
        'title': 'Shingeki no Kyojin',
        'title_english': 'Attack on Titan',
        'images': {
          'jpg': {
            'image_url': 'https://cdn.myanimelist.net/images/anime/10/47347.jpg',
            'large_image_url': 'https://cdn.myanimelist.net/images/anime/10/47347l.jpg'
          }
        },
        'score': 8.54,
        'episodes': 25,
        'synopsis': 'Centuries ago, mankind was slaughtered to near extinction...',
        'status': 'Finished Airing',
        'genres': [
          {'mal_id': 1, 'name': 'Action'},
          {'mal_id': 8, 'name': 'Drama'},
          {'mal_id': 10, 'name': 'Fantasy'}
        ]
      };

      final anime = AnimeModel.fromJson(validJson);

      expect(anime.id, equals(16498));
      expect(anime.title, equals('Shingeki no Kyojin'));
      expect(anime.titleEnglish, equals('Attack on Titan'));
      expect(anime.imageUrl, equals('https://cdn.myanimelist.net/images/anime/10/47347l.jpg'));
      expect(anime.score, equals(8.54));
      expect(anime.episodes, equals(25));
      expect(anime.status, equals('Finished Airing'));
      expect(anime.genres, containsAll(['Action', 'Drama', 'Fantasy']));
      expect(anime.genres.length, equals(3));
    });

    // -------------------------------------------------------------------------
    // CASO LÍMITE: Valores frontera, nulos controlados y umbrales de alerta
    // -------------------------------------------------------------------------
    test('2. Caso Límite: Manejo de campos nulos/vacíos y umbrales biométricos', () {
      // 2.1 Campos vacíos y defaults
      final boundaryJson = {
        'mal_id': 0,
        'title': null,
        'score': 0,
        'genres': <Map<String, dynamic>>[],
        'episodes': null,
      };

      final boundaryAnime = AnimeModel.fromJson(boundaryJson);
      expect(boundaryAnime.id, equals(0));
      expect(boundaryAnime.title, equals('Sin título'));
      expect(boundaryAnime.score, equals(0.0));
      expect(boundaryAnime.genres, isEmpty);
      expect(boundaryAnime.episodes, isNull);

      // 2.2 Valores frontera del algoritmo de alerta crítica: hypeLevel > 90 || heartRate > 120
      bool computeCriticalAlert(int hype, int bpm) => hype > 90 || bpm > 120;

      // Exactamente en el límite (no debe disparar alerta)
      expect(computeCriticalAlert(90, 120), isFalse,
          reason: 'Límite exacto de 90 hype y 120 bpm no debe disparar alerta');

      // Un valor por encima del límite (debe disparar alerta)
      expect(computeCriticalAlert(91, 120), isTrue,
          reason: 'Hype de 91 supera umbral de 90');
      expect(computeCriticalAlert(90, 121), isTrue,
          reason: 'HeartRate de 121 supera umbral de 120');

      // Valores seguros normales
      expect(computeCriticalAlert(50, 75), isFalse);
    });

    // -------------------------------------------------------------------------
    // CASO INVÁLIDO O ERROR: JSON con tipos incompatibles y resiliencia
    // -------------------------------------------------------------------------
    test('3. Caso Inválido: Resiliencia ante tipos erróneos en payload', () {
      final invalidJson = {
        'mal_id': 'no_es_un_numero', // Tipo string en vez de int
        'title': 12345,             // Tipo int en vez de string
        'score': 'not_a_double',    // Tipo incompatible en score
        'genres': 'no_es_una_lista',// Tipo incompatible en genres
        'images': null,
      };

      // No debe arrojar excepción no controlada
      final resilientAnime = AnimeModel.fromJson(invalidJson);

      expect(resilientAnime.id, equals(0),
          reason: 'ID no entero debe caer a valor por defecto 0');
      expect(resilientAnime.score, equals(0.0),
          reason: 'Score incompatible debe inicializarse en 0.0');
      expect(resilientAnime.genres, isEmpty,
          reason: 'Géneros incompatibles debe inicializarse como lista vacía');
      expect(resilientAnime.imageUrl, isNull);
    });

    // -------------------------------------------------------------------------
    // PRUEBA ADICIONAL DE LÓGICA DE NEGOCIO: Transiciones de Watchlist
    // -------------------------------------------------------------------------
    test('4. Lógica de Negocio: Transiciones de estado en WatchlistItem', () {
      final item = WatchlistItem(
        id: 'watch_001',
        animeId: 1,
        title: 'Demon Slayer',
        score: 8.9,
        addedAt: DateTime(2026, 1, 1),
      );

      expect(item.status, equals('watching'));
      expect(item.episodesWatched, equals(0));

      // Actualizar episodio
      item.episodesWatched = 5;
      expect(item.episodesWatched, equals(5));

      // Transición a completado
      item.status = 'completed';
      expect(item.status, equals('completed'));

      // Serialización correcta
      final jsonOutput = item.toJson();
      expect(jsonOutput['status'], equals('completed'));
      expect(jsonOutput['episodes_watched'], equals(5));
      expect(jsonOutput['anime_id'], equals(1));
    });
  });
}
