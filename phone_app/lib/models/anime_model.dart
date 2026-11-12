class AnimeModel {
  final int id;
  final String title;
  final String? titleEnglish;
  final String? imageUrl;
  final double score;
  final int? episodes;
  final String? synopsis;
  final String? status;
  final List<String> genres;

  AnimeModel({
    required this.id,
    required this.title,
    this.titleEnglish,
    this.imageUrl,
    required this.score,
    this.episodes,
    this.synopsis,
    this.status,
    this.genres = const [],
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] != null && json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }

    String? img;
    if (json['images'] != null && json['images']['jpg'] != null) {
      img = json['images']['jpg']['large_image_url'] ??
          json['images']['jpg']['image_url'];
    }

    double parsedScore = 0.0;
    if (json['score'] != null) {
      if (json['score'] is num) {
        parsedScore = (json['score'] as num).toDouble();
      }
    }

    int parsedId = 0;
    final rawId = json['mal_id'] ?? json['id'];
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    }

    return AnimeModel(
      id: parsedId,
      title: json['title']?.toString() ?? 'Sin título',
      titleEnglish: json['title_english']?.toString(),
      imageUrl: img,
      score: parsedScore,
      episodes: json['episodes'] is int ? json['episodes'] : null,
      synopsis: json['synopsis']?.toString(),
      status: json['status']?.toString(),
      genres: parsedGenres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_english': titleEnglish,
      'image_url': imageUrl,
      'score': score,
      'episodes': episodes,
      'synopsis': synopsis,
      'status': status,
      'genres': genres,
    };
  }
}
