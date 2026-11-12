import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/anime_model.dart';
import '../models/watchlist_model.dart';
import '../services/anime_api_service.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AnimeApiService _apiService = AnimeApiService();

  // ─── Estado de Autenticación ───────────────────────────────────────────────
  bool _isLoadingAuth = false;
  String? _authError;
  User? _currentUser;

  bool get isLoadingAuth => _isLoadingAuth;
  String? get authError => _authError;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // ─── Estado de Catálogo ────────────────────────────────────────────────────
  List<AnimeModel> _catalog = [];
  bool _isLoadingCatalog = false;
  String _selectedGenre = 'Todos';
  String _currentQuery = '';

  List<AnimeModel> get catalog {
    if (_selectedGenre == 'Todos') return _catalog;
    return _catalog
        .where((a) => a.genres.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase()))
        .toList();
  }

  bool get isLoadingCatalog => _isLoadingCatalog;
  String get selectedGenre => _selectedGenre;
  String get currentQuery => _currentQuery;

  // ─── Estado de Watchlist ───────────────────────────────────────────────────
  final List<WatchlistItem> _watchlist = [];
  List<WatchlistItem> get watchlist => List.unmodifiable(_watchlist);

  List<WatchlistItem> get watchingList =>
      _watchlist.where((item) => item.status == 'watching').toList();
  List<WatchlistItem> get favoriteList =>
      _watchlist.where((item) => item.status == 'favorite').toList();
  List<WatchlistItem> get completedList =>
      _watchlist.where((item) => item.status == 'completed').toList();

  // ─── Estado de Smart TV & Wearable ─────────────────────────────────────────
  String connectionStatus = 'Buscando BLE / Supabase...';
  int heartRate = 78;
  int hypeLevel = 65;
  int episodes = 12;
  bool criticalAlert = false;
  int tvSelectedCardIndex = 0;
  bool tvIsPlaying = true;

  // ─── Estado de Mensajería Multidispositivo y Roles (Prácticas 6 y 7) ────────
  final List<String> connectedDevices = const [
    'Dispositivo A: Smartphone (Administrador)',
    'Dispositivo B: Smart TV 10-Foot (Agente)',
    'Dispositivo C: Smartwatch Wear OS (Usuario 1)',
    'Dispositivo D: Portal Web PWA (Usuario 2)',
  ];
  String selectedSenderDevice = 'Dispositivo A: Smartphone (Administrador)';
  final List<Map<String, String>> deviceMessages = [
    {
      'sender': 'Dispositivo A: Smartphone (Administrador)',
      'text': 'Canal de sincronización iniciado. Reporte REP001 activo.',
      'timestamp': '18:00:00',
    },
  ];
  final Map<String, int> messageCountsByDevice = {
    'Dispositivo A: Smartphone (Administrador)': 1,
    'Dispositivo B: Smart TV 10-Foot (Agente)': 0,
    'Dispositivo C: Smartwatch Wear OS (Usuario 1)': 0,
    'Dispositivo D: Portal Web PWA (Usuario 2)': 0,
  };

  StreamSubscription? _bleScanSub;
  StreamSubscription? _supabaseSyncSub;

  AppState() {
    _initAuth();
    _initBleAndSync();
    fetchCatalog();
  }

  // ─── Inicialización Auth ───────────────────────────────────────────────────
  void _initAuth() {
    _currentUser = _supabaseService.currentUser;
    try {
      _supabaseService.authStateChanges.listen((data) {
        _currentUser = data.session?.user;
        if (_currentUser != null) {
          _loadUserWatchlist();
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[Auth State] Error o entorno desconectado: $e');
      });
    } catch (e) {
      debugPrint('[Auth State] Error al escuchar cambios de auth: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoadingAuth = true;
    _authError = null;
    notifyListeners();

    try {
      final res = await _supabaseService.signIn(email: email, password: password);
      _currentUser = res.user;
      _isLoadingAuth = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingAuth = false;
      _authError = _formatAuthError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? displayName}) async {
    _isLoadingAuth = true;
    _authError = null;
    notifyListeners();

    try {
      final res = await _supabaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _currentUser = res.user;
      _isLoadingAuth = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingAuth = false;
      _authError = _formatAuthError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
    _currentUser = null;
    _watchlist.clear();
    notifyListeners();
  }

  String _formatAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Credenciales inválidas. Verifica tu correo y contraseña.';
    } else if (error.contains('User already registered')) {
      return 'Este correo electrónico ya está registrado.';
    } else if (error.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'Error de autenticación. Intenta nuevamente.';
  }

  // ─── Catálogo & Búsqueda ───────────────────────────────────────────────────
  Future<void> fetchCatalog() async {
    _isLoadingCatalog = true;
    notifyListeners();

    _catalog = await _apiService.getTopAnime(limit: 20);
    _isLoadingCatalog = false;
    notifyListeners();
  }

  Future<void> searchCatalog(String query) async {
    _currentQuery = query;
    _isLoadingCatalog = true;
    notifyListeners();

    if (query.trim().isEmpty) {
      _catalog = await _apiService.getTopAnime(limit: 20);
    } else {
      _catalog = await _apiService.searchAnime(query);
    }
    _isLoadingCatalog = false;
    notifyListeners();
  }

  void filterByGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // ─── Watchlist ─────────────────────────────────────────────────────────────
  Future<void> _loadUserWatchlist() async {
    final remoteItems = await _supabaseService.fetchWatchlist();
    if (remoteItems.isNotEmpty) {
      _watchlist.clear();
      _watchlist.addAll(remoteItems);
      notifyListeners();
    }
  }

  bool isInWatchlist(int animeId) {
    return _watchlist.any((w) => w.animeId == animeId);
  }

  WatchlistItem? getWatchlistItem(int animeId) {
    try {
      return _watchlist.firstWhere((w) => w.animeId == animeId);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleWatchlist(AnimeModel anime, {String status = 'watching'}) async {
    final index = _watchlist.indexWhere((w) => w.animeId == anime.id);
    if (index >= 0) {
      final removed = _watchlist.removeAt(index);
      notifyListeners();
      await _supabaseService.removeWatchlistItem(removed.animeId);
    } else {
      final newItem = WatchlistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        animeId: anime.id,
        title: anime.title,
        imageUrl: anime.imageUrl,
        score: anime.score,
        status: status,
        episodesWatched: 1,
        totalEpisodes: anime.episodes,
        addedAt: DateTime.now(),
      );
      _watchlist.insert(0, newItem);
      notifyListeners();
      await _supabaseService.saveWatchlistItem(newItem);
    }
  }

  Future<void> updateWatchlistStatus(int animeId, String newStatus) async {
    final index = _watchlist.indexWhere((w) => w.animeId == animeId);
    if (index >= 0) {
      _watchlist[index].status = newStatus;
      notifyListeners();
      await _supabaseService.saveWatchlistItem(_watchlist[index]);
    }
  }

  Future<void> removeFromWatchlist(int animeId) async {
    _watchlist.removeWhere((w) => w.animeId == animeId);
    notifyListeners();
    await _supabaseService.removeWatchlistItem(animeId);
  }

  // ─── Control Remoto Smart TV y Telemetría Wearable ─────────────────────────
  void _initBleAndSync() async {
    bool isBleAvailable = false;
    try {
      if (await FlutterBluePlus.isSupported == true) {
        final state = await FlutterBluePlus.adapterState.first
            .timeout(const Duration(seconds: 3));
        if (state == BluetoothAdapterState.on) {
          isBleAvailable = true;
        }
      }
    } catch (e) {
      debugPrint('[BLE Check] Usando sincronización en la nube Supabase: $e');
    }

    if (isBleAvailable) {
      _startBleScanning();
    } else {
      _connectSupabaseRealtime();
    }
  }

  void _startBleScanning() async {
    connectionStatus = 'Buscando BLE...';
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      _bleScanSub = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.platformName.contains('Anime') ||
              r.advertisementData.manufacturerData.isNotEmpty) {
            FlutterBluePlus.stopScan();
            connectionStatus = 'Conectado 🟢 (BLE)';
            notifyListeners();

            if (r.advertisementData.manufacturerData.containsKey(1)) {
              final data = r.advertisementData.manufacturerData[1]!;
              if (data.length >= 3) {
                heartRate = data[0];
                hypeLevel = data[1];
                episodes = data[2];
                criticalAlert = hypeLevel > 90 || heartRate > 120;
                publishTvSync();
                notifyListeners();
              }
            }
            break;
          }
        }
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (connectionStatus == 'Buscando BLE...') {
          FlutterBluePlus.stopScan();
          _connectSupabaseRealtime();
        }
      });
    } catch (e) {
      _connectSupabaseRealtime();
    }
  }

  void _connectSupabaseRealtime() {
    connectionStatus = 'Conectado 🟢 (Vía Supabase)';
    notifyListeners();

    // Escuchar tabla device_sync (id=2 representa telemetría del wearable si viene de cloud)
    _supabaseSyncSub?.cancel();
    try {
      _supabaseSyncSub = _supabaseService.client
          .from('device_sync')
          .stream(primaryKey: ['id'])
          .eq('id', 2)
          .listen((data) {
            if (data.isNotEmpty) {
              final res = data.first;
              heartRate = res['heart_rate'] ?? heartRate;
              hypeLevel = res['hype_level'] ?? hypeLevel;
              episodes = res['episodes'] ?? episodes;
              criticalAlert = hypeLevel > 90 || heartRate > 120;
              publishTvSync();
              notifyListeners();
            }
          }, onError: (e) {
            debugPrint('[Supabase Sync] Stream no disponible o en entorno de test: $e');
          });
    } catch (e) {
      debugPrint('[Supabase Sync] Error al suscribirse: $e');
    }
  }

  // Enviar comando directo a la Smart TV
  Future<void> selectTvCard(int cardIndex) async {
    tvSelectedCardIndex = cardIndex;
    notifyListeners();

    await _supabaseService.updateDeviceSync(
      heartRate: heartRate,
      hypeLevel: hypeLevel,
      episodes: episodes,
      criticalAlert: criticalAlert,
      remoteCommand: 'CARD_$cardIndex',
      selectedCard: cardIndex,
    );
  }

  Future<void> toggleTvPlayback() async {
    tvIsPlaying = !tvIsPlaying;
    notifyListeners();

    await _supabaseService.updateDeviceSync(
      heartRate: heartRate,
      hypeLevel: hypeLevel,
      episodes: episodes,
      criticalAlert: criticalAlert,
      remoteCommand: tvIsPlaying ? 'PLAY' : 'PAUSE',
      selectedCard: tvSelectedCardIndex,
    );
  }

  Future<void> incrementEpisode() async {
    episodes++;
    notifyListeners();
    publishTvSync();
  }

  Future<void> decrementEpisode() async {
    if (episodes > 0) {
      episodes--;
      notifyListeners();
      publishTvSync();
    }
  }

  Future<void> adjustHype(int delta) async {
    hypeLevel = (hypeLevel + delta).clamp(0, 100);
    criticalAlert = hypeLevel > 90 || heartRate > 120;
    notifyListeners();
    publishTvSync();
  }

  Future<void> publishTvSync() async {
    await _supabaseService.updateDeviceSync(
      heartRate: heartRate,
      hypeLevel: hypeLevel,
      episodes: episodes,
      criticalAlert: criticalAlert,
      remoteCommand: 'UPDATE',
      selectedCard: tvSelectedCardIndex,
    );
  }

  // ─── Métodos de Mensajería entre Dispositivos y Roles (Prácticas 6 y 7) ────
  void selectSenderDevice(String device) {
    if (connectedDevices.contains(device)) {
      selectedSenderDevice = device;
      notifyListeners();
    }
  }

  bool sendDeviceMessage(String rawText) {
    final trimmed = rawText.trim();
    // [Práctica 6 y 7 - Requisito 6]: Evitar el envío de mensajes vacíos
    if (trimmed.isEmpty) return false;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    deviceMessages.add({
      'sender': selectedSenderDevice,
      'text': trimmed,
      'timestamp': timeStr,
    });
    messageCountsByDevice[selectedSenderDevice] =
        (messageCountsByDevice[selectedSenderDevice] ?? 0) + 1;

    notifyListeners();
    publishTvSync();
    return true;
  }

  void clearDeviceMessages() {
    deviceMessages.clear();
    for (final key in messageCountsByDevice.keys.toList()) {
      messageCountsByDevice[key] = 0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _bleScanSub?.cancel();
    _supabaseSyncSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
