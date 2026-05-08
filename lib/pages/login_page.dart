import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_page.dart';
import 'home_page.dart';
import '../widgets/app_background.dart';
import 'admin_page.dart';
import 'aviso_privacidad_page.dart';

const String _kAdminEmail = 'admin@admin.com';
const String _kAdminPassword = '123456';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _verContrasena = false; // Toggle ver/ocultar contraseña
  bool _cargando = false; // Spinner durante login

  // ── Validación de inicio de sesión ────────────────────────────────────────
  // SEGURIDAD: Valida campos localmente antes de enviar petición a Firebase,
  // evitando llamadas innecesarias y dando retroalimentación inmediata.
  String? _validarCampos() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return 'Completa todos los campos para continuar.';
    }

    // Validar formato básico de correo
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null; // Todo válido
  }

  // ── Login principal ───────────────────────────────────────────────────────
  Future<void> loginUser() async {
    // 1. Validación local de campos
    final errorValidacion = _validarCampos();
    if (errorValidacion != null) {
      showError(errorValidacion);
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 2. Verificar si es el administrador
    if (email == _kAdminEmail && password == _kAdminPassword) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      }
      return;
    }

    setState(() => _cargando = true);

    try {
      // 3. Autenticación Firebase — VALIDACIÓN DE INICIO DE SESIÓN
      // Firebase valida credenciales en el servidor de forma segura.
      // La contraseña viaja cifrada sobre HTTPS/TLS.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);
      showError(_mensajeFirebase(e.code));
    } catch (_) {
      setState(() => _cargando = false);
      showError('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  // Traduce códigos de error Firebase a mensajes amigables en español
  String _mensajeFirebase(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo. ¿Quieres crear una?';
      case 'wrong-password':
        return 'Contraseña incorrecta. Verifica e intenta de nuevo.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos. Verifica tus datos.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta al soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera unos minutos e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
      default:
        return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
    }
  }

  void showError(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message ?? 'Credenciales incorrectas.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // ── Logo e identidad ───────────────────────────────────
                  const Icon(
                    Icons.fitness_center,
                    size: 90,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Elite Form',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Entrena. Mejora. Supera.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 40),

                  // ── Formulario ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Correo
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Contraseña con toggle ver/ocultar
                        // SEGURIDAD: El campo tiene obscureText por defecto.
                        // El ícono de ojo permite alternar la visibilidad.
                        TextField(
                          controller: passwordController,
                          obscureText: !_verContrasena,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            // Botón toggle ocultar/mostrar contraseña
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verContrasena
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white38,
                              ),
                              tooltip: _verContrasena
                                  ? 'Ocultar contraseña'
                                  : 'Ver contraseña',
                              onPressed: () => setState(
                                  () => _verContrasena = !_verContrasena),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.black),
                                  )
                                : const Text(
                                    'INICIAR ENTRENAMIENTO',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Link a registro
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          ),
                          child: const Text('Crear cuenta'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Link al aviso de privacidad ────────────────────────
                  // PRIVACIDAD: El aviso debe ser accesible desde el login.
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AvisoPrivacidadPage()),
                    ),
                    icon: const Icon(Icons.privacy_tip_outlined,
                        color: Colors.white24, size: 14),
                    label: const Text(
                      'Aviso de Privacidad',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
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
}
