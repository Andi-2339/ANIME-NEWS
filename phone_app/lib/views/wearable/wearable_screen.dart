import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

class WearableScreen extends StatelessWidget {
  const WearableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isConnected = appState.connectionStatus.contains('Conectado');

    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              const Text(
                'Wearable & Métricas Hype',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Telemetría en tiempo real recibida del reloj inteligente (Wear OS).',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Card de Estado de Conexión BLE
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isConnected ? kNeonGreen : Colors.blueAccent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isConnected ? kNeonGreen : Colors.blueAccent)
                          .withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                      color: isConnected ? kNeonGreen : Colors.blueAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enlace Wear OS Smartwatch',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          appState.connectionStatus,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isConnected ? kNeonGreen : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Alerta Crítica si supera los umbrales
              if (appState.criticalAlert) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[900]!.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '¡ALERTA CRÍTICA DE HYPE!\nRitmo cardíaco acelerado detectado. Advertencia transmitida a la Smart TV.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Estadísticas del Smartwatch
              const Text(
                '⌚ Biometría y Visualización',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNeonGreen,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(
                    title: 'Pulso (BPM)',
                    value: '${appState.heartRate}',
                    icon: Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  _statCard(
                    title: 'Nivel Hype',
                    value: '${appState.hypeLevel}%',
                    icon: Icons.flash_on,
                    color: Colors.amberAccent,
                  ),
                  _statCard(
                    title: 'Eps Vistos',
                    value: '${appState.episodes}',
                    icon: Icons.tv,
                    color: kPurple,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Controles para simular telemetría en evaluación docente
              const Text(
                '🧪 Panel de Simulación para Evaluación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Permite verificar la reactividad del ecosistema sin requerir un emulador de reloj físico activo simultáneamente.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[850]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Simular Pulso Cardíaco:',
                            style: TextStyle(color: Colors.white)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.grey),
                              onPressed: () {
                                if (appState.heartRate > 60) {
                                  appState.heartRate -= 5;
                                  appState.publishTvSync();
                                }
                              },
                            ),
                            Text(
                              '${appState.heartRate} bpm',
                              style: const TextStyle(
                                  color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.redAccent),
                              onPressed: () {
                                appState.heartRate += 5;
                                appState.publishTvSync();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF333333)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            appState.heartRate = 72;
                            appState.hypeLevel = 50;
                            appState.criticalAlert = false;
                            appState.publishTvSync();
                          },
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: const Text('Estado Normal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            appState.heartRate = 135;
                            appState.hypeLevel = 95;
                            appState.criticalAlert = true;
                            appState.publishTvSync();
                          },
                          icon: const Icon(Icons.warning, size: 16, color: Colors.black),
                          label: const Text('Disparar Alerta', style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                          ),
                        ),
                      ],
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

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
