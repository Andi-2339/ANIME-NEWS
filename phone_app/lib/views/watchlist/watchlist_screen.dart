import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/watchlist_model.dart';
import '../../providers/app_state.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        title: const Text(
          'Mis Listas de Anime',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kNeonGreen,
          indicatorWeight: 3,
          labelColor: kNeonGreen,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: 'Viendo (${appState.watchingList.length})'),
            Tab(text: 'Favoritos (${appState.favoriteList.length})'),
            Tab(text: 'Completados (${appState.completedList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(appState.watchingList, appState, 'No estás viendo ningún anime aún.'),
          _buildList(appState.favoriteList, appState, 'No tienes animes favoritos guardados.'),
          _buildList(appState.completedList, appState, 'Aún no has completado ningún anime.'),
        ],
      ),
    );
  }

  Widget _buildList(List<WatchlistItem> items, AppState state, String emptyMsg) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ve a la pestaña Catálogo y pulsa el icono de marcador para añadir títulos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          color: kCardBg,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey[850]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 14),

                // Título y progreso
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
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
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.score > 0 ? '${item.score}' : 'N/A',
                            style: const TextStyle(
                              color: kNeonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Dropdown para cambiar estado
                          DropdownButton<String>(
                            value: item.status,
                            dropdownColor: const Color(0xFF2E2E2E),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: kNeonGreen, size: 18),
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                state.updateWatchlistStatus(item.animeId, newStatus);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'watching', child: Text('Viendo')),
                              DropdownMenuItem(value: 'favorite', child: Text('Favorito')),
                              DropdownMenuItem(value: 'completed', child: Text('Completado')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón eliminar
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Quitar de lista',
                  onPressed: () => state.removeFromWatchlist(item.animeId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 80,
      color: Colors.grey[800],
      child: const Icon(Icons.movie, color: Colors.grey, size: 24),
    );
  }
}
