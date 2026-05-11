import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'aviso_privacidad_page.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? _fotoUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();
    nombreController.text = doc['nombre'] ?? '';
    telefonoController.text = doc['telefono'] ?? '';
    emailController.text = user.email ?? '';
    setState(() {
      loading = false;
      _fotoUrl = doc.data()?['foto_url'] as String?;
    });
  }

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
            if (_fotoUrl != null)
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

  Future<void> _tomarFoto(ImageSource source) async {
    try {
      // 1. GESTIÓN DE PERMISOS
      PermissionStatus status;

      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        // Intentar primero con photos (Android 13+)
        status = await Permission.photos.request();
        // Si se deniega o no es compatible, intentar con storage (Android < 13)
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

      // 2. SELECCIÓN DE LA IMAGEN (Esta línea es vital)
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (imagen == null) return; // El usuario canceló la selección

      // 3. PROCESO DE SUBIDA
      setState(() => _subiendoFoto = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseStorage.instance
          .ref()
          .child('fotos_perfil')
          .child('${user.uid}.jpg');

      // Subir archivo a Storage
      await ref.putFile(File(imagen.path));
      final url = await ref.getDownloadURL();

      // Actualizar URL en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'foto_url': url});

      if (mounted) {
        setState(() {
          _fotoUrl = url;
          _subiendoFoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada')));
      }
    } catch (e) {
      setState(() => _subiendoFoto = false);
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _eliminarFoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _subiendoFoto = true);
    try {
      await FirebaseStorage.instance
          .ref()
          .child('fotos_perfil')
          .child('${user.uid}.jpg')
          .delete();
    } catch (_) {}
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({'foto_url': FieldValue.delete()});
    setState(() {
      _fotoUrl = null;
      _subiendoFoto = false;
    });
  }

  Future<void> actualizarPerfil() async {
    if (telefonoController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('El teléfono debe tener exactamente 10 dígitos')));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .update({
      'nombre': nombreController.text.trim(),
      'telefono': telefonoController.text.trim(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }

  Future<void> eliminarCuenta() async {
    final user = FirebaseAuth.instance.currentUser;
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
      final uid = user!.uid;
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(FirebaseFirestore.instance.collection('usuarios').doc(uid));
      final pedidos = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('uid_usuario', isEqualTo: uid)
          .get();
      for (final doc in pedidos.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      try {
        await FirebaseStorage.instance
            .ref()
            .child('fotos_perfil')
            .child('$uid.jpg')
            .delete();
      } catch (_) {}
      await user.delete();
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No se pudo eliminar. Vuelve a iniciar sesión e intenta de nuevo.')));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Avatar con botón de cámara ────────────────────────────────
            Stack(
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
                          color: Colors.orangeAccent.withOpacity(0.6),
                          width: 3),
                      color: const Color(0xFF1E293B),
                    ),
                    child: _subiendoFoto
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: Colors.orangeAccent, strokeWidth: 3))
                        : ClipOval(
                            child: _fotoUrl != null
                                ? Image.network(_fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.orangeAccent))
                                : const Icon(Icons.person,
                                    size: 60, color: Colors.orangeAccent),
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: _seleccionarFoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF0F172A), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
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
              const Text('v1.0 · khalebreyes06@gmail.com',
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
