import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

class TvRemoteScreen extends StatefulWidget {
  const TvRemoteScreen({super.key});

  @override
  State<TvRemoteScreen> createState() => _TvRemoteScreenState();
}

class _TvRemoteScreenState extends State<TvRemoteScreen> {
  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, String>> _tvCards = const [
    {'title': 'Demon Slayer', 'sub': 'Estreno película', 'code': '0'},
    {'title': 'Jujutsu Kaisen', 'sub': 'Temporada 3 Confirmada', 'code': '1'},
    {'title': 'Naruto', 'sub': 'Especial Aniversario', 'code': '2'},
    {'title': 'One Piece', 'sub': 'Arco Egghead Clímax', 'code': '3'},
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título y estado de sincronización
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Control Smart TV',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kNeonGreen, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi, size: 14, color: kNeonGreen),
                        SizedBox(width: 6),
                        Text(
                          'WebSockets Activo',
                          style: TextStyle(color: kNeonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Envía comandos en tiempo real a la interfaz 10-foot de la TV vía Supabase Realtime.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Sección: Seleccionar Contenido en TV
              const Text(
                '📺 Contenido Activo en TV (Fondo & D-Pad)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kNeonGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _tvCards.length,
                itemBuilder: (context, index) {
                  final card = _tvCards[index];
                  final isSelected = appState.tvSelectedCardIndex == index;

                  return InkWell(
                    onTap: () => appState.selectTvCard(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPurple.withValues(alpha: 0.3) : kCardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? kNeonGreen : Colors.grey[800]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kNeonGreen.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CANAL ${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? kNeonGreen : Colors.grey,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.tv, color: kNeonGreen, size: 18),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                card['sub']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Controles de Reproducción Multimedia
              const Text(
                '🎮 Controles Multimedia Remotos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kNeonGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[850]!),
                ),
                child: Column(
                  children: [
                    // Botón Play/Pause grande (>48dp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.skip_previous, color: Colors.white),
                          tooltip: 'Canal anterior',
                          onPressed: () {
                            int prev = (appState.tvSelectedCardIndex - 1 + 4) % 4;
                            appState.selectTvCard(prev);
                          },
                        ),
                        InkWell(
                          onTap: () => appState.toggleTvPlayback(),
                          borderRadius: BorderRadius.circular(36),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [kPurple, kNeonGreen],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kNeonGreen.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ],
                            ),
                            child: Icon(
                              appState.tvIsPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          tooltip: 'Siguiente canal',
                          onPressed: () {
                            int next = (appState.tvSelectedCardIndex + 1) % 4;
                            appState.selectTvCard(next);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF333333)),
                    const SizedBox(height: 12),

                    // Contador de Episodios con botones accesibles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episodio Transmitido',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sincroniza con el badge de la TV',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () => appState.decrementEpisode(),
                            ),
                            Text(
                              '${appState.episodes}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kNeonGreen,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: kNeonGreen),
                              onPressed: () => appState.incrementEpisode(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nivel de Hype con control rápido
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ajustar Nivel Hype:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => appState.adjustHype(-10),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333),
                                minimumSize: const Size(40, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: const Text('-10%', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${appState.hypeLevel}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => appState.adjustHype(10),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333),
                                minimumSize: const Size(40, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: const Text('+10%', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Botón de prueba de Alerta Crítica para demostración
              OutlinedButton.icon(
                onPressed: () {
                  appState.adjustHype(40); // Forzar nivel superior al 90% para activar alerta en TV
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                label: const Text(
                  'Probar Alerta Crítica en Smart TV (>90% Hype)',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.amber),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),

              // ─── Prácticas 6 y 7: Interacción entre Dispositivos y Roles (MobileConnect) ───
              const Text(
                '📡 Canal Multidispositivo & Roles (MobileConnect)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kNeonGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[850]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Selector de Dispositivo Emisor y Rol (4 dispositivos)
                    const Text(
                      'Dispositivo Emisor Activo:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: appState.selectedSenderDevice,
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: appState.connectedDevices
                          .map((dev) => DropdownMenuItem(value: dev, child: Text(dev)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) appState.selectSenderDevice(val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // 2. Contadores de mensajes enviados por cada dispositivo
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: appState.messageCountsByDevice.entries.map((entry) {
                        final shortName = entry.key.split(':').first;
                        return Chip(
                          backgroundColor: const Color(0xFF1A1A1A),
                          side: BorderSide(color: kPurple.withValues(alpha: 0.5)),
                          label: Text(
                            '$shortName: ${entry.value} msj',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // 3. Campo de texto para redactar mensajes y botón de envío
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Redactar mensaje o reporte de incidencia...',
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final sent = appState.sendDeviceMessage(_msgController.text);
                            if (sent) {
                              _msgController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mensaje transmitido al canal multidispositivo.',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: kNeonGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'No se permiten mensajes vacíos.',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red[800],
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonGreen,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(48, 44),
                          ),
                          child: const Icon(Icons.send, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. Lista de conversación con emisor y hora de envío
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: appState.deviceMessages.isEmpty
                          ? const Center(
                              child: Text(
                                'Historial de conversación vacío.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: appState.deviceMessages.length,
                              itemBuilder: (context, idx) {
                                final msg = appState.deviceMessages[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '[${msg['timestamp']}] ',
                                          style: const TextStyle(color: kNeonGreen, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: '${msg['sender']}: ',
                                          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: msg['text']),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),

                    // 5. Botón para limpiar el historial
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => appState.clearDeviceMessages(),
                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 18),
                        label: const Text(
                          'Limpiar historial',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
