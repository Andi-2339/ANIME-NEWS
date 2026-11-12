import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/anime_model.dart';
import '../../providers/app_state.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  final List<String> _genres = [
    'Todos',
    'Acción',
    'Aventura',
    'Fantasía',
    'Shonen',
    'Sobrenatural',
    'Drama',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAnimeDetails(BuildContext context, AnimeModel anime) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<AppState>(
          builder: (context, appState, _) {
            final inList = appState.isInWatchlist(anime.id);

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: anime.imageUrl != null
                                ? Image.network(
                                    anime.imageUrl!,
                                    width: 100,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, stack) => _imagePlaceholder(),
                                  )
                                : _imagePlaceholder(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anime.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      anime.score > 0 ? '${anime.score}' : 'N/A',
                                      style: const TextStyle(
                                        color: kNeonGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (anime.episodes != null)
                                      Text(
                                        '${anime.episodes} eps',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (anime.status != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kPurple.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: kPurple),
                                    ),
                                    child: Text(
                                      anime.status!,
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        children: anime.genres
                            .map((g) => Chip(
                                  label: Text(g, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: const Color(0xFF333333),
                                  side: BorderSide.none,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sinopsis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kNeonGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        anime.synopsis ?? 'Sin descripción disponible para este título.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD1D5DB),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botón para agregar o quitar de watchlist
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            appState.toggleWatchlist(anime);
                          },
                          icon: Icon(
                            inList ? Icons.bookmark_remove : Icons.bookmark_add,
                            color: inList ? Colors.white : Colors.black,
                          ),
                          label: Text(
                            inList ? 'ELIMINAR DE MI LISTA' : 'GUARDAR EN MI LISTA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: inList ? Colors.white : Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inList ? Colors.red[800] : kNeonGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 140,
      color: Colors.grey[800],
      child: const Icon(Icons.movie_creation, color: Colors.grey, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera accesible con barra de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Catálogo de Anime',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: kNeonGreen),
                        tooltip: 'Recargar catálogo',
                        onPressed: () => appState.fetchCatalog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Input de búsqueda con altura ergonómica
                  TextField(
                    controller: _searchController,
                    onSubmitted: (query) => appState.searchCatalog(query),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar anime, shonen, autor...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: kNeonGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                appState.searchCatalog('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: kCardBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: kNeonGreen, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chips horizontales de categorías
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = appState.selectedGenre == genre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: kNeonGreen,
                      backgroundColor: kCardBg,
                      side: BorderSide(
                        color: isSelected ? kNeonGreen : Colors.grey[800]!,
                      ),
                      onSelected: (_) => appState.filterByGenre(genre),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Lista de Animes
            Expanded(
              child: appState.isLoadingCatalog
                  ? const Center(
                      child: CircularProgressIndicator(color: kNeonGreen),
                    )
                  : appState.catalog.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                'No se encontraron títulos.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  appState.searchCatalog('');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: kPurple),
                                child: const Text('Restablecer búsqueda', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: appState.catalog.length,
                          itemBuilder: (context, index) {
                            final anime = appState.catalog[index];
                            final inList = appState.isInWatchlist(anime.id);

                            return Card(
                              color: kCardBg,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: inList
                                      ? kNeonGreen.withValues(alpha: 0.6)
                                      : Colors.grey[850]!,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _showAnimeDetails(context, anime),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Poster thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: anime.imageUrl != null
                                            ? Image.network(
                                                anime.imageUrl!,
                                                width: 70,
                                                height: 95,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, error, stack) =>
                                                    _smallImagePlaceholder(),
                                              )
                                            : _smallImagePlaceholder(),
                                      ),
                                      const SizedBox(width: 14),
                                      // Metadatos
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              anime.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  anime.score > 0 ? '${anime.score}' : 'N/A',
                                                  style: const TextStyle(
                                                    color: kNeonGreen,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                if (anime.episodes != null)
                                                  Text(
                                                    '${anime.episodes} eps',
                                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            if (anime.genres.isNotEmpty)
                                              Text(
                                                anime.genres.take(3).join(' • '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Botón rápido de acción
                                      IconButton(
                                        icon: Icon(
                                          inList ? Icons.bookmark : Icons.bookmark_outline,
                                          color: inList ? kNeonGreen : Colors.grey,
                                          size: 26,
                                        ),
                                        tooltip: inList ? 'En tu lista' : 'Añadir a lista',
                                        onPressed: () => appState.toggleWatchlist(anime),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallImagePlaceholder() {
    return Container(
      width: 70,
      height: 95,
      color: Colors.grey[850],
      child: const Icon(Icons.movie, color: Colors.grey, size: 28),
    );
  }
}
