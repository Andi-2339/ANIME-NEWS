import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class AnimeApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  // [Práctica 12 - Optimización Fase 6]: Caché en memoria con TTL de 5 minutos
  // para reducir peticiones HTTP redundantes y disminuir latencia en lecturas repetidas.
  static List<AnimeModel>? _cachedTopAnime;
  static DateTime? _lastCacheTime;
  static const Duration _cacheTtl = Duration(minutes: 5);

  static void clearCache() {
    _cachedTopAnime = null;
    _lastCacheTime = null;
  }

  // Fallback curado para demostración offline o rate-limits de Jikan
  static final List<AnimeModel> _fallbackCatalog = [
    AnimeModel(
      id: 1,
      title: 'Demon Slayer: Kimetsu no Yaiba',
      titleEnglish: 'Demon Slayer',
      score: 8.9,
      episodes: 26,
      status: 'Finalizado',
      genres: ['Acción', 'Fantasía', 'Shonen'],
      synopsis:
          'Tanjiro Kamado lucha para salvar a su hermana Nezuko, convertida en demonio, y vengar a su familia enfrentándose a los Doce Kizuki.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1286/99889l.jpg',
    ),
    AnimeModel(
      id: 2,
      title: 'Jujutsu Kaisen',
      titleEnglish: 'Jujutsu Kaisen',
      score: 8.8,
      episodes: 24,
      status: 'Finalizado',
      genres: ['Acción', 'Sobrenatural', 'Shonen'],
      synopsis:
          'Yuji Itadori ingiere un dedo maldito de Ryomen Sukuna y entra al mundo de los hechiceros de Tokyo Jujutsu High.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1171/109222l.jpg',
    ),
    AnimeModel(
      id: 3,
      title: 'One Piece',
      titleEnglish: 'One Piece',
      score: 9.1,
      episodes: 1100,
      status: 'En emisión',
      genres: ['Aventura', 'Comedia', 'Shonen'],
      synopsis:
          'Monkey D. Luffy y los Piratas de Sombrero de Paja recorren el Grand Line en busca del legendario tesoro One Piece.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1244/138851l.jpg',
    ),
    AnimeModel(
      id: 4,
      title: 'Solo Leveling (Ore dake Level Up na Ken)',
      titleEnglish: 'Solo Leveling',
      score: 8.6,
      episodes: 12,
      status: 'Finalizado',
      genres: ['Acción', 'Fantasía', 'Aventura'],
      synopsis:
          'En un mundo donde cazadores despiertan habilidades mágicas, Sung Jin-woo, el cazador más débil de rango E, recibe un sistema de juego misterioso.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1841/140685l.jpg',
    ),
    AnimeModel(
      id: 5,
      title: 'Bleach: Sennen Kessen-hen',
      titleEnglish: 'Bleach: Thousand-Year Blood War',
      score: 9.0,
      episodes: 13,
      status: 'Finalizado',
      genres: ['Acción', 'Aventura', 'Sobrenatural'],
      synopsis:
          'La paz en la Sociedad de Almas se quiebra con la invasión del Wandenreich, liderado por Yhwach.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1764/126627l.jpg',
    ),
    AnimeModel(
      id: 6,
      title: 'Attack on Titan (Shingeki no Kyojin)',
      titleEnglish: 'Attack on Titan Final Season',
      score: 9.0,
      episodes: 28,
      status: 'Finalizado',
      genres: ['Acción', 'Drama', 'Misterio'],
      synopsis:
          'Eren Jaeger y la Legión de Reconocimiento cruzan el mar hacia Marley para descubrir los secretos de la humanidad.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1000/110531l.jpg',
    ),
    AnimeModel(
      id: 7,
      title: 'Chainsaw Man',
      titleEnglish: 'Chainsaw Man',
      score: 8.5,
      episodes: 12,
      status: 'Finalizado',
      genres: ['Acción', 'Gore', 'Sobrenatural'],
      synopsis:
          'Denji vive una vida de miseria pagando las deudas de su padre cazando demonios junto a Pochita, el demonio motosierra.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1806/126216l.jpg',
    ),
    AnimeModel(
      id: 8,
      title: 'Frieren: Beyond Journey\'s End',
      titleEnglish: 'Sousou no Frieren',
      score: 9.3,
      episodes: 28,
      status: 'Finalizado',
      genres: ['Aventura', 'Drama', 'Fantasía'],
      synopsis:
          'La maga elfa Frieren reflexiona sobre el significado de las vidas humanas tras la derrota del Rey Demonio y la muerte de sus compañeros.',
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1015/138075l.jpg',
    ),
  ];

  Future<List<AnimeModel>> getTopAnime({int limit = 15, bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedTopAnime != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheTtl &&
        _cachedTopAnime!.length >= limit) {
      return _cachedTopAnime!.take(limit).toList();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/top/anime?limit=$limit'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] as List)
            .map((item) => AnimeModel.fromJson(item))
            .toList();
        _cachedTopAnime = list;
        _lastCacheTime = DateTime.now();
        return list;
      }
    } catch (e) {
      debugPrint('[AnimeApiService] Top anime fallback activado: $e');
    }
    return _fallbackCatalog;
  }

  Future<List<AnimeModel>> searchAnime(String query) async {
    if (query.trim().isEmpty) return getTopAnime();

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final response = await http
          .get(
            Uri.parse('$_baseUrl/anime?q=$encodedQuery&limit=15&sfw=true'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] as List)
            .map((item) => AnimeModel.fromJson(item))
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('[AnimeApiService] Error buscando anime: $e');
    }

    // Filtrar localmente el catálogo fallback
    final q = query.toLowerCase();
    return _fallbackCatalog
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            (a.titleEnglish != null && a.titleEnglish!.toLowerCase().contains(q)) ||
            a.genres.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }
}
