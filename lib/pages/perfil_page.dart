import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'aviso_privacidad_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_version.dart';

// NOTA: Firebase Storage eliminado. Las fotos se guardan como Base64
// directamente en Firestore en el campo 'foto_base64' del documento
// del usuario. Máximo recomendado: imágenes de 512x512 a calidad 70
// generan ~30-60 KB en Base64, bien dentro del límite de 1 MB de Firestore.

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();

  bool editando = false;
  bool loading = true;
  bool _subiendoFoto = false;

  // Base64 de la foto almacenada en Firestore
  String? _fotoBase64;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      telefonoController.text = data['telefono'] ?? '';
      emailController.text = user.email ?? '';
      setState(() {
        loading = false;
        _fotoBase64 = data['foto_base64'] as String?;
      });
    } else {
      setState(() => loading = false);
    }
  }

  // ── Selector de fuente de foto ────────────────────────────────────────────
  Future<void> _seleccionarFoto() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Foto de perfil',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.camera_alt, color: Colors.orangeAccent),
              ),
              title: const Text('Tomar foto',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Usar la cámara del dispositivo',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child:
                    const Icon(Icons.photo_library, color: Colors.blueAccent),
              ),
              title: const Text('Elegir de la galería',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Seleccionar una foto existente',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.gallery);
              },
            ),
            if (_fotoBase64 != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                title: const Text('Eliminar foto',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarFoto();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Tomar / seleccionar foto y guardar como Base64 en Firestore ───────────
  Future<void> _tomarFoto(ImageSource source) async {
    try {
      // 1. Gestión de permisos
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }

      if (status.isPermanentlyDenied) {
        openAppSettings();
        return;
      }
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Necesitamos permisos para continuar')));
        }
        return;
      }

      // 2. Seleccionar imagen — tamaño reducido para Firestore
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70, // calidad 70 → ~30-60 KB → Base64 ~40-80 KB
      );
      if (imagen == null) return;

      setState(() => _subiendoFoto = true);

      // 3. Leer bytes y convertir a Base64
      final Uint8List bytes = await imagen.readAsBytes();
      if (bytes.isEmpty) {
        setState(() => _subiendoFoto = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo leer la imagen')));
        }
        return;
      }
      final String base64Str = base64Encode(bytes);

      // 4. Guardar Base64 en Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'foto_base64': base64Str});

      if (mounted) {
        setState(() {
          _fotoBase64 = base64Str;
          _subiendoFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Colors.greenAccent));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _subiendoFoto = false);
        debugPrint('Error guardando foto: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // ── Eliminar foto ─────────────────────────────────────────────────────────
  Future<void> _eliminarFoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _subiendoFoto = true);
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({'foto_base64': FieldValue.delete()});
    setState(() {
      _fotoBase64 = null;
      _subiendoFoto = false;
    });
  }

  // ── Widget de avatar ──────────────────────────────────────────────────────
  Widget _buildAvatar() {
    Widget fotoWidget;
    if (_subiendoFoto) {
      fotoWidget = const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
            color: Colors.orangeAccent, strokeWidth: 3),
      );
    } else if (_fotoBase64 != null) {
      try {
        final bytes = base64Decode(_fotoBase64!);
        fotoWidget = ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 110,
            height: 110,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.person, size: 60, color: Colors.orangeAccent),
          ),
        );
      } catch (_) {
        fotoWidget =
            const Icon(Icons.person, size: 60, color: Colors.orangeAccent);
      }
    } else {
      fotoWidget =
          const Icon(Icons.person, size: 60, color: Colors.orangeAccent);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _seleccionarFoto,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.orangeAccent.withOpacity(0.6), width: 3),
              color: const Color(0xFF1E293B),
            ),
            child: ClipOval(child: Center(child: fotoWidget)),
          ),
        ),
        GestureDetector(
          onTap: _seleccionarFoto,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0F172A), width: 2),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
          ),
        ),
      ],
    );
  }

  // ── Actualizar perfil ─────────────────────────────────────────────────────
  Future<void> actualizarPerfil() async {
    if (telefonoController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('El teléfono debe tener exactamente 10 dígitos')));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({
      'nombre': nombreController.text.trim(),
      'telefono': telefonoController.text.trim(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    }
  }

  // ── Eliminar cuenta ───────────────────────────────────────────────────────
  Future<void> eliminarCuenta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final confirmar = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar cuenta',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                'Esta acción eliminará tu cuenta permanentemente incluyendo '
                'tu foto de perfil, datos, pedidos e historial. ¿Continuar?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
    if (!confirmar) return;
    try {
      final uid = user.uid;
      final batch = FirebaseFirestore.instance.batch();
      // Borrar documento del usuario (foto_base64 se elimina con él)
      batch.delete(FirebaseFirestore.instance.collection('usuarios').doc(uid));
      final pedidos = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('uid_usuario', isEqualTo: uid)
          .get();
      for (final doc in pedidos.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await user.delete();
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No se pudo eliminar. Vuelve a iniciar sesión e intenta de nuevo.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            _buildAvatar(),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _seleccionarFoto,
              child: const Text('Cambiar foto de perfil',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 13)),
            ),
            const SizedBox(height: 10),

            if (!editando) ...[
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Nombre'),
                subtitle: Text(nombreController.text),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Teléfono'),
                subtitle: Text(telefonoController.text),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Correo'),
                subtitle: Text(user?.email ?? ''),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => editando = true),
                  child: const Text('Editar perfil'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: eliminarCuenta,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text('Eliminar cuenta'),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),
              Row(children: const [
                Icon(Icons.privacy_tip_outlined,
                    color: Colors.white38, size: 15),
                SizedBox(width: 8),
                Text('Privacidad y datos',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.privacy_tip,
                      color: Colors.orangeAccent, size: 18),
                ),
                title: const Text('Aviso de Privacidad',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                    'Consulta cómo usamos y protegemos tus datos',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AvisoPrivacidadPage())),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.gavel,
                      color: Colors.blueAccent, size: 18),
                ),
                title: const Text('Ejercer derechos ARCO',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                    'Acceso, rectificación, cancelación u oposición',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E293B),
                    title: const Row(children: [
                      Icon(Icons.gavel, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Derechos ARCO',
                          style: TextStyle(color: Colors.white)),
                    ]),
                    content: const Text(
                      'Para ejercer tus derechos envía un correo a:\n\n'
                      'khalebreyes06@gmail.com\n\n'
                      'Asunto: "Ejercicio de Derechos ARCO"\n\n'
                      'Responderemos en máximo 15 días hábiles.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('$kVersionActual · khalebreyes06@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 20),
            ],

            if (editando) ...[
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                    labelText: 'Nombre', prefixIcon: Icon(Icons.badge)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    counterText: ''),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await actualizarPerfil();
                    setState(() => editando = false);
                  },
                  child: const Text('Guardar cambios'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => editando = false),
                child: const Text('Cancelar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
