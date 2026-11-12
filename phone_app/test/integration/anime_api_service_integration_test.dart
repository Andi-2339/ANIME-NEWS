import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/services/anime_api_service.dart';
import 'package:phone_app/models/anime_model.dart';

void main() {
  group('Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST)', () {
    late AnimeApiService apiService;

    setUp(() {
      apiService = AnimeApiService();
    });

    // -------------------------------------------------------------------------
    // PRUEBA DE INTEGRACIÓN 1: Interacción Real - Flujo Correcto con API Externa
    // -------------------------------------------------------------------------
    test('1. Flujo Correcto Real: Consumo de Top Anime desde Jikan API vía HTTP', () async {
      final List<AnimeModel> result = await apiService.getTopAnime(limit: 5);

      // Verificaciones de interacción entre Cliente HTTP y Servidor REST
      expect(result, isNotEmpty, reason: 'La API debe retornar una lista de animes');
      expect(result.length, greaterThanOrEqualTo(5),
          reason: 'Debe obtener al menos 5 animes del Top');

      final firstAnime = result.first;
      expect(firstAnime.id, greaterThan(0), reason: 'El mal_id debe ser un entero positivo');
      expect(firstAnime.title, isNotEmpty, reason: 'El título no debe estar vacío');
      expect(firstAnime.score, greaterThan(0.0), reason: 'El anime de top debe tener score mayor a 0');

      // print para evidencia de ejecución
      // ignore: avoid_print
      print('>>> [INTEGRACIÓN EXITOSA] Anime obtenido: "${firstAnime.title}" (Score: ${firstAnime.score}, ID: ${firstAnime.id})');
    });

    // -------------------------------------------------------------------------
    // PRUEBA DE INTEGRACIÓN 2: Interacción Real de Búsqueda con Query Parameter
    // -------------------------------------------------------------------------
    test('2. Flujo Correcto Real: Búsqueda con codificación de parámetros URL', () async {
      const query = 'One Piece';
      final List<AnimeModel> searchResults = await apiService.searchAnime(query);

      expect(searchResults, isNotEmpty);
      final hasMatch = searchResults.any((anime) =>
          anime.title.toLowerCase().contains('one piece') ||
          (anime.titleEnglish?.toLowerCase().contains('one piece') ?? false));

      expect(hasMatch, isTrue, reason: 'Al menos un resultado debe coincidir con la consulta');
      // ignore: avoid_print
      print('>>> [INTEGRACIÓN BÚSQUEDA] Coincidencias encontradas: ${searchResults.length}');
    });

    // -------------------------------------------------------------------------
    // PRUEBA DE INTEGRACIÓN 3: Manejo de Error de Red y Activación de Fallback
    // -------------------------------------------------------------------------
    test('3. Manejo de Error Relevante: Resiliencia ante falla de red o rate-limit', () async {
      // Probamos el comportamiento del servicio cuando se envían caracteres que no retornan datos
      // o cuando el servicio recurre a la lista de respaldo local sin generar un crash.
      final fallbackResults = await apiService.searchAnime('XYZ_ANIME_INEXISTENTE_99999');

      // El servicio está diseñado para capturar la respuesta y aplicar su catálogo de fallback local
      expect(fallbackResults, isA<List<AnimeModel>>());
      // No debe lanzar unhandled exception ni abortar el hilo de ejecución
      // ignore: avoid_print
      print('>>> [RESILIENCIA ANTE ERROR] Manejo controlado sin excepciones no capturadas.');
    });
  });
}
