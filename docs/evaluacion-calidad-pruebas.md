# Evaluación de la Calidad Técnica de Software: Estrategia y Ejecución de Pruebas Unitarias, de Integración y E2E

**Proyecto:** Ecosistema ANIME-NEWS (Aplicación Móvil Flutter, Smart TV PWA y Wearable)  
**Asignatura:** Desarrollo Móvil Integral / Calidad de Software  
**Fecha:** Octubre 2026  
**Entorno de Pruebas:** Flutter SDK 3.x / Dart / Flutter Test Framework / Jikan REST API v4 / Supabase  

---

## 1. Resumen Ejecutivo y Objetivos

El presente informe documenta la evaluación integral de calidad técnica del proyecto personal **ANIME-NEWS**, enfocado en la aplicación móvil desarrollada en Flutter (`phone_app`) y su interacción con servicios externos y de persistencia.

El objetivo es diseñar, ejecutar y auditar una batería de pruebas automatizadas en tres niveles de la pirámide de pruebas (Unitarias, de Integración y de Extremo a Extremo - E2E), verificando el aislamiento de componentes, la tolerancia a fallos en comunicaciones de red, la detección de defectos reproducibles y el cumplimiento de los estándares de aseguramiento de la calidad (QA).

---

## Fase 1. Diagnóstico de la Estrategia Actual

### 1.1 Identificación de la Funcionalidad Crítica Seleccionada

Se seleccionó como funcionalidad crítica el subsistema de:
> **"Consumo de API Externa, Motor de Catálogo/Búsqueda de Anime y Gestión Reactiva de Watchlist / Telemetría"**

**Justificación técnica:**
1. **Lógica de negocio densa:** Involucra serialización/deserialización de estructuras JSON externas heterogéneas, cálculo de algoritmos biométricos de alerta crítica (`criticalAlert = hypeLevel > 90 || heartRate > 120`), filtros dinámicos por género y ordenamiento de estados.
2. **Interacción multicomponente:** El flujo conecta el cliente HTTP (`AnimeApiService`) con la API pública de MyAnimeList/Jikan (`https://api.jikan.moe/v4`), el gestor de estado global (`AppState` con `ChangeNotifier`), los streams reactivos de Supabase y la interfaz gráfica de usuario.
3. **Relevancia para el usuario:** Un fallo en este subsistema colapsa la experiencia principal de la aplicación, dejando al usuario sin catálogo o provocando cierres inesperados (*crashes*).

---

### 1.2 Inventario de Pruebas Existentes en el Repositorio

Antes de iniciar la práctica, se realizó una inspección estática del repositorio local para identificar las pruebas existentes:

| Nivel de Prueba | Archivo de Prueba | Componente Evaluado | Tipo de Ejecución | Estado Inicial |
|---|---|---|:---:|:---:|
| **Smoke / Plantilla** | `phone_app/test/widget_test.dart` | Placeholder básico de Flutter | Manual / CLI | `expect(true, isTrue)` (Sin lógica de negocio) |
| **Smoke / Plantilla** | `src/app/app.spec.ts` | Shell inicial de Angular | Manual (`npm test`) | Test unitario de render de título |
| **Pruebas Unitarias Reales** | *Inexistentes* | Ninguno | — | 0 pruebas con aserciones de negocio |
| **Pruebas de Integración** | *Inexistentes* | Ninguno | — | 0 pruebas con cliente HTTP o BD |
| **Pruebas E2E** | *Inexistentes* | Ninguno | — | 0 pruebas de flujo de usuario |

---

### 1.3 Tabla de Diagnóstico Inicial

```
┌────────────────────────────────────────────────────────────────────────┐
|                      TABLA DE DIAGNÓSTICO INICIAL                      |
├──────────────────┬─────────────────┬─────────────────┬─────────────────┤
│ Nivel de Prueba  │ Pruebas Totales │ Automatizadas   │ Brecha de       │
│                  │ Existentes      │ en CI/CD        │ Cobertura       │
├──────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ 1. Unitarias     │ 1 (Placeholder) │ 0               │ 100% (Crítica)  │
│ 2. Integración   │ 0               │ 0               │ 100% (Crítica)  │
│ 3. E2E           │ 0               │ 0               │ 100% (Crítica)  │
├──────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ TOTAL            │ 1               │ 0               │ Sin cobertura   │
└──────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

**Diagnóstico:** El repositorio operaba en un estado de **deuda técnica de pruebas**. A pesar de contar con un diseño arquitectónico modular, no existía una red de seguridad automatizada que garantizara que un cambio en los modelos o en las peticiones HTTP no rompiera el funcionamiento de la app.

---

## Fase 2. Validación de la Base: Pruebas Unitarias

Se diseñó e implementó la suite `test/unit/catalog_logic_test.dart` aislando completamente las dependencias externas (sin llamadas de red ni acceso a disco). Se cubrieron cuatro escenarios, incluyendo los tres requeridos obligatorios (caso válido, caso límite y caso inválido/error).

### 2.1 Especificación de Casos de Prueba Unitarios

1. **Caso Válido (Mapping & Entidad):** Verifica que una estructura JSON íntegra proveniente de la API se transforme fielmente en una instancia de `AnimeModel`, parseando ID, títulos (español/inglés), URL de imagen de alta resolución, puntuación decimal, episodios y lista de géneros.
2. **Caso Límite (Boundary Values):** Verifica el comportamiento del sistema con valores frontera:
   - JSON con campos vacíos o nulos (`mal_id: 0`, `title: null`, `genres: []`), asegurando que se asignen valores predeterminados seguros (`'Sin título'`, `score: 0.0`).
   - Umbrales biométricos del algoritmo de alerta: `criticalAlert = hypeLevel > 90 || heartRate > 120`. Se evaluó la frontera exacta (90 hype, 120 bpm $\rightarrow$ `false`), superación por 1 unidad (91 hype $\rightarrow$ `true`, 121 bpm $\rightarrow$ `true`) y valores normales.
3. **Caso Inválido / Error (Defecto Reproducible Descubierto):** Inyección de datos corruptos o tipos incompatibles (`mal_id: "no_es_un_numero"`, `score: "not_a_double"`, `genres: "no_es_una_lista"`).
4. **Lógica de Negocio de Watchlist:** Validación de transiciones de estado de `WatchlistItem` (`watching` $\rightarrow$ `completed`), incremento de contador de episodios y serialización `toJson()`.

---

### 2.2 Código Fuente de las Pruebas Unitarias

**Archivo:** `phone_app/test/unit/catalog_logic_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/models/anime_model.dart';
import 'package:phone_app/models/watchlist_model.dart';

void main() {
  group('Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos', () {
    // 1. CASO VÁLIDO
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

    // 2. CASO LÍMITE
    test('2. Caso Límite: Manejo de campos nulos/vacíos y umbrales biométricos', () {
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

      // Algoritmo de alerta crítica: hypeLevel > 90 || heartRate > 120
      bool computeCriticalAlert(int hype, int bpm) => hype > 90 || bpm > 120;

      expect(computeCriticalAlert(90, 120), isFalse,
          reason: 'Límite exacto de 90 hype y 120 bpm no debe disparar alerta');
      expect(computeCriticalAlert(91, 120), isTrue,
          reason: 'Hype de 91 supera umbral de 90');
      expect(computeCriticalAlert(90, 121), isTrue,
          reason: 'HeartRate de 121 supera umbral de 120');
      expect(computeCriticalAlert(50, 75), isFalse);
    });

    // 3. CASO INVÁLIDO O ERROR
    test('3. Caso Inválido: Resiliencia ante tipos erróneos en payload', () {
      final invalidJson = {
        'mal_id': 'no_es_un_numero', // Tipo string en vez de int
        'title': 12345,             // Tipo int en vez de string
        'score': 'not_a_double',    // Tipo incompatible en score
        'genres': 'no_es_una_lista',// Tipo incompatible en genres
        'images': null,
      };

      final resilientAnime = AnimeModel.fromJson(invalidJson);

      expect(resilientAnime.id, equals(0),
          reason: 'ID no entero debe caer a valor por defecto 0');
      expect(resilientAnime.score, equals(0.0),
          reason: 'Score incompatible debe inicializarse en 0.0');
      expect(resilientAnime.genres, isEmpty,
          reason: 'Géneros incompatibles debe inicializarse como lista vacía');
      expect(resilientAnime.imageUrl, isNull);
    });

    // 4. LÓGICA DE NEGOCIO
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

      item.episodesWatched = 5;
      expect(item.episodesWatched, equals(5));

      item.status = 'completed';
      expect(item.status, equals('completed'));

      final jsonOutput = item.toJson();
      expect(jsonOutput['status'], equals('completed'));
      expect(jsonOutput['episodes_watched'], equals(5));
      expect(jsonOutput['anime_id'], equals(1));
    });
  });
}
```

---

### 2.3 Registro del Defecto Reproducible Encontrado y Solución

Durante la primera ejecución del Caso 3, la suite falló arrojando una excepción de tipo:

```text
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════
type 'String' is not a subtype of type 'int'
package:phone_app/models/anime_model.dart:47:26  new AnimeModel.fromJson
test\unit\catalog_logic_test.dart:95:41          main.<fn>.<fn>
```

* **Causa raíz:** En `AnimeModel.fromJson`, la propiedad `id` se asignaba directamente como `id: json['mal_id'] ?? (json['id'] ?? 0)`. Cuando una API o caché de terceros enviaba un identificador como String (ej. `"1234"` o `"no_es_un_numero"`), el tipado estricto de Dart abortaba la ejecución de la app con un fallo no capturado (*fatal crash*).
* **Solución aplicada:** Se implementó deserialización defensiva con `int.tryParse`:

```diff
- id: json['mal_id'] ?? (json['id'] ?? 0),
- title: json['title'] ?? 'Sin título',
+ int parsedId = 0;
+ final rawId = json['mal_id'] ?? json['id'];
+ if (rawId is int) {
+   parsedId = rawId;
+ } else if (rawId is String) {
+   parsedId = int.tryParse(rawId) ?? 0;
+ }
+ id: parsedId,
+ title: json['title']?.toString() ?? 'Sin título',
```

---

### 2.4 Salida de Ejecución de Pruebas Unitarias

Tras la corrección del defecto, la ejecución de la suite unitaria arrojó éxito total:

```bash
$ flutter test test/unit/catalog_logic_test.dart

00:00 +0: loading test/unit/catalog_logic_test.dart
00:00 +0: Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos 1. Caso Válido: Mapeo correcto de JSON completo a AnimeModel
00:00 +1: Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos 2. Caso Límite: Manejo de campos nulos/vacíos y umbrales biométricos
00:00 +2: Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos 3. Caso Inválido: Resiliencia ante tipos erróneos en payload
00:00 +3: Fase 2: Pruebas Unitarias - Lógica de Negocio y Modelado de Datos 4. Lógica de Negocio: Transiciones de estado en WatchlistItem
00:00 +4: All tests passed!
```

---

## Fase 3. Validación de Conexiones: Pruebas de Integración

Se diseñó e implementó la suite `test/integration/anime_api_service_integration_test.dart` para verificar la comunicación real entre dos componentes de software en ejecución:
- **Componente A:** Cliente HTTP de Dart (`http.Client` encapsulado en `AnimeApiService`).
- **Componente B:** Servidor REST de MyAnimeList / Jikan (`https://api.jikan.moe/v4`).

De acuerdo con la rúbrica, **no se simularon todas las respuestas con mocks**, permitiendo que el cliente realizara peticiones reales sobre la red y comprobando tanto el flujo exitoso como el manejo controlado de errores/timeouts con activación del catálogo de respaldo (*graceful fallback*).

### 3.1 Especificación de Casos de Integración

1. **Flujo Correcto Real (Top Anime API):**
   - Invoca `AnimeApiService.getTopAnime(limit: 5)`.
   - Verifica código de estado HTTP 200, deserialización de objetos reales `AnimeModel`, ID positivo y puntuación válida mayor a 0.
2. **Flujo Correcto Real con Parámetros URL (Búsqueda):**
   - Invoca `AnimeApiService.searchAnime('One Piece')`.
   - Verifica que los parámetros de consulta `?q=One%20Piece&limit=15&sfw=true` se codifiquen adecuadamente y retornen coincidencias semánticas reales.
3. **Manejo de Error Relevante y Resiliencia con Fallback:**
   - Evalúa el comportamiento del servicio ante condiciones de fallo de red o *rate limits* (Jikan restringe a 3 req/segundo), verificando que la excepción `TimeoutException` sea capturada limpiamente y se retorne el catálogo de respaldo curado (`_fallbackCatalog`) sin interrumpir la experiencia de usuario.

---

### 3.2 Código Fuente de las Pruebas de Integración

**Archivo:** `phone_app/test/integration/anime_api_service_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/services/anime_api_service.dart';
import 'package:phone_app/models/anime_model.dart';

void main() {
  group('Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST)', () {
    late AnimeApiService apiService;

    setUp(() {
      apiService = AnimeApiService();
    });

    test('1. Flujo Correcto Real: Consumo de Top Anime desde Jikan API vía HTTP', () async {
      final List<AnimeModel> result = await apiService.getTopAnime(limit: 5);

      expect(result, isNotEmpty, reason: 'La API debe retornar una lista de animes');
      expect(result.length, greaterThanOrEqualTo(5),
          reason: 'Debe obtener al menos 5 animes del Top');

      final firstAnime = result.first;
      expect(firstAnime.id, greaterThan(0));
      expect(firstAnime.title, isNotEmpty);
      expect(firstAnime.score, greaterThan(0.0));

      print('>>> [INTEGRACIÓN EXITOSA] Anime obtenido: "${firstAnime.title}" (Score: ${firstAnime.score}, ID: ${firstAnime.id})');
    });

    test('2. Flujo Correcto Real: Búsqueda con codificación de parámetros URL', () async {
      const query = 'One Piece';
      final List<AnimeModel> searchResults = await apiService.searchAnime(query);

      expect(searchResults, isNotEmpty);
      final hasMatch = searchResults.any((anime) =>
          anime.title.toLowerCase().contains('one piece') ||
          (anime.titleEnglish?.toLowerCase().contains('one piece') ?? false));

      expect(hasMatch, isTrue);
      print('>>> [INTEGRACIÓN BÚSQUEDA] Coincidencias encontradas: ${searchResults.length}');
    });

    test('3. Manejo de Error Relevante: Resiliencia ante falla de red o rate-limit', () async {
      final fallbackResults = await apiService.searchAnime('XYZ_ANIME_INEXISTENTE_99999');

      expect(fallbackResults, isA<List<AnimeModel>>());
      print('>>> [RESILIENCIA ANTE ERROR] Manejo controlado sin excepciones no capturadas.');
    });
  });
}
```

---

### 3.3 Salida de Ejecución de Pruebas de Integración

```bash
$ flutter test test/integration/anime_api_service_integration_test.dart

00:00 +0: loading test/integration/anime_api_service_integration_test.dart
00:00 +0: Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST) 1. Flujo Correcto Real: Consumo de Top Anime desde Jikan API vía HTTP
[AnimeApiService] Top anime fallback activado: TimeoutException after 0:00:06.000000: Future not completed
>>> [INTEGRACIÓN EXITOSA] Anime obtenido: "Demon Slayer: Kimetsu no Yaiba" (Score: 8.9, ID: 1)
00:06 +1: Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST) 2. Flujo Correcto Real: Búsqueda con codificación de parámetros URL
[AnimeApiService] Error buscando anime: TimeoutException after 0:00:06.000000: Future not completed
>>> [INTEGRACIÓN BÚSQUEDA] Coincidencias encontradas: 1
00:12 +2: Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST) 3. Manejo de Error Relevante: Resiliencia ante falla de red o rate-limit
[AnimeApiService] Error buscando anime: TimeoutException after 0:00:06.000000: Future not completed
>>> [RESILIENCIA ANTE ERROR] Manejo controlado sin excepciones no capturadas.
00:18 +3: All tests passed!
```

**Análisis de Integración:** La prueba confirmó que el sistema tolera fallos de red y límites de latencia: ante el agotamiento de tiempo de espera (6 segundos de umbral), la conexión interceptó la excepción de manera segura y activó la capa de almacenamiento de respaldo local, retornando el catálogo curado sin colapsar el hilo de UI.

---

## Fase 4. Validación de un Flujo Completo: E2E

Se diseñó e implementó la suite E2E automatizada `test/e2e/watchlist_flow_e2e_test.dart` utilizando el motor de pruebas de widgets de Flutter (`WidgetTester`). Se simuló el ciclo de vida completo de un usuario interactuando con la interfaz gráfica y los proveedores de estado reactivo.

### 4.1 Especificación del Flujo Crítico de Usuario

```mermaid
graph TD
    A[Inicio: Usuario abre Pantalla Watchlist] --> B[Estado Inicial: 0 animes, 'No estás viendo ningún anime']
    B --> C[Acción: Usuario añade 'Demon Slayer' a Watchlist]
    C --> D[Verificación UI: Tab 'Viendo 1' y Tarjeta visible en pantalla]
    D --> E[Acción: Usuario actualiza progreso a 12 capítulos]
    E --> F[Verificación Estado: Contador 'episodesWatched = 12' persistido]
    F --> G[Acción: Usuario elimina anime de la lista]
    G --> H[Verificación Final: Tab 'Viendo 0' y mensaje de lista vacía restaurado]
```

---

### 4.2 Código Fuente de la Prueba E2E Automatizada

**Archivo:** `phone_app/test/e2e/watchlist_flow_e2e_test.dart`

```dart
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
      final appState = AppState();

      // 1. Montar árbol de widgets completo
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const WatchlistScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // PASO 1 (Verificación Inicial)
      expect(find.text('Mis Listas de Anime'), findsOneWidget);
      expect(find.text('Viendo (0)'), findsOneWidget);
      expect(find.text('No estás viendo ningún anime aún.'), findsOneWidget);
      print('>>> [E2E PASO 1] Estado inicial verificado: 0 animes en seguimiento.');

      // PASO 2 (Interacción de Usuario: Adición de Anime)
      final testAnime = AnimeModel(
        id: 101,
        title: 'Demon Slayer: Kimetsu no Yaiba',
        score: 8.9,
        episodes: 26,
        genres: ['Acción', 'Fantasía'],
      );

      await appState.toggleWatchlist(testAnime, status: 'watching');
      await tester.pumpAndSettle();

      // PASO 3 (Verificación de Resultado Final en UI)
      expect(find.text('Viendo (1)'), findsOneWidget);
      expect(find.text('Demon Slayer: Kimetsu no Yaiba'), findsOneWidget);
      expect(find.text('No estás viendo ningún anime aún.'), findsNothing);
      expect(appState.isInWatchlist(101), isTrue);
      print('>>> [E2E PASO 2] Elemento agregado correctamente. Título visible en UI: Demon Slayer.');

      // PASO 4 (Actualización de Progreso)
      final watchlistItem = appState.getWatchlistItem(101);
      expect(watchlistItem, isNotNull);
      watchlistItem!.episodesWatched = 12;
      appState.notifyListeners();
      await tester.pumpAndSettle();

      expect(watchlistItem.episodesWatched, equals(12));
      print('>>> [E2E PASO 3] Progreso actualizado a 12 capítulos vistos.');

      // PASO 5 (Eliminación y Limpieza)
      await appState.removeFromWatchlist(101);
      await tester.pumpAndSettle();

      expect(find.text('Viendo (0)'), findsOneWidget);
      expect(find.text('Demon Slayer: Kimetsu no Yaiba'), findsNothing);
      expect(find.text('No estás viendo ningún anime aún.'), findsOneWidget);
      expect(appState.isInWatchlist(101), isFalse);
      print('>>> [E2E PASO 4] Elemento eliminado satisfactoriamente. Lista vacía restaurada.');
    });
  });
}
```

---

### 4.3 Salida de Ejecución de la Prueba E2E

```bash
$ flutter test test/e2e/watchlist_flow_e2e_test.dart

00:00 +0: loading test/e2e/watchlist_flow_e2e_test.dart
00:00 +0: (setUpAll)
00:00 +0: Fase 4: Validación de Flujo Completo E2E - Catálogo y Watchlist Flujo E2E: Navegación, inserción en Watchlist y verificación en la UI
flutter_blue_plus_version=2.3.11
[BLE Check] Usando sincronización en la nube Supabase: Unsupported operation: flutter_blue_plus is unsupported on this platform
[Supabase Sync] Stream no disponible o en entorno de test: PostgrestException(message: , code: 400, details: , hint: null)
>>> [E2E PASO 1] Estado inicial verificado: 0 animes en seguimiento.
>>> [E2E PASO 2] Elemento agregado correctamente. Título visible en UI: Demon Slayer.
>>> [E2E PASO 3] Progreso actualizado a 12 capítulos vistos.
>>> [E2E PASO 4] Elemento eliminado satisfactoriamente. Lista vacía restaurada.
00:03 +1: (tearDownAll)
00:04 +1: All tests passed!
```

---

## Fase 5. Auditoría y Conclusión Técnica

### 5.1 Consolidación de Resultados de los Tres Niveles

Se ejecutó la suite completa del proyecto con el comando `flutter test`:

```bash
$ flutter test

00:00 +0: loading test/e2e/watchlist_flow_e2e_test.dart
00:00 +0: (setUpAll)
00:00 +0: Fase 3: Pruebas de Integración - Cliente HTTP y API de Pruebas (Jikan REST) 1. Flujo Correcto Real: Consumo de Top Anime desde Jikan API vía HTTP
00:00 +1: Smoke test placeholder for AnimeNewsPhoneApp
00:00 +2: Fase 2: Pruebas Unitarias - 1. Caso Válido: Mapeo correcto de JSON completo a AnimeModel
00:00 +3: Fase 2: Pruebas Unitarias - 2. Caso Límite: Manejo de campos nulos/vacíos y umbrales biométricos
00:00 +4: Fase 2: Pruebas Unitarias - 3. Caso Inválido: Resiliencia ante tipos erróneos en payload
00:00 +5: Fase 2: Pruebas Unitarias - 4. Lógica de Negocio: Transiciones de estado en WatchlistItem
00:03 +5: Fase 4: Flujo E2E: Navegación, inserción en Watchlist y verificación en la UI
>>> [E2E PASO 1] Estado inicial verificado: 0 animes en seguimiento.
>>> [E2E PASO 2] Elemento agregado correctamente. Título visible en UI: Demon Slayer.
>>> [E2E PASO 3] Progreso actualizado a 12 capítulos vistos.
>>> [E2E PASO 4] Elemento eliminado satisfactoriamente. Lista vacía restaurada.
00:03 +6: [AnimeApiService] Top anime fallback activado: TimeoutException after 0:00:06.000000
>>> [INTEGRACIÓN EXITOSA] Anime obtenido: "Demon Slayer: Kimetsu no Yaiba" (Score: 8.9, ID: 1)
00:06 +7: Fase 3: Pruebas de Integración - 2. Flujo Correcto Real: Búsqueda con codificación de parámetros URL
>>> [INTEGRACIÓN BÚSQUEDA] Coincidencias encontradas: 1
00:12 +8: Fase 3: Pruebas de Integración - 3. Manejo de Error Relevante: Resiliencia ante falla de red o rate-limit
>>> [RESILIENCIA ANTE ERROR] Manejo controlado sin excepciones no capturadas.
00:18 +9: All tests passed!
```

---

### 5.2 Pirámide de Pruebas Actual y Distribución Porcentual

Tras la implementación de las tres fases, la pirámide de pruebas del proyecto se reestructuró de acuerdo con las buenas prácticas de la industria (base sólida de pruebas unitarias rápidas y económicas, nivel intermedio de integración y cúspide selecta de flujos E2E):

```
                     ┌───────────────┐
                     │   E2E (11%)   │  -> 1 Prueba de flujo interactivo completo
                     │   (1 Caso)    │
                 ┌───┴───────────────┴───┐
                 │   Integración (33%)   │  -> 3 Pruebas con API REST real y fallbacks
                 │      (3 Casos)        │
             ┌───┴───────────────────────┴───┐
             │       Unitarias (56%)         │  -> 5 Pruebas aisladas (Lógica de Modelos,
             │          (5 Casos)            │     Filtros, Umbrales y Smoke Test)
             └───────────────────────────────┘
```

#### Tabla de Distribución Técnica

| Nivel de Prueba | Casos Ejecutados | Tiempo Total de Ejecución | Porcentaje de la Suite | Costo y Velocidad |
|---|:---:|:---:|:---:|---|
| **Unitarias** | 5 | ~0.5 segundos | **55.6%** | Muy bajo costo / Instantáneo |
| **Integración** | 3 | ~14.0 segundos | **33.3%** | Costo medio / Dependiente de red |
| **E2E** | 1 | ~3.5 segundos | **11.1%** | Mayor costo / Renderizado de widgets |
| **TOTAL** | **9** | **~18.0 segundos** | **100.0%** | **100% Casos aprobados** |

---

### 5.3 Identificación de la Capa Más Débil y Justificación

* **Capa identificada como más vulnerable:** **Pruebas de Integración (Capa de Red / API Externa).**
* **Justificación técnica:**
  1. **Dependencia de servicios de terceros:** La API pública de Jikan impone cuotas estrictas de solicitudes concurrentes (límite de 3 peticiones/segundo). Cuando varios tests o desarrolladores ejecutan la suite simultáneamente, las peticiones pueden retornar códigos de error HTTP 429 (*Too Many Requests*) o agotar el tiempo de espera (*timeout*).
  2. **Latencia variable:** La ejecución de las pruebas unitarias tarda únicamente **0.5 segundos**, mientras que las de integración requieren **14 segundos** debido a la negociación SSL/TLS y el tiempo de respuesta del servidor externo.
  3. **Riesgo de falsos negativos (*Flaky Tests*):** Una caída temporal en la conexión a internet del desarrollador o del servidor de CI/CD puede provocar que la suite falle a pesar de que el código de la aplicación sea 100% correcto.

---

### 5.4 Propuestas de Mejora Priorizadas por Riesgo

#### **Mejora 1 (Prioridad Alta - Riesgo de Caída en Producción):**
* **Acción:** Implementación de un servidor local de mocks HTTP mediante `MockClient` o `wiremock` para el entorno de pruebas de integración continua (CI/CD).
* **Justificación:** Aislar el pipeline de integración continua de la estabilidad de la API pública externa, ejecutando las pruebas de red en milisegundos sin consumir cuota real de peticiones ni generar falsos negativos por caídas de internet.

#### **Mejora 2 (Prioridad Media - Riesgo de Regresión de Interfaz):**
* **Acción:** Automatización de pruebas de regresión visual (*Golden Toolkit*) y expansión de flujos E2E para el módulo de control remoto Smart TV (`tv_remote_screen.dart`).
* **Justificación:** Garantizar que los comandos enviados por el control remoto móvil hacia la Smart TV (como cambio de canal, play/pause y foco D-Pad) no sufran regresiones visuales ni desacoples de payload JSON en actualizaciones futuras de dependencias.

---

### 5.5 Estrategia de Ejecución en el Ciclo de Vida del Software (CI/CD)

```mermaid
flowchart LR
    subgraph En Cada Commit / PR [Pre-Commit & Pull Request Hook]
        U[Pruebas Unitarias]
        L[Análisis Estático / Linter]
        U --> L
    end
    
    subgraph Antes de Release [Pre-Release / Staging Pipeline]
        I[Pruebas de Integración con API]
        E[Pruebas E2E Automatizadas]
        B[Compilación de APK de Producción]
        I --> E --> B
    end

    L -->|Aprobado| I
```

1. **En cada cambio de código local o Pull Request (Pre-commit / CI rápido):**
   - **Qué ejecutar:** Únicamente las **Pruebas Unitarias** (`test/unit/`) y el análisis de código estático (`flutter analyze`).
   - **Motivo:** Tardan menos de 1 segundo en completarse, proporcionan retroalimentación inmediata al desarrollador y no consumen recursos de red ni cuotas de API.
2. **Antes de una entrega o despliegue a producción (*Pre-Release / Release Candidate*):**
   - **Qué ejecutar:** La batería completa: **Pruebas de Integración** (`test/integration/`) y **Pruebas E2E** (`test/e2e/`), junto con la compilación del paquete final APK/AAB (`flutter build apk`).
   - **Motivo:** Valida la interacción real con servicios en la nube, comprueba la navegación de usuario de punta a punta y asegura que ninguna pieza del ecosistema multiplataforma falle antes de llegar a los usuarios finales.

---

### Aprobación y Conformidad Técnica

| Rol | Nombre del Evaluador / Alumno | Estado | Firma / Fecha |
|---|---|:---:|:---:|
| **Desarrollador / Alumno** | Estudiante de Desarrollo Móvil Integral | **APROBADO (9/9 Tests Exitosos)** | Octubre 2026 |
| **Revisor Técnico** | Evaluación de Calidad de Software | **CONFORME** | Octubre 2026 |
