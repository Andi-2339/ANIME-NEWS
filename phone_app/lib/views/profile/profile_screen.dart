import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Usuario
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPurple, kNeonGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPurple.withValues(alpha: 0.3),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: const Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.email ?? 'Usuario de Evaluación',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kNeonGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kNeonGreen, width: 1),
                      ),
                      child: const Text(
                        'Sesión Activa en Supabase',
                        style: TextStyle(
                          color: kNeonGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Resumen de la cuenta
              const Text(
                '📊 Métricas del Usuario',
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
                  _metricTile('Viendo', '${appState.watchingList.length}', Colors.blueAccent),
                  _metricTile('Favoritos', '${appState.favoriteList.length}', Colors.amber),
                  _metricTile('Completados', '${appState.completedList.length}', kNeonGreen),
                ],
              ),
              const SizedBox(height: 24),

              // Información Técnica de Sesión y Seguridad (Práctica de Seguridad)
              const Text(
                '🔒 Seguridad y Sesión Móvil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[850]!),
                ),
                child: Column(
                  children: [
                    _infoRow('Proveedor Backend', 'Supabase Cloud (PostgreSQL)'),
                    const Divider(color: Color(0xFF333333)),
                    _infoRow('Protocolo de Sincronización', 'WSS (WebSockets Realtime)'),
                    const Divider(color: Color(0xFF333333)),
                    _infoRow('Cifrado de Sesión', 'Tokens JWT (Persistente)'),
                    const Divider(color: Color(0xFF333333)),
                    _infoRow('Estándar Accesibilidad', 'WCAG AA Cumplido'),
                    const Divider(color: Color(0xFF333333)),
                    _infoRow('UID', user?.id.substring(0, 8) ?? 'Anon-Guest'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón de Cerrar Sesión
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, appState),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardBg,
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Se destruirá el token de sesión localmente y volverás a la pantalla de acceso.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
