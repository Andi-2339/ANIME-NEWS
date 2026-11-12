class WatchlistItem {
  final String id;
  final int animeId;
  final String title;
  final String? imageUrl;
  final double score;
  String status; // 'watching', 'favorite', 'completed'
  int episodesWatched;
  final int? totalEpisodes;
  final DateTime addedAt;

  WatchlistItem({
    required this.id,
    required this.animeId,
    required this.title,
    this.imageUrl,
    required this.score,
    this.status = 'watching',
    this.episodesWatched = 0,
    this.totalEpisodes,
    required this.addedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      animeId: json['anime_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? 'Sin título',
      imageUrl: json['image_url'],
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'watching',
      episodesWatched: json['episodes_watched'] ?? 0,
      totalEpisodes: json['total_episodes'],
      addedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anime_id': animeId,
      'title': title,
      'image_url': imageUrl,
      'score': score,
      'status': status,
      'episodes_watched': episodesWatched,
      'total_episodes': totalEpisodes,
      'created_at': addedAt.toIso8601String(),
    };
  }
}
