import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/app_state.dart';
import 'views/auth/login_screen.dart';
import 'views/main_navigation.dart';

// Paleta central del sistema ANIME-NEWS
const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase con tolerancia a fallos offline
  try {
    await Supabase.initialize(
      url: 'https://mtwhobrdwjlffflxnrud.supabase.co',
      // ignore: deprecated_member_use
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10d2hvYnJkd2psZmZmbHhucnVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NjYzMzIsImV4cCI6MjA5MTI0MjMzMn0.IZy-nH12l9pbiDcu94jdPhwhTNks8-9ts01wd2-A5g4',
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('[Supabase Init] Modo offline/fallback activado: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const AnimeNewsPhoneApp(),
    ),
  );
}

class AnimeNewsPhoneApp extends StatelessWidget {
  const AnimeNewsPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANIME-NEWS Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: kPurple,
        scaffoldBackgroundColor: kDarkBg,
        colorScheme: const ColorScheme.dark(
          primary: kPurple,
          secondary: kNeonGreen,
          surface: kCardBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkBg,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Si el usuario ya está autenticado en Supabase, entra al ecosistema
    if (appState.isAuthenticated) {
      return const MainNavigationScreen();
    }

    // De lo contrario, muestra la pantalla accesible de Login / Registro
    return const LoginScreen();
  }
}
