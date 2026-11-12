import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

// Paleta accesible WCAG AA
const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF222222);
const Color kInputBg = Color(0xFF2C2C2C);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    // [Práctica 5 - Validación 2 y 3]: Verificar que los campos superen las validaciones
    // de presencia, sin espacios vacíos y dentro de los límites de longitud antes de autenticar.
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    bool success;

    // [Práctica 5 - Validación 6]: Nunca se imprimen contraseñas ni tokens en Logcat/consola.
    if (_isSignUp) {
      success = await appState.register(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _nameController.text.trim(),
      );
    } else {
      success = await appState.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      // [Práctica 5 - Validación 7]: Mostrar mensaje de acceso cuando los datos sean válidos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Acceso Seguro concedido: Sesión autenticada correctamente.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: kNeonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (appState.authError != null) {
      // [Práctica 5 - Validación 5]: Mostrar mensajes de error genéricos sin revelar detalles técnicos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.authError!,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Ícono accesible
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPurple, kNeonGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kNeonGreen.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_martial_arts,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título principal con alto contraste (WCAG AA)
                  const Text(
                    'ANIME-NEWS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kNeonGreen,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ecosistema Móvil Integral',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD1D5DB),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Mensaje de estado (Login / Registro)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: kPurple.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _isSignUp ? 'Crear Cuenta en Supabase' : 'Iniciar Sesión',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre (Solo en Sign Up)
                  if (_isSignUp) ...[
                    Semantics(
                      label: 'Nombre completo',
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Nombre Completo',
                          icon: Icons.person_outline,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Correo Electrónico / Usuario (Práctica 5 - AccesoSeguro)
                  Semantics(
                    label: 'Correo Electrónico',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                      ),
                      validator: (val) {
                        // [Práctica 5 - Validación 2]: Evitar entradas vacías o con solo espacios
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa tu correo (no se permiten solo espacios)';
                        }
                        // [Práctica 5 - Validación 3]: Rechazar entradas que superen longitud máxima
                        if (val.trim().length > 64) {
                          return 'El correo no debe superar los 64 caracteres';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Ingresa un formato de correo válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contraseña (Práctica 5 - Ocultamiento y longitud mínima de 8 caracteres)
                  Semantics(
                    label: 'Contraseña',
                    child: TextFormField(
                      controller: _passwordController,
                      // [Práctica 5 - Validación 4]: Ocultar los caracteres de la contraseña
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        // [Práctica 5]: Comprobar que la contraseña tenga al menos 8 caracteres
                        if (val.length < 8) {
                          return 'Mínimo 8 caracteres requeridos por seguridad';
                        }
                        // [Práctica 5 - Validación 3]: Rechazar entradas que superen longitud definida
                        if (val.length > 64) {
                          return 'La contraseña no debe superar los 64 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón Principal (>48dp altura mínima WCAG)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: appState.isLoadingAuth ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNeonGreen,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: appState.isLoadingAuth
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'REGISTRARSE' : 'INICIAR SESIÓN',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alternar entre Login y Registro
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? '¿Ya tienes una cuenta? '
                                : '¿No tienes cuenta aún? ',
                          ),
                          TextSpan(
                            text: _isSignUp ? 'Inicia Sesión' : 'Regístrate aquí',
                            style: const TextStyle(
                              color: kNeonGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Separador WCAG
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[800])),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'ACCESO RÁPIDO EVALUACIÓN',
                          style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[800])),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botón de credenciales de prueba pre-cargadas para evaluación
                  OutlinedButton.icon(
                    onPressed: () {
                      _emailController.text = 'demo@animenews.com';
                      _passwordController.text = 'Anime2026!';
                    },
                    icon: const Icon(Icons.flash_on, color: Colors.amberAccent, size: 20),
                    label: const Text(
                      'Llenar credenciales Demo (demo@animenews.com)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
      prefixIcon: Icon(icon, color: kPurple),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: kInputBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNeonGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    );
  }
}
