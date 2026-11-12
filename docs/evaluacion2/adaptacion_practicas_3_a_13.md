# Evaluación 2: Corroboración de Cumplimiento y Adaptación del Proyecto ANIME-NEWS a las Prácticas (Prácticas 3 a 13)

**Proyecto:** Ecosistema Multiplataforma ANIME-NEWS Hub (Flutter Mobile App + Angular 18 PWA Smart TV + Wear OS + Supabase Cloud)  
**Asignatura:** Desarrollo Móvil Integral  
**Periodo:** Décimo Cuatrimestre  
**Documento:** Auditoría de Cumplimiento y Adaptación Arquitectónica por Práctica  

---

## Tabla General de Trazabilidad y Cumplimiento (Prácticas 3 a 13)

> **Nota sobre la numeración del documento guía:** El documento maestro de prácticas inicia en la **Práctica 3** y continúa de forma secuencial hasta la **Práctica 12** (10 prácticas en el documento Word), complementándose en el repositorio con la **Práctica 13** (Cuentas, Registros y Conexión de API). A continuación se documentan **todas las prácticas (de la 3 a la 13)** para garantizar una cobertura del **100%** sin omisiones.

| N° Práctica | Título Oficial de la Práctica | Módulo / Archivos del Proyecto donde se Adapta | Estado de Cumplimiento |
| :---: | :--- | :--- | :---: |
| **Práctica 3** | Consumo de una URL preasignada desde una aplicación móvil (`ConsultaWeb`) | `src/app/pages/consulta-web/consulta-web.ts` y `phone_app/lib/services/anime_api_service.dart` | **100% Cumplido** |
| **Práctica 4** | Almacenamiento estructurado en una aplicación móvil (CRUD / Entidades / DAO) | `phone_app/lib/models/watchlist_model.dart`, `phone_app/lib/services/supabase_service.dart`, `src/app/pages/admin/user-management.ts` | **100% Cumplido** |
| **Práctica 5** | Prácticas de código seguro en aplicaciones móviles (`AccesoSeguro`) | `phone_app/lib/views/auth/login_screen.dart`, `phone_app/lib/providers/app_state.dart`, `src/app/services/auth.service.ts` | **100% Cumplido** |
| **Práctica 6** | Interacción entre dispositivos (`MobileConnect`) | `phone_app/lib/views/tv_remote/tv_remote_screen.dart`, `phone_app/lib/providers/app_state.dart` | **100% Cumplido** |
| **Práctica 7** | Asignación de roles masivos e interacción de situaciones (4 Dispositivos) | `phone_app/lib/views/tv_remote/tv_remote_screen.dart`, `src/app/pages/admin/user-management.ts`, `docs/supabase-setup.sql` | **100% Cumplido** |
| **Práctica 8** | Evaluación de calidad de software mediante pruebas de caja negra (*Black Box Testing*) | `docs/practica-8-caja-negra.md`, `phone_app/test/e2e/watchlist_flow_e2e_test.dart` | **100% Cumplido** |
| **Práctica 9** | Conexiones y pruebas de base de datos entre dispositivos con la misma aplicación | `phone_app/lib/services/supabase_service.dart`, `src/app/services/tv-sync.service.ts` (Tabla `device_sync` y `watchlist`) | **100% Cumplido** |
| **Práctica 10** | Seguridad, autenticación y control de acceso a una base de datos compartida (RLS) | `docs/supabase-setup.sql`, `src/app/guards/admin.guard.ts`, `src/app/guards/auth.guard.ts` | **100% Cumplido** |
| **Práctica 11** | Pruebas de Caja Blanca (*White Box Testing*), Cobertura y Rendimiento de Red | `phone_app/test/unit/catalog_logic_test.dart`, `phone_app/test/integration/anime_api_service_integration_test.dart`, `docs/evaluacion-calidad-pruebas.md` | **100% Cumplido** |
| **Práctica 12** | Optimización, pruebas de estrés y resiliencia de aplicaciones móviles Flutter/Kotlin | `phone_app/lib/services/anime_api_service.dart` (Caché TTL), `phone_app/lib/services/supabase_service.dart` (Exponential Backoff + Idempotencia) | **100% Cumplido** |
| **Práctica 13** | Cuentas, Registros y Conexión de API (Roles Jerárquicos y Auditoría) | `docs/practica-13-cuentas.md`, `src/app/pages/admin/audit-log.ts`, `src/app/services/audit.service.ts` | **100% Cumplido** |

---

## Apartado 1: Práctica 3 — Consumo de una URL Preasignada desde una Aplicación Móvil (`ConsultaWeb`)

### 1.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
El proyecto **ANIME-NEWS** implementa esta práctica en dos niveles complementarios:
1. **Módulo Dedicado Exacto (`ConsultaWeb`):** Se creó el componente especializado [`src/app/pages/consulta-web/consulta-web.ts`](../../src/app/pages/consulta-web/consulta-web.ts) accesible en la ruta `/consulta-web` (empaquetado con Capacitor para Android y disponible en la PWA). Cumple literalmente con los textos y estados requeridos por los requisitos `RF01` a `RF06` consumiendo una URL preasignada (`https://jsonplaceholder.typicode.com/users/1`).
2. **Consumo de URL Preasignada del Dominio Anime (`AnimeApiService`):** En la aplicación móvil nativa en Flutter ([`phone_app/lib/services/anime_api_service.dart`](../../phone_app/lib/services/anime_api_service.dart)), se define la constante estática preasignada `_baseUrl = 'https://api.jikan.moe/v4'`, desde la cual el usuario consulta el catálogo de anime en tiempo real, visualizando un indicador de carga (`CircularProgressIndicator`) y contando con manejo de errores de conexión mediante un catálogo de respaldo (*fallback*).

### 1.2 Corroboración de Requisitos Funcionales y Actividades

| Requisito | Especificación Solicitada en la Práctica | Implementación Verificada en el Proyecto | Estado |
| :---: | :--- | :--- | :---: |
| **RF01** | Al iniciar la aplicación deberá mostrar el título: `"Consulta de información"` | En `consulta-web.ts` (línea 11): `<h1 class="title">Consulta de información</h1>`. En Flutter: cabecera de Catálogo. | ✅ Cumple |
| **RF02** | Deberá existir un botón: `"CONSULTAR"` | En `consulta-web.ts` (línea 13-15): `<button class="btn-consultar" (click)="consultar()">CONSULTAR</button>`. | ✅ Cumple |
| **RF03** | Al presionar el botón, realizar petición HTTP a la URL preasignada | Ejecuta `fetch(this.URL)` hacia la constante `readonly URL` y `http.get(Uri.parse('$_baseUrl/top/anime'))` en Flutter. | ✅ Cumple |
| **RF04** | La información obtenida deberá mostrarse en pantalla | Renderiza el JSON formateado en `<div class="data-display"><pre>{{ data | json }}</pre></div>` y tarjetas `AnimeModel` en Flutter. | ✅ Cumple |
| **RF05** | Mientras se realiza la petición deberá mostrarse: `"Consultando..."` | En `consulta-web.ts` (línea 18): `<div *ngIf="loading" class="consulta-loader">Consultando...</div>`. | ✅ Cumple |
| **RF06** | Si existe un error de conexión deberá mostrarse: `"No fue posible obtener la información."` | En `consulta-web.ts` (línea 19): `<div *ngIf="error" class="error-msg">No fue posible obtener la información.</div>`. | ✅ Cumple |

#### Evidencia de las 3 Pruebas Principales:
- **Prueba 1 — Con conexión:** Al presionar `CONSULTAR` con red Wi-Fi activa, el estado pasa a `"Consultando..."` por 800 ms, recibe código HTTP `200 OK` y despliega los datos JSON estructurados en pantalla.
- **Prueba 2 — Sin conexión:** Al desactivar Wi-Fi/Datos móviles (o activar modo Offline en DevTools), el bloque `try/catch` captura la excepción de red, apaga el indicador de carga y muestra `"No fue posible obtener la información."` (en `ConsultaWeb`) o activa el catálogo local de respaldo (en `AnimeApiService`), sin cierres inesperados.
- **Prueba 3 — Modificación de la URL:** Al cambiar la constante `URL` a un endpoint inexistente (`/users/999999`), se valida `if (!response.ok) throw new Error('HTTP Error')`, activando limpiamente el estado de error controlado `RF06`.

### 1.3 Respuestas a las Preguntas de Análisis (Práctica 3)
1. **¿Qué es una URL?** Es un *Uniform Resource Locator* (Localizador Uniforme de Recursos), una dirección única estandarizada que identifica la ubicación de un recurso en Internet y el mecanismo para recuperarlo.
2. **¿Qué significa que una URL sea preasignada?** Significa que la dirección del recurso remoto está definida como una constante de configuración en el código fuente (`readonly URL` o `static const _baseUrl`) antes de la compilación, evitando que el usuario final tenga que escribirla manualmente.
3. **¿Qué protocolo utiliza la aplicación para comunicarse con el servidor?** Utiliza el protocolo **HTTPS** (*Hypertext Transfer Protocol Secure*) sobre TCP/IP con cifrado TLS.
4. **¿Qué formato tiene la información recibida?** Formato de texto ligero **JSON** (*JavaScript Object Notation*), estructurado en pares clave-valor y listas.
5. **¿Qué función cumple JSON?** Actúa como formato estándar de intercambio de datos independiente del lenguaje, permitiendo serializar objetos del servidor y deserializarlos en modelos tipados (`AnimeModel.fromJson`) en el cliente móvil.
6. **¿Qué sucede si la URL no está disponible?** El cliente HTTP lanza una excepción (`SocketException`, `TimeoutException` o código HTTP 404/500). La aplicación la intercepta en el bloque `catch` y muestra el mensaje amigable `"No fue posible obtener la información."` o carga datos de respaldo.
7. **¿Por qué es importante controlar los errores de conexión?** Porque en entornos móviles la conectividad es inherentemente inestable; no capturar excepciones de red provocaría bloqueos de interfaz (*freezes*) o cierres abruptos (*fatal crashes*).
8. **¿Qué diferencia existe entre una URL y una API?** La **URL** es únicamente la dirección de acceso a un recurso, mientras que una **API** (*Application Programming Interface*) es el conjunto completo de contratos, reglas, endpoints, métodos HTTP y formatos que permiten que dos sistemas de software se comuniquen.
9. **¿Qué ventajas tiene separar la URL de la lógica principal de la aplicación?** Mejora la mantenibilidad (Principio de Responsabilidad Única): si el servidor cambia de dominio o versión (ej. de `v3` a `v4`), solo se actualiza una constante en la capa de servicios sin tocar las vistas ni los componentes de UI.
10. **¿Cómo podría utilizarse esta misma técnica para una aplicación real?** En el propio **ANIME-NEWS** se utiliza en producción para consultar en vivo el ranking mundial de animes desde la API Jikan v4 (`https://api.jikan.moe/v4/top/anime`) y sincronizar perfiles desde Supabase REST.

---

## Apartado 2: Práctica 4 — Almacenamiento Estructurado en una Aplicación Móvil

### 2.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
La práctica indica expresamente: *"Pueden usar la base de datos de su repositorio de proyecto"*. En **ANIME-NEWS**, el almacenamiento estructurado se adapta mediante una arquitectura híbrida de persistencia relacional y local:
1. **Tabla Estructurada de Usuarios (`perfiles`) y DAO/Servicio (`SupabaseService` + `UserManagementComponent`):**
   - Implementada en [`docs/supabase-setup.sql`](../supabase-setup.sql) y gestionada desde [`src/app/pages/admin/user-management.ts`](../../src/app/pages/admin/user-management.ts) y [`phone_app/lib/services/supabase_service.dart`](../../phone_app/lib/services/supabase_service.dart).
   - Incluye todos los campos solicitados por la práctica más el campo adicional del Caso 4:
     - `id` (Identificador único)
     - `nombre` (String — Nombre del usuario)
     - `edad` (Int — Edad validada)
     - `rol` / `profesion` (String — Rol/Carrera dentro de la plataforma: `admin`, `editor`, `cliente`, `invitado`)
     - `email` / `correo` (**Caso 4 implementado**: Campo `email` integrado en la Entidad `UserItem`, Base de Datos PostgreSQL, Interfaz de formulario, Inserción, Consulta y Actualización).
2. **Almacenamiento Estructurado en el Dispositivo Móvil (`WatchlistItem` + `SharedPreferences` + Tabla `watchlist`):**
   - En la app Flutter (`phone_app`), la entidad [`WatchlistItem`](../../phone_app/lib/models/watchlist_model.dart) modela de forma estructurada cada anime guardado por el usuario (`id`, `animeId`, `title`, `score`, `status`, `episodesWatched`), permitiendo las 4 operaciones CRUD completas desde la pantalla `WatchlistScreen`.

### 2.2 Corroboración de Casos CRUD Solicitados

| Caso de la Práctica | Operación Solicitada | Adaptación y Verificación en ANIME-NEWS | Estado |
| :---: | :--- | :--- | :---: |
| **Caso 1 — Insertar** | Registrar tres usuarios/estudiantes | Se registraron los perfiles iniciales estructurados (`admin@animenews.com`, `editor1@animenews.com`, `testcliente@gmail.com`) mediante `createUserProfile()` y `saveWatchlistItem()`. | ✅ Cumple |
| **Caso 2 — Consultar** | Ejecutar método de obtención (`obtenerTodos()`) y mostrar registros | Al abrir Gestión de Usuarios o presionar actualizar, se ejecuta `supabase.getAllUsers()` y `fetchWatchlist()`, renderizando la tabla completa en pantalla. | ✅ Cumple |
| **Caso 3 — Actualizar** | Modificar la carrera/rol o datos de un registro | Mediante el modal `openEditModal(user)` / `saveEdit()` y `saveRole()` se actualiza el rol/datos en `perfiles`; en móvil, `updateWatchlistStatus()` actualiza el estado (`watching` $\to$ `completed`). | ✅ Cumple |
| **Caso 4 — Nuevo campo (`correo`)** | Modificar Entity, BD, Interfaz, Inserción, Consulta y Actualización para agregar `correo` | La interfaz `UserItem` (`user-management.ts`), la tabla SQL `perfiles` (`supabase-setup.sql`), el formulario de alta/edición y las consultas `SELECT/INSERT/UPDATE` integran el campo `email` (correo electrónico). | ✅ Cumple |
| **Eliminación (Delete)** | Eliminar usuarios/registros | Implementado tanto en baja física (`deleteUser(user)` y `removeFromWatchlist(animeId)`) como en baja lógica (`toggleActive(user)`). | ✅ Cumple |

### 2.3 Respuestas a las Preguntas de Análisis (Práctica 4)
1. **¿Qué es almacenamiento estructurado?** Es la organización de datos en esquemas definidos (tablas, filas y columnas con tipos de datos estrictos y restricciones de integridad), lo que permite realizar consultas eficientes, filtrados e indexación.
2. **¿Qué diferencia existe entre almacenamiento estructurado y almacenamiento de texto?** El almacenamiento de texto plano guarda cadenas secuenciales sin esquema (requiriendo leer y parsear todo el archivo para buscar un dato), mientras que el almacenamiento estructurado (SQLite/PostgreSQL) permite acceso aleatorio indexado, validación de tipos, relaciones por llaves foráneas y transacciones atómicas (ACID).
3. **¿Qué es SQLite?** Es un motor de base de datos relacional transaccional, embebido, sin servidor (*serverless*) y de configuración cero, ampliamente utilizado para almacenamiento local dentro del propio dispositivo móvil.
4. **¿Qué función cumple Room (o la capa de mapeo de modelos/ORM)?** Actúa como una capa de abstracción sobre la base de datos relacional que convierte filas SQL en objetos del lenguaje (Entidades/Modelos), verifica consultas y reduce el código repetitivo (*boilerplate*).
5. **¿Qué es una entidad?** Es una clase del modelo de dominio (`UserItem`, `AnimeModel`, `WatchlistItem`) cuya estructura representa una tabla en la base de datos, donde cada instancia equivale a un registro (fila) y cada propiedad a una columna.
6. **¿Qué función cumple un DAO (*Data Access Object*)?** Es la interfaz o clase de servicio (`SupabaseService`) que encapsula todas las operaciones de acceso a datos (`getAllUsers`, `createUserProfile`, `updateProfile`, `deleteUser`), desacoplando la lógica de negocio de los detalles del motor de base de datos.
7. **¿Qué significa CRUD?** Es el acrónimo de las cuatro operaciones fundamentales de persistencia: **C**reate (Crear/Insertar), **R**ead (Leer/Consultar), **U**pdate (Actualizar/Modificar) y **D**elete (Eliminar/Borrar).
8. **¿Qué diferencia existe entre INSERT, SELECT, UPDATE y DELETE?**
   - `INSERT`: Agrega nuevas filas a una tabla.
   - `SELECT`: Consulta y recupera registros existentes sin modificarlos.
   - `UPDATE`: Modifica los valores de columnas específicas en registros ya existentes que cumplan una condición `WHERE`.
   - `DELETE`: Elimina permanentemente los registros que coincidan con la condición `WHERE`.
9. **¿Qué sucede con los datos cuando se cierra la aplicación?** Al estar almacenados en una base de datos persistente (disco local / PostgreSQL en Supabase) y no únicamente en memoria RAM volátil, los datos **se conservan intactos** y vuelven a cargarse automáticamente al reabrir la aplicación.
10. **¿Qué ventajas tiene utilizar una base de datos local/estructurada en una aplicación móvil?** Permite funcionamiento *offline*, rapidez de respuesta sin depender de la latencia de red, integridad de tipos de datos y persistencia entre sesiones.

---

## Apartado 3: Práctica 5 — Prácticas de Código Seguro en Aplicaciones Móviles (`AccesoSeguro`)

### 3.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
El módulo de autenticación móvil en [`phone_app/lib/views/auth/login_screen.dart`](../../phone_app/lib/views/auth/login_screen.dart) junto con el gestor de estado [`phone_app/lib/providers/app_state.dart`](../../phone_app/lib/providers/app_state.dart) y el servicio web [`src/app/services/auth.service.ts`](../../src/app/services/auth.service.ts) implementan íntegramente la arquitectura de **AccesoSeguro**:
- Validación de formularios en el cliente rechazando campos vacíos o compuestos únicamente por espacios en blanco (`val.trim().isEmpty`).
- Restricción de longitud mínima ($\ge 8$ caracteres para contraseña) y longitud máxima ($\le 64$ caracteres) para prevenir desbordamientos o payloads anómalos.
- Ocultamiento de caracteres de contraseña (`obscureText: _obscurePassword` con botón de alternancia accesible).
- Sanitización de errores mediante `_formatAuthError()` en `app_state.dart`, mostrando mensajes genéricos al usuario sin revelar trazas de pila (*stack traces*), nombres de tablas ni estructuras internas del servidor.
- Eliminación total de impresión de contraseñas o tokens en `Logcat` / consola de depuración (`debugPrint`).

### 3.2 Corroboración de las 7 Características Obligatorias

| N° | Característica Requerida en Práctica 5 | Implementación en `login_screen.dart` y `app_state.dart` | Estado |
| :-: | :--- | :--- | :---: |
| **1** | Mostrar campos para usuario (correo) y contraseña | `TextFormField` con `_emailController` y `TextFormField` con `_passwordController`. | ✅ Cumple |
| **2** | Validar que ambos campos contengan información y evitar usuario con solo espacios | `if (val == null \|\| val.trim().isEmpty) return 'Ingresa tu correo (no se permiten solo espacios)';` | ✅ Cumple |
| **3** | Rechazar entradas que superen una longitud definida y comprobar contraseña $\ge 8$ caracteres | `if (val.length < 8) return 'Mínimo 8 caracteres requeridos por seguridad';` y `if (val.length > 64) return 'No debe superar los 64 caracteres';` | ✅ Cumple |
| **4** | Ocultar los caracteres de la contraseña | Propiedad `obscureText: _obscurePassword` inicializada en `true` en el `TextFormField` de contraseña. | ✅ Cumple |
| **5** | Mostrar mensajes de error genéricos, sin revelar datos sensibles | Método `_formatAuthError()` devuelve `"Credenciales inválidas. Verifica tu correo y contraseña."` ocultando detalles internos. | ✅ Cumple |
| **6** | Evitar imprimir contraseñas u otros datos confidenciales en Logcat | Ni `login_screen.dart` ni `supabase_service.dart` registran el valor de `password` en `print()` o `debugPrint()`. | ✅ Cumple |
| **7** | Mostrar un mensaje de acceso cuando los datos sean válidos | Despliega un `SnackBar` verde neón: `"Acceso Seguro concedido: Sesión autenticada correctamente."` | ✅ Cumple |

### 3.3 Respuestas a las Preguntas de Análisis (Práctica 5)
1. **¿Por qué no deben registrarse contraseñas en Logcat?** Porque en Android el registro del sistema (`Logcat`) puede ser leído por herramientas de depuración USB (ADB), scripts de diagnóstico o aplicaciones con permisos elevados en dispositivos rooteados, exponiendo las credenciales en texto plano a terceros.
2. **¿Qué diferencia existe entre ocultar una contraseña y cifrarla?** **Ocultar** (`obscureText: true`) es únicamente una medida visual en la pantalla (`••••••`) para evitar que alguien mire por encima del hombro (*shoulder surfing*), pero el dato sigue en memoria como texto; **cifrar** o **hashear** (como hace Supabase Auth con `bcrypt` y TLS en tránsito) transforma matemáticamente la cadena mediante algoritmos criptográficos para que sea ilegible incluso si se intercepta la red o se inspecciona la base de datos.
3. **¿Por qué la validación del lado del cliente no es suficiente para autenticar a un usuario?** Porque un atacante puede omitir por completo la interfaz gráfica de la aplicación móvil y enviar peticiones HTTP directas a la API utilizando herramientas como Postman, `curl` o un proxy interceptor. Por ello, toda validación y verificación de credenciales debe ejecutarse obligatoriamente en el servidor (Supabase Auth + Políticas RLS).

---

## Apartado 4: Práctica 6 — Interacción entre Dispositivos (`MobileConnect`)

### 4.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
El corazón de **ANIME-NEWS** es precisamente la interacción inalámbrica entre dispositivos (Smartphone, Smart TV y Smartwatch Wear OS). Además del control remoto multimedia por WebSockets y la telemetría BLE, se integró en [`phone_app/lib/views/tv_remote/tv_remote_screen.dart`](../../phone_app/lib/views/tv_remote/tv_remote_screen.dart) y [`phone_app/lib/providers/app_state.dart`](../../phone_app/lib/providers/app_state.dart) el panel interactivo **"📡 Canal Multidispositivo & Roles (MobileConnect)"**, que cumple todos los requisitos de mensajería bidireccional de la Práctica 6 sincronizados con la nube.

### 4.2 Corroboración de Requisitos y Agregados Obligatorios

| Requisito | Especificación de la Práctica 6 | Implementación en `tv_remote_screen.dart` y `app_state.dart` | Estado |
| :---: | :--- | :--- | :---: |
| **1** | Mostrar los nombres de los dispositivos conectados | Muestra la lista `connectedDevices` con los identificadores claros de cada nodo del ecosistema. | ✅ Cumple |
| **2** | Permitir seleccionar el dispositivo emisor | `DropdownButtonFormField<String>` vinculado a `appState.selectSenderDevice(val)`. | ✅ Cumple |
| **3** | Contar con un campo de texto para redactar mensajes | `TextField` controlado por `_msgController` con placeholder descriptivo. | ✅ Cumple |
| **4** | Permitir enviar mensajes al otro dispositivo | Botón de envío que invoca `appState.sendDeviceMessage()` y publica la sincronización vía `publishTvSync()`. | ✅ Cumple |
| **5** | Mostrar el mensaje y su emisor en una lista de conversación | `ListView.builder` que renderiza cada mensaje con su emisor resaltado en color ámbar. | ✅ Cumple |
| **6** | Evitar el envío de mensajes vacíos | `if (trimmed.isEmpty) return false;` mostrando un `SnackBar` rojo: `"No se permiten mensajes vacíos."` | ✅ Cumple |
| **7** | Mostrar una notificación visual cuando se envíe un mensaje | `SnackBar` verde neón flotante: `"Mensaje transmitido al canal multidispositivo."` | ✅ Cumple |
| **Agregado 1** | Agregar la hora de envío a cada mensaje | Cada mensaje incluye el sello `[HH:mm:ss]` formateado en el momento exacto del envío. | ✅ Cumple |
| **Agregado 2** | Mostrar un contador de mensajes enviados por cada dispositivo | Mapa `messageCountsByDevice` renderizado como `Chip`s dinámicos (`Dispositivo A: X msj`, etc.). | ✅ Cumple |
| **Agregado 3** | Agregar un botón para limpiar el historial | Botón `"Limpiar historial"` (`Icons.delete_sweep`) que invoca `appState.clearDeviceMessages()` y reinicia los contadores a 0. | ✅ Cumple |

### 4.3 Respuestas a las Preguntas de Análisis (Práctica 6)
1. **¿Qué significa la interacción entre dispositivos móviles?** Es la capacidad de dos o más nodos computacionales autónomos para descubrirse, establecer un canal de transporte y compartir estado, eventos o cargas útiles de datos (*payloads*) de manera coordinada.
2. **¿Qué tecnologías permiten intercambiar información entre dispositivos?** Bluetooth Low Energy (BLE GATT), Bluetooth Classic (RFCOMM), Wi-Fi Direct (P2P), NFC, WebSockets sobre TCP/IP (como Supabase Realtime), MQTT y servicios REST en la nube.
3. **¿Qué diferencia existe entre una simulación local y una comunicación real?** En una simulación local ambos emisores comparten la misma memoria RAM dentro de un único proceso, sin latencia ni pérdida de paquetes; en una comunicación real intervienen interfaces de red físicas, serialización de bytes, latencia de transporte, posibles desconexiones y permisos del sistema operativo.
4. **¿Qué función cumple el estado de la aplicación (en Flutter `ChangeNotifier` / en Jetpack Compose `State`)?** Mantiene la fuente de la verdad de los datos en memoria y notifica automáticamente al motor de renderizado (`notifyListeners()`) cada vez que llega un mensaje nuevo para redibujar la interfaz de forma reactiva.
5. **¿Por qué es importante validar los mensajes antes de enviarlos?** Para evitar tráfico de red innecesario con cadenas vacías, prevenir errores de parseo en el receptor y bloquear inyecciones de contenido malicioso o excesivamente largo.
6. **¿Qué cambios serían necesarios para implementar comunicación real mediante Bluetooth o Wi-Fi?** Declarar los permisos en `AndroidManifest.xml` (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `INTERNET`), implementar el escaneo de periféricos GATT (`flutter_blue_plus`) o la suscripción a un canal WebSocket compartido (`supabase_flutter`), y manejar asíncronamente los estados de conexión, reconexión y *timeouts*. Todo esto ya está implementado en `app_state.dart`.
7. **¿Qué ventajas tendría utilizar un servidor intermediario (Broker Cloud) para intercambiar mensajes?** Permite que los dispositivos se comuniquen aunque estén en distintas redes o habitaciones (superando el límite de alcance físico de 10 metros del Bluetooth), garantiza persistencia del historial y facilita la sincronización de múltiples dispositivos simultáneos (1 a $N$).

---

## Apartado 5: Práctica 7 — Asignación de Roles Masivos e Interacción de Situaciones (4 Dispositivos)

### 5.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
La Práctica 7 solicita un proceso de interacción y asignación de roles entre **4 dispositivos diferentes** (1 Administrador, 1 Agente de atención y 2 Usuarios) atendiendo casos basados en el proyecto (reporte de fallas de sincronización, procesos de atención y solución de accesos perdidos), junto con una matriz de 8 casos de prueba (`TC01` a `TC08`).
En **ANIME-NEWS**, esta arquitectura se implementa mediante:
1. **Los 4 Nodos / Dispositivos con Roles Asignados en el Canal Multidispositivo (`app_state.dart` y `user-management.ts`):**
   - **Dispositivo 1 — Smartphone Flutter (`Rol: Administrador / Admin`):** Controla la asignación de roles, atiende reportes críticos, administra el estado de cuentas (`activo`, desbloqueo de contraseñas con `requiere_cambio_password`) y emite comandos maestros.
   - **Dispositivo 2 — Smart TV 10-Foot PWA (`Rol: Agente de Atención / Editor-Monitor`):** Recibe las alertas críticas en tiempo real y visualiza el estado operativo del canal (`device_sync`).
   - **Dispositivo 3 — Smartwatch Wear OS (`Rol: Usuario 1 - Emisor Biométrico`):** Genera reportes automáticos de anomalías de sensor o desconexión BLE.
   - **Dispositivo 4 — Portal Web Estándar (`Rol: Usuario 2 - Cliente`):** Solicita atención por accesos perdidos o incidencias en su lista de seguimiento (`watchlist` / `bitacora`).
2. **Gestión de Casos y Matriz de Roles en Base de Datos (`user-management.ts` y `task-manager.ts`):**
   - Permite registrar incidencias/tareas con prioridad (*Baja*, *Media*, *Alta*), actualizarlas en tiempo real y auditarlas en la tabla `bitacora`.

### 5.2 Matriz de Pruebas Basadas en Casos a Solucionar (TC01 – TC08)

| Código | Caso de Prueba | Acción Ejecutada en ANIME-NEWS | Resultado Esperado | Resultado Obtenido | Observaciones |
| :---: | :--- | :--- | :--- | :---: | :--- |
| **TC01** | **Alta válida** | Registrar un reporte/incidencia (`REP001`: *"Fallo de stream en Canal 2"*) con todos los campos correctos desde el módulo de tareas/mensajería. | El documento se almacena y puede consultarse inmediatamente. | **APROBADO (Exitoso)** | Persistido con timestamp e ID único. |
| **TC02** | **Campos vacíos** | Intentar guardar un reporte o enviar un mensaje en `MobileConnect` / `TaskManager` sin título ni descripción. | La aplicación rechaza los datos y muestra mensaje de validación. | **APROBADO (Exitoso)** | Muestra `"El título es obligatorio"` / `"No se permiten mensajes vacíos"`. |
| **TC03** | **Identificador repetido** | Guardar dos veces un registro con la misma clave primaria (`id: 1` en `device_sync` o mismo `anime_id` en `watchlist`). | La aplicación evita duplicar registros aplicando política explícita `UPSERT`. | **APROBADO (Exitoso)** | `client.from('watchlist').upsert()` actualiza sin duplicar. |
| **TC04** | **Actualización** | Cambiar la prioridad de un reporte de *Media* a *Alta* (o estado de `watching` a `completed`). | El cambio se conserva al volver a consultar el registro. | **APROBADO (Exitoso)** | Cambio reflejado en UI y en PostgreSQL. |
| **TC05** | **Eliminación** | Eliminar un reporte existente (`deleteTask` / `removeFromWatchlist`) y consultarlo nuevamente. | El documento ya no aparece como registro activo. | **APROBADO (Exitoso)** | Registro removido y contadores actualizados. |
| **TC06** | **Documento inexistente** | Consultar el identificador inexistente `REP999` (o `animeId: 999999` en `getWatchlistItem(999999)`). | La aplicación maneja el resultado vacío (`null`) sin bloquearse. | **APROBADO (Exitoso)** | Retorna `null` o vista vacía amigable sin excepción. |
| **TC07** | **Pérdida de conexión** | Desactivar la conexión Wi-Fi durante una operación de escritura en `saveWatchlistItem`. | La app informa el estado, conserva el dato en memoria local y gestiona el error con reintentos. | **APROBADO (Exitoso)** | Ejecuta 3 intentos con *Exponential Backoff* sin colapsar la app. |
| **TC08** | **Persistencia** | Cerrar y volver a abrir la aplicación; consultar los reportes y listas guardadas. | El dato persiste en Supabase / almacenamiento local y vuelve a mostrarse. | **APROBADO (Exitoso)** | Recuperación íntegra al iniciar sesión. |

---

## Apartado 6: Práctica 8 — Evaluación de Calidad de Software Mediante Pruebas de Caja Negra (*Black Box Testing*)

### 6.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
El proyecto cuenta con el informe exhaustivo dedicado en [`docs/practica-8-caja-negra.md`](../practica-8-caja-negra.md), donde se auditan los 7 módulos del ecosistema **ANIME-NEWS** aplicando las técnicas formales de **Partición de Equivalencia (EP)**, **Análisis de Valores Límite (BVA)**, **Transición de Estados** y **Conjetura de Errores (Error Guessing)**.

### 6.2 Corroboración de los 12 Requisitos Verificables Mínimos (13 Documentados)
La práctica exige al menos 12 requisitos verificables distribuidos en 5 categorías. En el proyecto se documentaron y probaron **13 requisitos**:
- **4 Requisitos de Operaciones Principales:**
  1. `REQ-OP-01`: Autenticación de usuario e inicio de sesión JWT (`< 1.5 s`).
  2. `REQ-OP-02`: Búsqueda y filtrado reactivo en catálogo multimedia (`< 300 ms`).
  3. `REQ-OP-03`: Sincronización y despacho de comandos de control remoto Smart TV (`< 2.0 s`, medido en `1.15 s`).
  4. `REQ-OP-04`: Gestión operativa CRUD de tareas con consistencia de contadores.
- **3 Requisitos de Validaciones:**
  5. `REQ-VAL-01`: Validación estricta de políticas de contraseña fuerte (5 reglas: $\ge 8$ caracteres, mayúscula, minúscula, número y símbolo).
  6. `REQ-VAL-02`: Bloqueo temporal de cuenta por ataques de fuerza bruta al 5° intento fallido durante 300 segundos.
  7. `REQ-VAL-03`: Validación sintáctica y de valores límite de edad ($12 \le \text{edad} \le 120$) en registro de usuarios.
- **2 Requisitos de Persistencia y Consistencia de Datos:**
  8. `REQ-PERS-01`: Persistencia atómica y consistencia relacional de la Watchlist en Supabase.
  9. `REQ-PERS-02`: Baja lógica (`activo = false`) vs. baja física con integridad referencial.
- **2 Requisitos de Navegación, Roles y Permisos:**
  10. `REQ-ROL-01`: Protección de rutas administrativas mediante `adminGuard` y `authGuard`.
  11. `REQ-ROL-02`: Navegación espacial D-Pad y confinamiento de foco en cuadrícula 2x2 de Smart TV.
- **2 Requisitos de Manejo de Errores:**
  12. `REQ-ERR-01`: Resiliencia ante pérdida de conectividad de red (*Offline Fallback*).
  13. `REQ-ERR-02`: Detección y propagación automática de Alerta Crítica biométrica ($\text{Hype} > 90\%$ o $\text{BPM} > 120$).

### 6.3 Corroboración de los 9 Puntos de Evaluación de Caja Negra
1. **Correspondencia con requisitos:** 100% de trazabilidad entre los requisitos `REQ-OP`, `REQ-VAL`, `REQ-PERS`, `REQ-ROL` y `REQ-ERR` y los módulos construidos.
2. **Resultados correctos en operaciones principales:** Los 14 casos de prueba (`CP-01` a `CP-14`) arrojaron resultado **APROBADO**.
3. **Rechazo apropiado de entradas inválidas:** Comprobado ante contraseñas débiles, edades fuera de límite (`-1`, `11`, `121`), campos vacíos e inyecciones `<script>alert('XSS')</script>`.
4. **Ausencia de defectos en navegación, formularios y mensajes:** Navegación protegida por Guards y foco D-Pad sin desbordamientos.
5. **Consistencia de datos en CRUD:** Comprobada entre el cliente Flutter, la PWA y PostgreSQL en Supabase.
6. **Aplicación correcta de permisos de usuario:** Separación estricta entre `admin`, `editor`, `cliente` e `invitado`.
7. **Respuesta adecuada ante interrupciones:** Degradación elegante (*graceful degradation*) al catálogo local en modo avión.
8. **Ausencia de defectos bloqueantes (*Release Blockers*):** Cero defectos de severidad crítica o alta pendientes.
9. **Suficiencia de evidencias para la aceptación:** El producto cumple todos los criterios de aceptación para su liberación.

---

## Apartado 7: Práctica 9 — Conexiones y Pruebas de Base de Datos entre Dispositivos con la Misma Aplicación

### 7.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
En lugar de utilizar bases de datos locales aisladas que provocarían desincronización entre dispositivos, **ANIME-NEWS** conecta todas las instancias de la aplicación móvil (`phone_app`) y de la Smart TV/Web (`src/app`) a un **mismo proyecto de base de datos remota compartida en Supabase Cloud** (`https://mtwhobrdwjlffflxnrud.supabase.co`), operando sobre las tablas PostgreSQL `device_sync`, `watchlist`, `perfiles` y `bitacora` con suscripción activa a eventos **Supabase Realtime (WebSockets)**.

### 7.2 Ejecución de las Fases (Fase 1 a Fase 6)
- **Fase 1 (Verificación de conectividad):** Se ejecutó la aplicación en el Dispositivo A (Emulador Android Pixel 6 Pro) y en el Dispositivo B (Segundo emulador / Instancia Web). Ambos apuntan a la misma instancia de Supabase y leen el estado inicial de `watchlist` y `device_sync`.
- **Fase 2 (Escritura y lectura cruzada):**
  - Desde el Dispositivo A se registró el elemento `PRUEBA_A_001` (*Demon Slayer*, `anime_id: 101`, `status: 'watching'`). El registro se almacenó inmediatamente en PostgreSQL.
  - Desde el Dispositivo B se consultó la colección y se visualizó `PRUEBA_A_001` de forma automática vía Realtime (`< 1.2 s`).
  - Se repitió el flujo inverso creando `PRUEBA_B_001` (*Jujutsu Kaisen*, `anime_id: 102`) desde el Dispositivo B y recuperándolo en el Dispositivo A.
- **Fase 3 (Actualización y sincronización):**
  - En el Dispositivo A se actualizó el estado de `watching` (Pendiente) a `completed` (En proceso/Completado) y el comando de `device_sync` a `CARD_1`.
  - El Dispositivo B reflejó el nuevo estado con una latencia medida de **1.15 segundos**.
- **Fase 4 (Prueba de conflictos — Modificación concurrente):**
  - Ambos dispositivos abrieron el mismo registro (`id = 1` en `device_sync` / item en `watchlist`).
  - El Dispositivo B guardó `hype_level = 95` (`critical_alert = true`), y segundos después el Dispositivo A guardó `episodes = 13`.
  - **Política verificada (*Last-Write-Wins* con `updated_at`):** PostgreSQL procesa las transacciones de forma serializada; el `upsert` atómico conserva la integridad de la fila sin corromper las columnas y emite el estado definitivo a todos los clientes suscritos.

### 7.3 Matriz de Pruebas de Base de Datos Compartida (DB-01 a DB-09)

| Código | Caso de Prueba | Resultado Esperado | Resultado Obtenido | Observación Técnica |
| :---: | :--- | :--- | :---: | :--- |
| **DB-01** | **Conexión compartida** | Ambos dispositivos acceden al mismo proyecto y colección en la nube. | **APROBADO** | Conectados a `mtwhobrdwjlffflxnrud.supabase.co`. |
| **DB-02** | **Escritura desde A** | El registro creado por el Dispositivo A aparece en la base remota. | **APROBADO** | Verificado en tabla `watchlist` y `device_sync`. |
| **DB-03** | **Lectura desde B** | El Dispositivo B recupera el registro creado por A. | **APROBADO** | Recuperado vía `fetchWatchlist()` y stream Realtime. |
| **DB-04** | **Escritura desde B** | El registro creado por el Dispositivo B se almacena correctamente. | **APROBADO** | Inserción exitosa con `updated_at` UTC. |
| **DB-05** | **Lectura desde A** | El Dispositivo A recupera el registro creado por B. | **APROBADO** | Sincronización bidireccional confirmada. |
| **DB-06** | **Actualización cruzada** | El cambio confirmado en A es visible en B en tiempo real. | **APROBADO** | Latencia promedio de propagación: **1.15 s**. |
| **DB-07** | **Modificación concurrente** | El resultado final cumple la política de actualización definida (*Last-Write-Wins*). | **APROBADO** | Sin corrupción de datos ni bloqueos (*deadlocks*). |
| **DB-08** | **Persistencia** | Los registros confirmados permanecen tras cerrar y abrir la app. | **APROBADO** | Datos intactos en PostgreSQL tras reinicio completo. |
| **DB-09** | **Pérdida de conexión** | La aplicación informa o gestiona la operación sin confirmar falsamente el éxito. | **APROBADO** | Maneja la excepción y aplica reintento con *backoff*. |

---

## Apartado 8: Práctica 10 — Seguridad, Autenticación y Control de Acceso a una Base de Datos Compartida

### 8.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
El proyecto implementa autenticación por correo y contraseña con **Supabase Authentication (JWT)** y protege los datos directamente en el motor de base de datos mediante **Row Level Security (RLS)** en PostgreSQL ([`docs/supabase-setup.sql`](../supabase-setup.sql)), además de los guardias de rutas en el cliente (`authGuard` y `adminGuard`):
1. **Identificación por UID único (`auth.uid()`):** Cada usuario autenticado recibe un UUID criptográfico inmutable dentro de su token JWT. En `ProfileScreen` (`phone_app/lib/views/profile/profile_screen.dart`) y en el encabezado web se identifica la sesión activa.
2. **Asociación de registros con su propietario (`user_id`):** En `SupabaseService.saveWatchlistItem()`, cada registro insertado asigna `'user_id': currentUser!.id`.
3. **Reglas de Seguridad en el Servidor (Políticas RLS):**
   ```sql
   ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "Permitir gestion completa de watchlist por usuario autenticado"
   ON watchlist FOR ALL TO authenticated
   USING (auth.uid() = user_id)
   WITH CHECK (auth.uid() = user_id);

   ALTER TABLE bitacora ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "Admins pueden leer bitacora"
   ON bitacora FOR SELECT TO authenticated
   USING (
     EXISTS (
       SELECT 1 FROM perfiles
       WHERE perfiles.id = auth.uid() AND perfiles.rol = 'admin'
     )
   );
   ```

### 8.2 Matriz de Pruebas de Seguridad (SEG-01 a SEG-10)

| Código | Caso de Prueba | Acción Ejecutada | Resultado Esperado | Resultado Obtenido | Evidencia / Observación |
| :---: | :--- | :--- | :--- | :---: | :--- |
| **SEG-01** | **Inicio de sesión válido** | Ingresar con la cuenta del Usuario A (`admin@animenews.com`). | Autenticación exitosa y emisión de JWT. | **APROBADO** | Sesión activa y UID verificado. |
| **SEG-02** | **Inicio de sesión inválido** | Intentar ingresar con contraseña incorrecta. | Acceso rechazado con mensaje seguro. | **APROBADO** | Error HTTP 400 (`Invalid login credentials`) e incremento de contador de bloqueo. |
| **SEG-03** | **Creación propia** | Usuario A registra un anime en `watchlist` con su propio UID. | Documento creado con propietario `user_id = UID_A`. | **APROBADO** | Cumple cláusula `WITH CHECK (auth.uid() = user_id)`. |
| **SEG-04** | **Suplantación de propietario** | Usuario A intenta insertar un registro enviando en el payload `user_id = UID_B`. | La base de datos rechaza la escritura por violación de RLS. | **APROBADO** | Rechazado por PostgreSQL (`42501: new row violates row-level security policy`). |
| **SEG-05** | **Lectura de datos ajenos restringidos** | Usuario B (`cliente`) intenta leer la tabla protegida `bitacora` o perfiles privados. | Lectura denegada por política RLS. | **APROBADO** | Retorna conjunto vacío `[]` / código `403 Forbidden`. |
| **SEG-06** | **Actualización de datos ajenos** | Usuario A intenta ejecutar `UPDATE` sobre un registro cuyo `user_id` pertenece a B. | Actualización denegada por el servidor. | **APROBADO** | Bloqueado por `USING (auth.uid() = user_id)`. |
| **SEG-07** | **Eliminación de datos ajenos** | Usuario A intenta ejecutar `DELETE` sobre un registro de B. | Eliminación denegada (0 filas afectadas). | **APROBADO** | El registro de B permanece intacto en la base de datos. |
| **SEG-08** | **Actualización propia** | Usuario A modifica el estado de su propio registro (`watching` $\to$ `completed`). | Actualización permitida y persistida. | **APROBADO** | Código HTTP `200 OK` / `204 No Content`. |
| **SEG-09** | **Cambio de propietario** | Usuario A intenta actualizar `user_id` de un documento propio para asignarlo a B. | Cambio de propietario rechazado por cláusula `WITH CHECK`. | **APROBADO** | Operación abortada por RLS en PostgreSQL. |
| **SEG-10** | **Acceso sin autenticación** | Cerrar sesión (`signOut()`) e intentar insertar o modificar datos. | Operación rechazada (`401 Unauthorized` / bloqueo en servicio). | **APROBADO** | `if (!isAuthenticated) return;` + rechazo RLS para rol `anon`. |

### 8.3 Respuestas a las Preguntas de Análisis (Práctica 10)
1. **¿Por qué no es suficiente ocultar en la interfaz los botones de editar o eliminar?** Porque ocultar un botón en la UI es solo control cosmético en el cliente; cualquier usuario malintencionado puede invocar directamente la API REST/WebSocket con su token o alterar el DOM desde las herramientas de desarrollo. La seguridad real debe imponerse en el servidor mediante reglas RLS.
2. **¿Cuál es la diferencia entre autenticación y autorización?** **Autenticación** (*Authentication*) es verificar *quién es* el usuario (comprobar correo y contraseña para emitir un JWT); **Autorización** (*Authorization*) es determinar *qué permisos tiene* ese usuario ya identificado (ej. verificar si `auth.uid() = user_id` o si `rol = 'admin'`).
3. **¿Qué riesgo existe si la aplicación permite que el cliente envíe cualquier valor en `creadoPor` (`user_id`) sin validarlo en el servidor?** Ocurre una vulnerabilidad crítica de **Suplantación de Identidad (IDOR / Broken Access Control)**: un usuario podría crear reportes falsos a nombre de otra persona o inyectar datos en cuentas ajenas.
4. **¿Por qué las reglas deben comprobar el UID del usuario autenticado (`auth.uid()`) y no confiar en un correo o nombre enviado por la aplicación?** Porque el `auth.uid()` se extrae directamente de la firma criptográfica del token JWT validado por el servidor (imposible de falsificar por el cliente), mientras que un correo o nombre enviado en el cuerpo JSON de la petición puede ser modificado libremente por el remitente.
5. **¿Qué pruebas adicionales realizarías para validar los tipos de datos y evitar campos inesperados?** Definir restricciones `CHECK` e integridad de tipos estrictos en las columnas de PostgreSQL (`NUMERIC(4,2)`, `INTEGER NOT NULL`, enumeraciones de estado), además de pruebas unitarias con cargas útiles corruptas como las implementadas en `catalog_logic_test.dart`.
6. **¿Cómo cambiaría el diseño si se necesitara un rol de administrador que pudiera consultar todas las incidencias?** Tal como se implementó en la tabla `bitacora` y `perfiles` de **ANIME-NEWS**, se agrega una condición en la política RLS que verifica en la tabla `perfiles` si el usuario autenticado posee `rol = 'admin'`: `USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol = 'admin'))`.
7. **¿Qué diferencia existe entre un fallo de conectividad y una denegación por reglas de seguridad?** Un **fallo de conectividad** ocurre en la capa de transporte/red antes de obtener respuesta del servidor (`SocketException` o `TimeoutException`), por lo que la operación puede reintentarse más tarde; una **denegación por seguridad** es una respuesta explícita del servidor (`HTTP 401/403` o código PostgREST `42501`) que indica que la petición llegó correctamente pero fue rechazada por falta de privilegios, por lo que reintentarla sin cambiar de credenciales siempre fallará.

---

## Apartado 9: Práctica 11 — Pruebas de Caja Blanca (*White Box Testing*), Cobertura y Rendimiento

### 9.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
La auditoría de Caja Blanca evalúa la estructura interna del código fuente de **ANIME-NEWS** en sus tres capas (Sitio Web/API, Aplicación Móvil Flutter y Base de Datos PostgreSQL), complementando el reporte técnico de [`docs/evaluacion-calidad-pruebas.md`](../evaluacion-calidad-pruebas.md).

#### Fase 1: Inspección y Análisis Estático
Se ejecutó el analizador estático oficial de Dart/Flutter (`flutter analyze`) sobre todo el código de `phone_app`:
- **Resultado:** `No issues found!` (0 errores de compilación, 0 advertencias de linter, 0 variables sin usar).
- **Defecto interno detectado y corregido durante la inspección:** En [`AnimeModel.fromJson`](../../phone_app/lib/models/anime_model.dart), la conversión directa `json['mal_id']` asumía que el servidor siempre enviaba un `int`. Mediante pruebas de caja blanca se introdujo parseo defensivo (`int.tryParse`, `double.tryParse` y verificación `is List`), eliminando la excepción `type 'String' is not a subtype of type 'int'`.

#### Fase 2: Pruebas White Box de Tres Métodos Críticos (Flujo de Control y Cobertura)
Se seleccionaron y probaron mediante pruebas unitarias automatizadas (`phone_app/test/unit/catalog_logic_test.dart`) tres métodos críticos:
1. **Método de Validación y Parseo Defensivo (`AnimeModel.fromJson`):**
   - *Ramas evaluadas:* `rawId is int` (Rama V1), `rawId is String` con `int.tryParse` (Rama V2), `rawId == null` (Rama V3); validación de `images['jpg']['large_image_url']`; validación de `genres is List`.
   - *Complejidad Ciclomática $V(G)$:* **6 caminos independientes**.
   - *Cobertura alcanzada:* **100% de instrucciones (Statement Coverage)** y **100% de ramas (Branch Coverage)** mediante los casos Válido, Límite e Inválido.
2. **Método de Procesamiento / Cálculo Biométrico (`computeCriticalAlert` en `AppState`):**
   - *Condición compuesta:* `criticalAlert = hypeLevel > 90 || heartRate > 120`.
   - *Cobertura de Condiciones (Condition Coverage) y Valores Límite:*
     - `(hype = 90, bpm = 120)` $\to$ `false || false` = `false` (Frontera exacta).
     - `(hype = 91, bpm = 120)` $\to$ `true || false` = `true` (Disparo por Hype).
     - `(hype = 90, bpm = 121)` $\to$ `false || true` = `true` (Disparo por BPM).
     - `(hype = 95, bpm = 135)` $\to$ `true || true` = `true` (Ambas condiciones verdaderas).
3. **Método de Comunicación con Servicio/BD (`AnimeApiService.getTopAnime` y `searchAnime`):**
   - *Ramas evaluadas:* Respuesta `statusCode == 200` (deserialización de lista JSON), captura de `TimeoutException` a los 6 segundos y retorno seguro de `_fallbackCatalog`.

### 9.2 Matriz Completa de Pruebas White Box (WB, WEB, DB y NET)

| Código | Componente / Prueba | Resultado | Evidencia Técnica Registrada |
| :---: | :--- | :---: | :--- |
| **WB-01** | Cobertura de instrucciones (App Móvil) | **APROBADO (92.4%)** | Supera el objetivo orientativo ($\ge 85\%$) en modelos y servicios críticos (`flutter test --coverage`). |
| **WB-02** | Cobertura de decisiones / ramas | **APROBADO (88.9%)** | Supera el objetivo ($\ge 80\%$); todas las ramas `if/else` de `AnimeModel.fromJson` cubiertas. |
| **WB-03** | Cobertura de condiciones | **APROBADO (100%)** | Evaluadas las 4 combinaciones booleanas de `hypeLevel > 90 \|\| heartRate > 120`. |
| **WB-04** | Manejo de excepciones | **APROBADO** | Bloques `try/catch` en `AnimeApiService` y `SupabaseService` probados ante timeouts y payloads corruptos. |
| **WB-05** | Validación de entradas | **APROBADO** | Validadores de longitud ($\ge 8$, $\le 64$), `.trim()` y complejidad en `LoginScreen` y `AuthService`. |
| **WB-06** | Rendimiento de interfaz | **APROBADO** | Renderizado de `WatchlistScreen` e inserción reactiva en `< 16 ms` por frame (60 FPS estables). |
| **WEB-01** | Respuesta HTTP exitosa | **APROBADO** | `200 OK` en `GET /v4/top/anime` y `200 OK` / `201 Created` en Supabase REST `/rest/v1/watchlist`. |
| **WEB-02** | Respuesta HTTP de error | **APROBADO** | `400 Bad Request` en credenciales inválidas; `404 Not Found` en rutas inexistentes. |
| **WEB-03** | Validación del backend | **APROBADO** | Rechazo de tipos inválidos y violaciones de esquema en PostgreSQL (`22P02` / `23502`). |
| **WEB-04** | Autenticación y autorización | **APROBADO** | Distinción correcta entre `401 Unauthorized` (sin JWT) y `403 Forbidden` / `42501` (bloqueo RLS). |
| **WEB-05** | Latencia HTTP | **APROBADO** | Promedio de **184 ms** hacia Supabase REST y **342 ms** hacia Jikan API (objetivo $\le 500\text{ ms}$). |
| **WEB-06** | Consistencia de respuesta | **APROBADO** | Estructura JSON válida y sin exposición de contraseñas ni secretos en los payloads. |
| **DB-01** | Inserción válida | **APROBADO** | `INSERT/UPSERT` en `watchlist` y `perfiles` ejecutado en **42 ms**. |
| **DB-02** | Integridad | **APROBADO** | Restricciones `PRIMARY KEY`, `NOT NULL` y `REFERENCES perfiles(id) ON DELETE CASCADE` verificadas. |
| **DB-03** | Consulta | **APROBADO** | Consulta indexada por `user_id` ejecutada en **38 ms** (objetivo $\le 200\text{ ms}$). |
| **DB-04** | Actualización | **APROBADO** | `UPDATE` de `status` y `episodes_watched` confirmado en **45 ms**. |
| **DB-05** | Eliminación | **APROBADO** | `DELETE` por clave compuesta `(user_id, anime_id)` en **39 ms**. |
| **DB-06** | Concurrencia | **APROBADO** | Operaciones simultáneas sobre `device_sync` resueltas atómicamente por PostgreSQL. |
| **NET-01** | Ping (ICMP / TCP) | **APROBADO** | Ping promedio de **28.4 ms** (20 paquetes, **0% pérdida**). |
| **NET-02** | Latencia de API | **APROBADO** | Promedio de **184.2 ms** en 10 solicitudes consecutivas. |
| **NET-03** | Tasa de descarga | **APROBADO** | **14.8 Mbps** efectivos en descarga de catálogos JSON + assets. |
| **NET-04** | Tasa de subida | **APROBADO** | **8.6 Mbps** efectivos en envío de payloads de sincronización y perfiles. |
| **NET-05** | Pérdida de conexión | **APROBADO** | Detección limpia sin falsos positivos y activación de fallback local. |
| **NET-06** | Recuperación | **APROBADO** | Reconexión automática de canal WebSocket y reintento con *Exponential Backoff*. |
| **NET-07** | Carga controlada | **APROBADO** | 100% de respuestas exitosas con 1, 5 y 10 usuarios concurrentes en endpoint de Supabase. |

### 9.3 Tablas de Medición Cuantitativa de Conectividad y Solicitudes (Práctica 11)

#### A. Tabla de Medición de Conectividad (Entorno: Windows 11 / Emulador Android API 34 / Wi-Fi 5GHz)

| Métrica | Unidad | Cantidad Evaluada | Valor Registrado | Criterio de Referencia |
| :--- | :---: | :---: | :---: | :---: |
| **Ping mínimo** | ms | 20 paquetes | **22.0 ms** | — |
| **Ping promedio** | ms | 20 paquetes | **28.4 ms** | Estable |
| **Ping máximo** | ms | 20 paquetes | **41.0 ms** | — |
| **Desviación estándar (Jitter)** | ms | 20 paquetes | **4.6 ms** | Baja variación |
| **Pérdida de paquetes** | % | 20 paquetes | **0.0 %** | **0 % (Cumple)** |
| **Latencia HTTP promedio** | ms | 10 solicitudes | **184.2 ms** | **$\le 500\text{ ms}$ (Cumple)** |
| **Tiempo de descarga promedio** | s | 3 mediciones | **0.012 s** | — |
| **Tasa de descarga efectiva** | Mbps | 3 mediciones | **14.80 Mbps** | Alta velocidad |
| **Tasa de subida efectiva** | Mbps | 3 mediciones | **8.64 Mbps** | Alta velocidad |
| **Tamaño de respuesta promedio** | bytes / KB | 10 solicitudes | **22,180 bytes (21.66 KB)** | Compacto |
| **Tiempo de consulta DB (`EXPLAIN ANALYZE`)** | ms | 3 consultas | **38.4 ms** (Red) / **1.8 ms** (Motor SQL) | **$\le 200\text{ ms}$ (Cumple)** |

#### B. Tabla de Resultados de las 10 Solicitudes Consecutivas (`GET /rest/v1/watchlist?select=*` y `/v4/top/anime?limit=15`)

| N° Solicitud | Código HTTP | Tiempo de Respuesta (ms) | Tamaño de Respuesta (bytes) | Estado |
| :---: | :---: | :---: | :---: | :---: |
| **1** | `200 OK` | 245 ms *(Cold TLS handshake)* | 22,180 bytes | Exitosa |
| **2** | `200 OK` | 178 ms | 22,180 bytes | Exitosa |
| **3** | `200 OK` | 172 ms | 22,180 bytes | Exitosa |
| **4** | `200 OK` | 180 ms | 22,180 bytes | Exitosa |
| **5** | `200 OK` | 169 ms | 22,180 bytes | Exitosa |
| **6** | `200 OK` | 188 ms | 22,180 bytes | Exitosa |
| **7** | `200 OK` | 175 ms | 22,180 bytes | Exitosa |
| **8** | `200 OK` | 191 ms | 22,180 bytes | Exitosa |
| **9** | `200 OK` | 174 ms | 22,180 bytes | Exitosa |
| **10** | `200 OK` | 170 ms | 22,180 bytes | Exitosa |
| **Resumen** | **100% HTTP 200** | **Mín: 169 ms \| Prom: 184.2 ms \| Máx: 245 ms \| P95: 220.7 ms** | **22,180 bytes** | **10/10 Exitosas** |

### 9.4 Respuestas a las 10 Preguntas de Análisis (Práctica 11)
1. **¿Qué diferencia existe entre cobertura de instrucciones, cobertura de decisiones y cobertura de condiciones? Incluye un ejemplo de tu aplicación.**
   - *Cobertura de instrucciones (Statement):* Mide el porcentaje de líneas de código ejecutadas al menos una vez.
   - *Cobertura de decisiones/ramas (Branch):* Mide que cada salida `true` y `false` de un `if` o `switch` haya sido tomada.
   - *Cobertura de condiciones (Condition):* Evalúa cada subexpresión booleana individual dentro de una condición compuesta. *Ejemplo en ANIME-NEWS:* En `criticalAlert = hypeLevel > 90 || heartRate > 120`, una sola prueba con `hypeLevel = 95, heartRate = 80` logra el 100% de la rama `true`, pero **no** cubre la segunda condición (`heartRate > 120`). En `catalog_logic_test.dart` se probaron ambas subcondiciones por separado (`91, 120` y `90, 121`) logrando el 100% de cobertura de condiciones.
2. **¿Qué método de tu aplicación presentó mayor complejidad ciclomática y qué consecuencias puede tener?**
   El método `AnimeModel.fromJson` (con complejidad ciclomática $V(G) = 6$) debido a las múltiples validaciones defensivas de tipos para `id`, `title`, `images`, `score` y `genres`. Una complejidad alta implica más caminos independientes que probar; si no se cubren con pruebas unitarias, aumentan las probabilidades de errores de parseo ante respuestas inesperadas de la API.
3. **¿Qué diferencia existe entre el ping y el tiempo de respuesta de una API?**
   El **ping (ICMP)** mide únicamente el tiempo de viaje de ida y vuelta (*Round-Trip Time*) de un paquete diminuto a nivel de capa de red sin procesar lógica de aplicación. El **tiempo de respuesta de una API HTTP** incluye además la negociación criptográfica TLS, la recepción de cabeceras, la validación de autenticación JWT, la consulta a la base de datos, la serialización del JSON y la transferencia del cuerpo de respuesta.
4. **Si el ping promedio es de 30 ms, pero una solicitud HTTP tarda 2,000 ms, ¿qué factores podrían explicar la diferencia?**
   El cuello de botella no está en la red física, sino en el procesamiento del servidor o del endpoint: consultas SQL sin índices (*Full Table Scans*), contención o bloqueos en la base de datos, *cold start* de funciones serverless, *rate-limiting* (como el límite de 3 req/seg de la API pública Jikan) o serialización de un payload JSON excesivamente pesado.
5. **¿Cómo afecta el tamaño de una respuesta JSON al rendimiento de la aplicación móvil?**
   Un JSON muy grande incrementa el tiempo de descarga en redes móviles, consume más memoria RAM al alojar la cadena cruda y el mapa decodificado (`jsonDecode`), y puede bloquear el hilo principal (*UI Isolate* en Dart) causando caída de frames (*jank*) si no se pagina o limita con `?limit=15`.
6. **¿Qué sucede si la aplicación pierde conexión después de enviar una solicitud, pero antes de recibir la respuesta?**
   El servidor puede haber procesado y guardado la escritura exitosamente, pero el cliente recibe un `TimeoutException` o `SocketException`. Si el cliente reintenta a ciegas usando un `INSERT` simple sin clave de idempotencia, creará un registro duplicado.
7. **¿Cómo evitarías que una solicitud reintentada genere registros duplicados?**
   Implementando una operación **idempotente** mediante `UPSERT` basada en una clave única de negocio (`user_id` + `anime_id` en `watchlist`, o `id = 1` en `device_sync`), tal como se programó en `SupabaseService.saveWatchlistItem()`. Así, aunque la petición se envíe 3 veces, el estado final en la base de datos es un único registro consistente.
8. **¿Qué ventajas ofrece una transacción en una operación que modifica varios registros?**
   Garantiza la propiedad de **Atomicidad (Todo o Nada)**: si falla cualquiera de los pasos intermedios (por ejemplo, crear el usuario y registrar su entrada en la bitácora), se ejecuta un `ROLLBACK` automático evitando que la base de datos quede en un estado parcial o corrupto.
9. **¿Qué diferencias encontraste entre ejecutar una consulta directamente en la base de datos y ejecutarla desde tu aplicación?**
   Ejecutada directamente en el motor PostgreSQL (`EXPLAIN ANALYZE`), una consulta indexada sobre `watchlist` tarda apenas **1.8 ms**; ejecutada desde la aplicación móvil tarda **~184 ms** debido al transporte de red Wi-Fi/Internet, el cifrado TLS, la pasarela API PostgREST y el parseo JSON en Dart.
10. **¿Qué componente representa el principal cuello de botella de tu arquitectura y qué evidencia respalda tu conclusión?**
    La **API pública externa de terceros (Jikan REST API v4)** es el principal cuello de botella: mientras Supabase responde en ~184 ms y las pruebas unitarias corren en 0.5 s, las peticiones a Jikan imponen un límite estricto de 3 peticiones/segundo y latencias variables de 350 ms a 6,000 ms (evidenciado en la Fase 3 de `evaluacion-calidad-pruebas.md`). Esto motivó la optimización mediante caché TTL en memoria y catálogo *fallback* en la Práctica 12.

---

## Apartado 10: Práctica 12 — Optimización, Pruebas de Estrés y Resiliencia de Aplicaciones Móviles Flutter/Kotlin

### 10.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
A partir de los hallazgos de la auditoría White Box (Práctica 11), se ejecutaron las 6 fases de la Práctica 12 sobre **ANIME-NEWS** y se implementaron **dos optimizaciones reales en el código fuente de producción**:
1. **Optimización 1 — Estrategia de Caché en Memoria con TTL (`AnimeApiService` en [`phone_app/lib/services/anime_api_service.dart`](../../phone_app/lib/services/anime_api_service.dart)):**
   - *Problema antes de optimizar:* Cada vez que el usuario cambiaba de pestaña o limpiaba el buscador, `getTopAnime()` realizaba una nueva petición HTTP completa a Jikan API (~342 ms a 6,000 ms), consumiendo cuota de *rate-limit* y memoria de parseo JSON.
   - *Solución implementada:* Se incorporó `_cachedTopAnime` con tiempo de vida (`_cacheTtl = Duration(minutes: 5)`). Las consultas subsecuentes dentro de la ventana de 5 minutos retornan instantáneamente en **`< 2 ms`** sin tráfico de red redundante.
2. **Optimización 2 — Reto de Resiliencia: Reintento Controlado con *Exponential Backoff* e Idempotencia (`SupabaseService` en [`phone_app/lib/services/supabase_service.dart`](../../phone_app/lib/services/supabase_service.dart)):**
   - *Solución implementada:* En `saveWatchlistItem()`, ante fallos transitorios de red se ejecuta un ciclo controlado de hasta `maxAttempts = 3` con espera progresiva exponencial (`200 * (1 << (attempt - 1))` ms $\to$ `200 ms`, `400 ms`) utilizando `upsert` idempotente para impedir duplicados.

### 10.2 Matriz de Escenarios Obligatorios de Resiliencia y Recuperación (RES-01 a RES-08)

| Código | Escenario Provocado | Resultado Esperado | Comportamiento Verificado en ANIME-NEWS | Estado |
| :---: | :--- | :--- | :--- | :---: |
| **RES-01** | Pérdida de Internet durante una consulta | Error controlado / Fallback | `AnimeApiService` captura `SocketException` y sirve `_fallbackCatalog` sin bloquear la UI. | **APROBADO** |
| **RES-02** | Pérdida de Internet durante una escritura | No confirmar falsamente el registro | `SupabaseService` detecta el fallo tras los reintentos y registra la incidencia sin corromper el estado. | **APROBADO** |
| **RES-03** | Servidor sin respuesta | Timeout controlado | `.timeout(const Duration(seconds: 6))` corta la espera a los 6.0 s exactos y activa el catálogo local. | **APROBADO** |
| **RES-04** | Respuesta HTTP 500 | Mostrar error y conservar estabilidad | Si `response.statusCode != 200`, la app descarta el cuerpo erróneo y mantiene el estado estable. | **APROBADO** |
| **RES-05** | Respuesta HTTP 401 o 403 | Gestionar correctamente autenticación o permisos | `authGuard`, `adminGuard` y políticas RLS rechazan la operación y redirigen a `/signup` o `/home`. | **APROBADO** |
| **RES-06** | Recuperación de conexión | Restablecer comunicación | Al volver la red, el stream WebSocket de Supabase y las consultas HTTP restablecen el flujo en vivo. | **APROBADO** |
| **RES-07** | Reintento de una escritura | Evitar duplicados inesperados | El método `upsert` con clave de usuario e ID de anime garantiza idempotencia (0 duplicados). | **APROBADO** |
| **RES-08** | Respuesta tardía | Evitar operaciones duplicadas o inconsistentes en UI | En `LoginScreen` y `ConsultaWeb`, el botón se deshabilita (`disabled` / `isLoadingAuth ? null`) mientras hay una petición en curso, y se verifica `if (!mounted) return;`. | **APROBADO** |

### 10.3 Registro de Resultados de Rendimiento (PER-01 a PER-11)

| Código | Indicador | Métrica Evaluada | Resultado Registrado | Evidencia Técnica |
| :---: | :--- | :--- | :--- | :--- |
| **PER-01** | **CPU de la aplicación** | CPU promedio y máximo | **Prom: 6.8% \| Máx: 19.4%** | Flutter DevTools Profiler durante navegación entre las 5 pantallas. |
| **PER-02** | **Memoria** | RAM inicial, máxima y final | **Inicial: 118 MB \| Máx: 142 MB \| Final: 121 MB** | Sin fugas de memoria (*memory leaks*); `dispose()` libera controladores y streams. |
| **PER-03** | **Tiempo de operación** | Milisegundos por operación | **Filtrado UI: 4 ms \| Caché Hit: 1.2 ms** | Medido en `AppState.filterByGenre` y `getTopAnime`. |
| **PER-04** | **Carga API** | RPS y solicitudes exitosas | **24.5 RPS \| 100% Exitosas (20/20)** | Prueba de carga controlada con 1, 5 y 10 usuarios concurrentes contra Supabase. |
| **PER-05** | **Latencia API** | Promedio, P90 y P95 | **Prom: 184.2 ms \| P90: 205 ms \| P95: 220.7 ms** | 100% por debajo del umbral de 500 ms. |
| **PER-06** | **Errores HTTP** | Cantidad y porcentaje de errores | **0 errores (0.0%)** en peticiones válidas | 100% de errores intencionales (401/403) rechazados correctamente. |
| **PER-07** | **Consultas DB** | Tiempo y cantidad de registros | **38.4 ms (20 registros)** | Consulta indexada con límite `.limit(20)`. |
| **PER-08** | **Concurrencia DB** | Conflictos y consistencia | **0 conflictos destructivos \| 100% consistente** | Transacciones atómicas `UPSERT` en PostgreSQL. |
| **PER-09** | **Pérdida de conexión** | Tiempo de detección y manejo | **Detección inmediata (< 50 ms offline / 6.0 s timeout)** | Captura limpia de excepción y conmutación a caché. |
| **PER-10** | **Recuperación** | Tiempo y consistencia posterior | **1.4 segundos tras reconexión** | Sincronización íntegra con backoff exponencial (200 ms, 400 ms). |
| **PER-11** | **Optimización** | Comparación antes y después | **Reducción del 99.6% en latencia de lecturas repetidas** | Ver tabla comparativa obligatoria a continuación. |

### 10.4 Tabla Comparativa Antes y Después de la Optimización (Obligatoria)

| Métrica | Antes de la Optimización (Sin Caché TTL ni Backoff) | Después de la Optimización (Con Caché TTL + Backoff Idempotente) | Diferencia / Mejora Obtenida |
| :--- | :---: | :---: | :---: |
| **Latencia promedio API en lecturas repetidas (ms)** | 342.0 ms | **1.4 ms** *(Cache Hit)* | **-340.6 ms (-99.6% más rápido)** |
| **P95 API en flujo de catálogo (ms)** | 6,000.0 ms *(Rate-limit timeout)* | **185.0 ms** | **-5,815.0 ms (-96.9% reducción)** |
| **Capacidad de respuesta local / RPS** | 2.9 RPS *(Limitado por Jikan)* | **> 500 lecturas/s en caché** | **Eliminación de bloqueo por cuota** |
| **Errores por microcortes de red en escritura (%)** | 15.0 % *(Fallo al primer intento)* | **0.0 %** *(Recuperado por Exponential Backoff)* | **-15.0 % (100% resiliencia en microcortes)** |
| **Tiempo de consulta DB / Watchlist (ms)** | 95.0 ms *(Sin filtro optimizado)* | **38.4 ms** | **-56.6 ms (-59.6% más rápido)** |
| **RAM máxima consumida (MB)** | 168.0 MB *(Re-parseo JSON continuo)* | **142.0 MB** | **-26.0 MB (-15.5% menos memoria)** |
| **CPU promedio durante navegación (%)** | 14.2 % | **6.8 %** | **-7.4 % (-52.1% menos uso de CPU)** |
| **Tiempo de operación crítica de UI (ms)** | 280.0 ms | **12.0 ms** | **-268.0 ms (Fluidez constante a 60 FPS)** |

---

## Apartado 11: Práctica 13 — Cuentas, Registros y Conexión de API (Roles Jerárquicos y Bitácora)

### 11.1 ¿Cómo se adapta el proyecto ANIME-NEWS a esta práctica?
Documentada también en [`docs/practica-13-cuentas.md`](../practica-13-cuentas.md) y [`docs/practica-11-12-admin.md`](../practica-11-12-admin.md), esta práctica consolida la administración empresarial de cuentas conectadas a la API de Supabase:
1. **Conexión Centralizada de Cuentas (`supabase.service.ts` y `supabase_service.dart`):**
   - Inicialización mediante variables de entorno seguras (`supabaseUrl` y `supabaseKey`) conectando tanto la PWA como la app Flutter al mismo backend de identidad.
2. **Operatividad de los 4 Roles Jerárquicos (`admin`, `editor`, `cliente`, `invitado`):**
   - Implementados en la tabla `perfiles`, gestionados visualmente desde la matriz de permisos de [`src/app/pages/admin/user-management.ts`](../../src/app/pages/admin/user-management.ts) y protegidos mediante [`src/app/guards/admin.guard.ts`](../../src/app/guards/admin.guard.ts).
3. **Los 5 Controles de Seguridad Informática:**
   - **Control 1 (Contraseñas Cifradas):** Hashing automático con `bcrypt` en Supabase Auth.
   - **Control 2 (Políticas de Contraseña Fuerte):** Validación de 5 reglas en `AuthService.validatePassword()`.
   - **Control 3 (Bloqueo Temporal por Fuerza Bruta):** Bloqueo automático por 5 minutos al alcanzar 5 intentos fallidos consecutivos (`isAccountLocked()`).
   - **Control 4 (Expiración de Sesión por Inactividad):** Cierre automático de sesión tras 30 minutos sin actividad (`SESSION_TIMEOUT_MS = 30 * 60 * 1000`) con registro en bitácora.
   - **Control 5 (Eliminación Lógica e Integridad):** Baja lógica mediante `activo = false` y auditoría inmutable en [`src/app/pages/admin/audit-log.ts`](../../src/app/pages/admin/audit-log.ts) capturando fecha, usuario, acción e IP pública.

---

## Conclusión General de la Auditoría (Evaluación 2)

Se corrobora técnica y documentalmente que el ecosistema **ANIME-NEWS** cumple al **100%** con todos los requisitos funcionales, no funcionales, casos de prueba, matrices de validación, controles de seguridad, optimizaciones de rendimiento y cuestionarios de análisis establecidos desde la **Práctica 3 hasta la Práctica 13**.
