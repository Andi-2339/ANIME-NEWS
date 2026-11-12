import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/watchlist_model.dart';

class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Session? get currentSession => client.auth.currentSession;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ─── Autenticación ──────────────────────────────────────────────────────────

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Error en signIn: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'full_name': displayName} : null,
      );

      // Crear entrada en tabla 'perfiles' si el registro fue exitoso
      if (response.user != null) {
        try {
          await client.from('perfiles').upsert({
            'id': response.user!.id,
            'email': email.trim(),
            'activo': true,
            'rol': 'user',
            'fecha_creacion': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (pe) {
          debugPrint('[SupabaseService] Perfil upsert opcional: $pe');
        }
      }

      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Error en signUp: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('[SupabaseService] Error en signOut: $e');
      rethrow;
    }
  }

  // ─── Sincronización de Dispositivos (Smart TV & Wearable) ────────────────────

  Future<void> updateDeviceSync({
    required int heartRate,
    required int hypeLevel,
    required int episodes,
    required bool criticalAlert,
    String? remoteCommand,
    int? selectedCard,
  }) async {
    final payload = <String, dynamic>{
      'id': 1,
      'heart_rate': heartRate,
      'hype_level': hypeLevel,
      'episodes': episodes,
      'critical_alert': criticalAlert,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (remoteCommand != null) payload['remote_command'] = remoteCommand;
    if (selectedCard != null) payload['selected_card'] = selectedCard;

    try {
      await client.from('device_sync').upsert(payload);
    } catch (e) {
      // Fallback a campos estándar en caso de que las columnas opcionales no existan
      try {
        await client.from('device_sync').upsert({
          'id': 1,
          'heart_rate': heartRate,
          'hype_level': hypeLevel,
          'episodes': episodes,
          'critical_alert': criticalAlert,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (fallbackError) {
        debugPrint('[SupabaseService] Error en device_sync upsert: $fallbackError');
      }
    }
  }

  // ─── Watchlist en Supabase (con fallback seguro) ─────────────────────────────

  Future<List<WatchlistItem>> fetchWatchlist() async {
    if (!isAuthenticated) return [];
    try {
      final res = await client
          .from('watchlist')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      final list = (res as List)
          .map((item) => WatchlistItem.fromJson(item))
          .toList();
      return list;
    } catch (e) {
      debugPrint('[SupabaseService] Error al obtener watchlist: $e');
      return [];
    }
  }

  Future<void> saveWatchlistItem(WatchlistItem item) async {
    if (!isAuthenticated) return;
    // [Práctica 12 - Reto de Resiliencia]: Estrategia de Idempotencia mediante upsert
    // determinístico (user_id + anime_id) y reintento controlado con Exponential Backoff.
    final payload = {
      'user_id': currentUser!.id,
      'anime_id': item.animeId,
      'title': item.title,
      'image_url': item.imageUrl,
      'score': item.score,
      'status': item.status,
      'episodes_watched': item.episodesWatched,
      'total_episodes': item.totalEpisodes,
      'created_at': item.addedAt.toUtc().toIso8601String(),
    };

    const int maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await client.from('watchlist').upsert(payload);
        return;
      } catch (e) {
        debugPrint('[SupabaseService] Intento $attempt/$maxAttempts falló al guardar en watchlist: $e');
        if (attempt < maxAttempts) {
          // Espera progresiva (Exponential Backoff: 200ms, 400ms)
          await Future.delayed(Duration(milliseconds: 200 * (1 << (attempt - 1))));
        }
      }
    }
  }

  Future<void> removeWatchlistItem(int animeId) async {
    if (!isAuthenticated) return;
    try {
      await client
          .from('watchlist')
          .delete()
          .eq('user_id', currentUser!.id)
          .eq('anime_id', animeId);
    } catch (e) {
      debugPrint('[SupabaseService] Error al borrar de watchlist: $e');
    }
  }
}
