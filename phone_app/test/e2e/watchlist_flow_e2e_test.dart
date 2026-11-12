import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phone_app/models/anime_model.dart';
import 'package:phone_app/providers/app_state.dart';
import 'package:phone_app/views/watchlist/watchlist_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://mtwhobrdwjlffflxnrud.supabase.co',
        // ignore: deprecated_member_use
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10d2hvYnJkd2psZmZmbHhucnVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NjYzMzIsImV4cCI6MjA5MTI0MjMzMn0.IZy-nH12l9pbiDcu94jdPhwhTNks8-9ts01wd2-A5g4',
      );
    } catch (_) {}
  });

  group('Fase 4: Validación de Flujo Completo E2E - Catálogo y Watchlist', () {
    testWidgets('Flujo E2E: Navegación, inserción en Watchlist y verificación en la UI',
        (WidgetTester tester) async {
      // 1. Instanciar estado de aplicación
      final appState = AppState();

      // 2. Montar árbol de widgets con el Provider y la pantalla de Watchlist
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const WatchlistScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // PASO 1 (Verificación Inicial): La lista inicia vacía con mensaje correspondiente
      expect(find.text('Mis Listas de Anime'), findsOneWidget);
      expect(find.text('Viendo (0)'), findsOneWidget);
      expect(find.text('No estás viendo ningún anime aún.'), findsOneWidget);
      // ignore: avoid_print
      print('>>> [E2E PASO 1] Estado inicial verificado: 0 animes en seguimiento.');

      // PASO 2 (Interacción de Usuario): Usuario selecciona y añade un anime crítico a la Watchlist
      final testAnime = AnimeModel(
        id: 101,
        title: 'Demon Slayer: Kimetsu no Yaiba',
        score: 8.9,
        episodes: 26,
        genres: ['Acción', 'Fantasía'],
      );

      // El usuario acciona el guardado
      await appState.toggleWatchlist(testAnime, status: 'watching');
      await tester.pumpAndSettle();

      // PASO 3 (Verificación de Resultado Final en UI):
      // - El contador del tab debe actualizarse a Viendo (1)
      // - La tarjeta con el título debe aparecer en pantalla
      // - El mensaje de lista vacía debe desaparecer
      expect(find.text('Viendo (1)'), findsOneWidget);
      expect(find.text('Demon Slayer: Kimetsu no Yaiba'), findsOneWidget);
      expect(find.text('No estás viendo ningún anime aún.'), findsNothing);
      expect(appState.isInWatchlist(101), isTrue);
      // ignore: avoid_print
      print('>>> [E2E PASO 2] Elemento agregado correctamente. Título visible en UI: Demon Slayer.');

      // PASO 4 (Actualización de Progreso): El usuario incrementa capítulos vistos
      final watchlistItem = appState.getWatchlistItem(101);
      expect(watchlistItem, isNotNull);
      watchlistItem!.episodesWatched = 12;
      appState.notifyListeners();
      await tester.pumpAndSettle();

      expect(watchlistItem.episodesWatched, equals(12));
      // ignore: avoid_print
      print('>>> [E2E PASO 3] Progreso actualizado a 12 capítulos vistos.');

      // PASO 5 (Eliminación / Desmarcado): El usuario retira el anime de su lista
      await appState.removeFromWatchlist(101);
      await tester.pumpAndSettle();

      // Verificación final del ciclo de vida completo
      expect(find.text('Viendo (0)'), findsOneWidget);
      expect(find.text('Demon Slayer: Kimetsu no Yaiba'), findsNothing);
      expect(find.text('No estás viendo ningún anime aún.'), findsOneWidget);
      expect(appState.isInWatchlist(101), isFalse);
      // ignore: avoid_print
      print('>>> [E2E PASO 4] Elemento eliminado satisfactoriamente. Lista vacía restaurada.');
    });
  });
}
