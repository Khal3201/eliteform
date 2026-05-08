import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'aviso_privacidad_page.dart';
import '../widgets/consentimiento_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();

  // ── Estado de seguridad ───────────────────────────────────────────────────
  bool _verContrasena = false; // Toggle ver/ocultar contraseña
  bool _consentimientoValido = false; // Casillas obligatorias marcadas
  bool _cargando = false; // Spinner durante registro

  // ── Validación de contraseña segura ──────────────────────────────────────
  // SEGURIDAD: Exige mínimo 8 caracteres, una mayúscula y un número.
  // Devuelve null si es válida, o un mensaje de error si no cumple requisitos.
  String? _validarContrasena(String contrasena) {
    if (contrasena.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!contrasena.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!contrasena.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    return null; // Contraseña válida
  }

  // ── Indicador visual de fortaleza ─────────────────────────────────────────
  _FortalezaContrasena _evalFortaleza(String pass) {
    if (pass.isEmpty) return _FortalezaContrasena.vacia;
    int score = 0;
    if (pass.length >= 8) score++;
    if (pass.contains(RegExp(r'[A-Z]'))) score++;
    if (pass.contains(RegExp(r'[0-9]'))) score++;
    if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    if (score <= 1) return _FortalezaContrasena.debil;
    if (score == 2) return _FortalezaContrasena.media;
    if (score == 3) return _FortalezaContrasena.buena;
    return _FortalezaContrasena.fuerte;
  }

  // ── Registro principal ────────────────────────────────────────────────────
  Future<void> registerUser() async {
    // 1. Validar que el consentimiento esté dado
    if (!_consentimientoValido) {
      _mostrarError(
          'Debes aceptar el Aviso de Privacidad y el tratamiento de datos para continuar.');
      return;
    }

    // 2. Validar teléfono
    if (telefonoController.text.length != 10) {
      _mostrarError('El teléfono debe tener exactamente 10 dígitos.');
      return;
    }

    // 3. Validar contraseña segura
    final errorContrasena = _validarContrasena(passwordController.text.trim());
    if (errorContrasena != null) {
      _mostrarError(errorContrasena);
      return;
    }

    // 4. Validar que el nombre no esté vacío
    if (nombreController.text.trim().isEmpty) {
      _mostrarError('El nombre es obligatorio.');
      return;
    }

    setState(() => _cargando = true);

    try {
      // 5. Crear usuario en Firebase Authentication
      // CIFRADO: Firebase almacena la contraseña como hash bcrypt + salt.
      // EliteForm nunca accede a la contraseña en texto plano.
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 6. Guardar datos del perfil en Firestore (sin la contraseña)
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'id_usuario': userCredential.user!.uid,
        'nombre': nombreController.text.trim(),
        'correo': emailController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'fecha_registro': FieldValue.serverTimestamp(),
        // No se guarda la contraseña — Firebase Auth la gestiona cifrada
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);
      _mostrarError(_mensajeFirebase(e.code));
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  // Traduce códigos de error de Firebase a mensajes amigables
  String _mensajeFirebase(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Intenta iniciar sesión.';
      case 'invalid-email':
        return 'El correo electrónico no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Elige una más segura.';
      default:
        return 'Error al crear la cuenta. Verifica tus datos e intenta de nuevo.';
    }
  }

  void _mostrarError(String mensaje) {
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
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
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
    nombreController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fortaleza = _evalFortaleza(passwordController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            const Center(
              child:
                  Icon(Icons.person_add, size: 64, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Únete a EliteForm',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Crea tu cuenta para comenzar',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(height: 28),

            // ── Nombre ────────────────────────────────────────────────────
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 14),

            // ── Teléfono ─────────────────────────────────────────────────
            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Teléfono (10 dígitos)',
                prefixIcon: Icon(Icons.phone),
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),

            // ── Correo ───────────────────────────────────────────────────
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 14),

            // ── Contraseña con toggle ver/ocultar ────────────────────────
            // SEGURIDAD: obscureText con botón de ojo para alternar visibilidad.
            StatefulBuilder(
              builder: (context, setLocal) {
                return TextField(
                  controller: passwordController,
                  obscureText: !_verContrasena,
                  onChanged: (_) => setState(() {}), // actualiza indicador
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    // Ícono de ojo: permite ver/ocultar la contraseña
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
                      onPressed: () =>
                          setState(() => _verContrasena = !_verContrasena),
                    ),
                  ),
                );
              },
            ),

            // ── Indicador de fortaleza de contraseña ─────────────────────
            if (passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _IndicadorFortaleza(fortaleza: fortaleza),
            ],

            // ── Requisitos de contraseña ──────────────────────────────────
            const SizedBox(height: 8),
            _RequisitoContrasena(
              texto: 'Mínimo 8 caracteres',
              cumple: passwordController.text.length >= 8,
            ),
            _RequisitoContrasena(
              texto: 'Al menos una letra mayúscula',
              cumple: passwordController.text.contains(RegExp(r'[A-Z]')),
            ),
            _RequisitoContrasena(
              texto: 'Al menos un número',
              cumple: passwordController.text.contains(RegExp(r'[0-9]')),
            ),

            const SizedBox(height: 24),

            // ── Bloque de consentimiento ──────────────────────────────────
            // PRIVACIDAD: casillas obligatorias antes de crear la cuenta.
            ConsentimientoWidget(
              onChanged: (valido) =>
                  setState(() => _consentimientoValido = valido),
            ),

            const SizedBox(height: 24),

            // ── Botón de registro ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_cargando || !_consentimientoValido) ? null : registerUser,
                icon: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_cargando ? 'Creando cuenta...' : 'Crear cuenta'),
              ),
            ),

            const SizedBox(height: 16),

            // ── Link al aviso de privacidad completo ──────────────────────
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AvisoPrivacidadPage()),
                ),
                icon: const Icon(Icons.privacy_tip_outlined,
                    color: Colors.white38, size: 14),
                label: const Text(
                  'Leer Aviso de Privacidad completo',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

enum _FortalezaContrasena { vacia, debil, media, buena, fuerte }

class _IndicadorFortaleza extends StatelessWidget {
  final _FortalezaContrasena fortaleza;

  const _IndicadorFortaleza({required this.fortaleza});

  @override
  Widget build(BuildContext context) {
    final (color, label, valor) = switch (fortaleza) {
      _FortalezaContrasena.debil => (Colors.redAccent, 'Débil', 0.25),
      _FortalezaContrasena.media => (Colors.amberAccent, 'Regular', 0.50),
      _FortalezaContrasena.buena => (Colors.lightGreen, 'Buena', 0.75),
      _FortalezaContrasena.fuerte => (Colors.greenAccent, 'Fuerte', 1.0),
      _ => (Colors.transparent, '', 0.0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: valor,
            backgroundColor: Colors.white12,
            color: color,
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fortaleza: $label',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _RequisitoContrasena extends StatelessWidget {
  final String texto;
  final bool cumple;

  const _RequisitoContrasena({required this.texto, required this.cumple});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: cumple ? Colors.greenAccent : Colors.white24,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: cumple ? Colors.greenAccent : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
