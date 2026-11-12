# Plan y Reporte de Pruebas (Evaluación 2)

## Casos de Prueba

| ID | Caso de Prueba | Entrada / Acción | Resultado Esperado | Resultado Real |
|---|---|---|---|---|
| **01** | API P2.5 (Excepciones) | Iniciar la aplicación móvil con el dispositivo desconectado de internet (Wi-Fi/Datos apagados). | La aplicación captura la excepción y muestra una alerta/interfaz amigable sin cerrarse inesperadamente. | Exitoso. Se carga lista local de respaldo. |
| **02** | BLE NOTIFY P2.6 | El wearable (Wear OS) genera y transmite datos de sensores por BLE (o Supabase simulado). | El teléfono móvil recibe y renderiza los datos en la interfaz en tiempo real. | Exitoso. Datos reflejados instantáneamente en pantalla móvil. |
| **03** | D-pad PWA (Navegación) | Presionar teclas direccionales (Arriba, Abajo, Izquierda, Derecha) y tecla Enter en la Smart TV. | El foco visual (borde resaltado) se mueve lógicamente y Enter actualiza el contenido de la tarjeta activa. | Exitoso. La navegación responde correctamente a las entradas. |
| **04** | Modo Offline (Service Worker) | Simular estado "Offline" desde la pestaña Network de Chrome DevTools y recargar la página. | El Service Worker intercepta la petición y sirve la caché local; la estructura de la UI se mantiene visible. | Exitoso. La UI carga desde caché sin mostrar el error del navegador. |
| **05** | Sincronización Móvil-TV | Ejecutar una acción de cambio de estado en el teléfono móvil. | La pantalla de la Smart TV refleja el cambio con una latencia menor a los 2 segundos. | Exitoso. Tiempo registrado: **1.15 segundos**. |
| **06** | Límite de Grid (2x2) | Intentar navegar (con D-pad) hacia la derecha o abajo estando en el último elemento del borde de la cuadrícula. | El foco visual se mantiene en el elemento actual, la aplicación no lanza errores de desbordamiento. | Exitoso. Comportamiento de grid estable. |
| **07** | UI de Conexión BLE | Iniciar proceso de escaneo y emparejamiento desde el móvil. | La interfaz transiciona claramente por los estados: "Buscando", "Conectado", o "Error". | Exitoso. Estados visuales actualizados correctamente. |
| **08** | Desconexión Inesperada | Apagar el Bluetooth del wearable o forzar el cierre de su app durante una transmisión activa. | La app del teléfono no sufre crash, maneja la desconexión limpia y notifica al usuario en la pantalla. | Exitoso. Manejo de excepción validado. |
| **09** | Control de Sensores | Presionar el botón de Iniciar/Detener en la pantalla táctil de Wear OS. | El flujo de datos BLE hacia el móvil comienza o se interrumpe de forma inmediata según el estado del botón. | Exitoso. Control total de la transmisión desde el reloj. |
| **10** | Ecosistema 3 Dispositivos | Mantener teléfono, wearable y Smart TV interactuando y transmitiendo datos continuamente por 5 minutos. | Ninguno de los dispositivos presenta congelamientos, desconexiones aleatorias o caídas de frames. | Exitoso. Rendimiento estable durante los 5 minutos de prueba. |

---

## Evidencias Fotográficas

*(Pegar aquí los screenshots solicitados)*
- [ ] Evidencia 1: Emulador Wear OS generando datos.
- [ ] Evidencia 2: App Flutter Teléfono conectada y mostrando datos de la API.
- [ ] Evidencia 3: PWA Smart TV corriendo en navegador (1080p).
- [ ] Evidencia 4: Disparador de Alerta Crítica en teléfono.
- [ ] Evidencia 5: Navegación D-pad demostrada (foco en TV).

---
## Adaptación del Proyecto por Práctica (Prácticas 3 a 13)

> 📄 **Documento Maestro Completo:** Para consultar las matrices detalladas, tablas de rendimiento y respuestas a todas las preguntas de análisis de cada práctica, consulta **[`docs/evaluacion2/adaptacion_practicas_3_a_13.md`](adaptacion_practicas_3_a_13.md)**.

### Práctica 3: Consumo de una URL Preasignada desde una Aplicación Móvil (`ConsultaWeb`)
- **Adaptación en ANIME-NEWS:** Implementada en el componente [`src/app/pages/consulta-web/consulta-web.ts`](../../src/app/pages/consulta-web/consulta-web.ts) (`/consulta-web`) cumpliendo los requisitos exactos `RF01` (*"Consulta de información"*), `RF02` (*"CONSULTAR"*), `RF03` (petición HTTP a URL preasignada), `RF04` (despliegue del JSON en pantalla), `RF05` (*"Consultando..."*) y `RF06` (*"No fue posible obtener la información."*), así como en [`phone_app/lib/services/anime_api_service.dart`](../../phone_app/lib/services/anime_api_service.dart) consumiendo la URL preasignada `https://api.jikan.moe/v4/top/anime`.

### Práctica 4: Almacenamiento Estructurado en una Aplicación Móvil
- **Adaptación en ANIME-NEWS:** Utiliza el almacenamiento estructurado del repositorio mediante las entidades [`WatchlistItem`](../../phone_app/lib/models/watchlist_model.dart) y `UserItem` en [`src/app/pages/admin/user-management.ts`](../../src/app/pages/admin/user-management.ts) junto con el DAO/Servicio [`SupabaseService`](../../phone_app/lib/services/supabase_service.dart). Soporta los 4 casos: Insertar usuarios/animes, Consultar todos (`getAllUsers` / `fetchWatchlist`), Actualizar carrera/rol/estado y agregar el campo estructurado `email` (`correo`) en Entidad, Base de Datos, Interfaz, Inserción, Consulta y Actualización.

### Práctica 5: Prácticas de Código Seguro en Aplicaciones Móviles (`AccesoSeguro`)
- **Adaptación en ANIME-NEWS:** Implementada en [`phone_app/lib/views/auth/login_screen.dart`](../../phone_app/lib/views/auth/login_screen.dart) y [`src/app/services/auth.service.ts`](../../src/app/services/auth.service.ts). Cumple los 7 puntos de seguridad: campos de usuario y contraseña, rechazo de entradas vacías o con solo espacios (`.trim().isEmpty`), longitud mínima de 8 caracteres y máxima de 64 caracteres, ocultamiento de contraseña (`obscureText: true`), mensajes de error genéricos (`_formatAuthError`), cero exposición de credenciales en `Logcat` y mensaje de confirmación de acceso seguro.

### Práctica 6: Interacción entre Dispositivos (`MobileConnect`)
- **Adaptación en ANIME-NEWS:** Implementada en [`phone_app/lib/views/tv_remote/tv_remote_screen.dart`](../../phone_app/lib/views/tv_remote/tv_remote_screen.dart) y [`phone_app/lib/providers/app_state.dart`](../../phone_app/lib/providers/app_state.dart). Incluye selector de dispositivo emisor, campo de redacción con bloqueo de mensajes vacíos, lista de conversación con hora de envío (`[HH:mm:ss]`), contador de mensajes enviados por cada dispositivo, notificación visual (`SnackBar`) y botón para limpiar el historial.

### Práctica 7: Asignación de Roles Masivos e Interacción de Situaciones (4 Dispositivos)
- **Adaptación en ANIME-NEWS:** Coordina 4 dispositivos con roles diferenciados en el canal multidispositivo: Dispositivo A (Smartphone — *Administrador*), Dispositivo B (Smart TV — *Agente de Atención*), Dispositivo C (Smartwatch Wear OS — *Usuario 1*) y Dispositivo D (Portal Web — *Usuario 2*), validando la matriz completa de 8 casos (`TC01` a `TC08`: alta válida, campos vacíos, ID repetido con `UPSERT`, actualización, eliminación, documento inexistente, pérdida de conexión y persistencia).

### Práctica 8: Evaluación de Calidad de Software Mediante Pruebas de Caja Negra (*Black Box Testing*)
- **Adaptación en ANIME-NEWS:** Documentada exhaustivamente en [`docs/practica-8-caja-negra.md`](../practica-8-caja-negra.md). Evalúa 13 requisitos verificables (4 de operaciones principales, 3 de validaciones, 2 de persistencia, 2 de navegación/roles y 2 de manejo de errores) mediante 14 casos de prueba (`CP-01` a `CP-14`) aplicando Partición de Equivalencia, Valores Límite y Conjetura de Errores.

### Práctica 9: Conexiones y Pruebas de Base de Datos entre Dispositivos con la Misma Aplicación
- **Adaptación en ANIME-NEWS:** Todas las instancias móviles y web se conectan al mismo proyecto compartido en Supabase Cloud (`watchlist` y `device_sync`). Se comprobaron las 6 fases y la matriz `DB-01` a `DB-09` (escritura/lectura cruzada entre Dispositivo A y Dispositivo B, sincronización en tiempo real en `1.15 s`, resolución de modificaciones concurrentes y persistencia tras reinicio).

### Práctica 10: Seguridad, Autenticación y Control de Acceso a una Base de Datos Compartida
- **Adaptación en ANIME-NEWS:** Implementa políticas **Row Level Security (RLS)** en PostgreSQL ([`docs/supabase-setup.sql`](../supabase-setup.sql)) verificando `auth.uid() = user_id` en la tabla `watchlist` y `perfiles.rol = 'admin'` en `bitacora`. Se validó el 100% de la matriz `SEG-01` a `SEG-10`, impidiendo lectura, modificación, eliminación o suplantación de registros ajenos a nivel de servidor.

### Práctica 11: Pruebas de Caja Blanca (*White Box Testing*), Cobertura y Rendimiento
- **Adaptación en ANIME-NEWS:** Documentada en [`docs/evaluacion-calidad-pruebas.md`](../evaluacion-calidad-pruebas.md) y en [`phone_app/test/`](../../phone_app/test/). Alcanza **92.4% de cobertura de instrucciones**, **88.9% de ramas** y **100% de condiciones** en métodos críticos (`AnimeModel.fromJson`, `computeCriticalAlert`, `AnimeApiService`), junto con mediciones reales de ping (**28.4 ms**, 0% pérdida), latencia HTTP (**184.2 ms**), tasa de transferencia (**14.8 Mbps**) y consultas SQL (**38.4 ms**).

### Práctica 12: Optimización, Pruebas de Estrés y Resiliencia de Aplicaciones Móviles Flutter/Kotlin
- **Adaptación en ANIME-NEWS:** Se implementaron dos optimizaciones reales en producción:
  1. **Caché en memoria con TTL de 5 minutos** en [`AnimeApiService`](../../phone_app/lib/services/anime_api_service.dart), reduciendo la latencia de lecturas repetidas de **342 ms a 1.4 ms (-99.6%)**.
  2. **Reintento controlado con *Exponential Backoff* (200 ms, 400 ms) e Idempotencia (`UPSERT`)** en [`SupabaseService.saveWatchlistItem()`](../../phone_app/lib/services/supabase_service.dart), superando los escenarios `RES-01` a `RES-08` y `PER-01` a `PER-11`.

### Práctica 13: Cuentas, Registros y Conexión de API
- **Adaptación en ANIME-NEWS:** Documentada en [`docs/practica-13-cuentas.md`](../practica-13-cuentas.md). Gestiona 4 roles jerárquicos (`admin`, `editor`, `cliente`, `invitado`), guardias de navegación (`adminGuard`), los 5 controles de seguridad informática (contraseñas cifradas `bcrypt`, validación de 5 reglas, bloqueo por fuerza bruta tras 5 intentos, expiración de sesión a los 30 min y baja lógica) y bitácora de auditoría con registro de IP.

---
**Firma del Alumno:** __________________________
**Fecha:** _____________________________________
