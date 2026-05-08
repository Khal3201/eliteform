import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'aviso_privacidad_page.dart';

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

  Future cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();

    nombreController.text = doc['nombre'];
    telefonoController.text = doc['telefono'];
    emailController.text = user.email ?? '';
    setState(() {
      loading = false;
    });
  }

  Future actualizarPerfil() async {
    if (telefonoController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El teléfono debe tener exactamente 10 dígitos')),
      );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  Future eliminarCuenta() async {
    final user = FirebaseAuth.instance.currentUser;

    bool confirmar = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar cuenta',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                'Esta acción eliminará tu cuenta permanentemente. '
                'Todos tus datos, pedidos e historial de asistencia '
                'serán eliminados. ¿Continuar?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    try {
      // Eliminar datos de Firestore (pedidos + perfil)
      final uid = user!.uid;
      final batch = FirebaseFirestore.instance.batch();

      // Eliminar documento de usuario
      batch.delete(FirebaseFirestore.instance.collection('usuarios').doc(uid));

      // Eliminar pedidos asociados
      final pedidos = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('uid_usuario', isEqualTo: uid)
          .get();
      for (final doc in pedidos.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Eliminar cuenta de Firebase Authentication
      await user.delete();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No se pudo eliminar la cuenta. Es posible que necesites '
                    'volver a iniciar sesión antes de eliminarla.')),
      );
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),

            // ── Vista de datos (modo lectura) ─────────────────────────────
            if (!editando) ...[
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Nombre'),
                subtitle: Text(nombreController.text),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Teléfono'),
                subtitle: Text(telefonoController.text),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Correo'),
                subtitle: Text(user!.email ?? ''),
              ),
              const SizedBox(height: 30),

              // Botón editar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => editando = true),
                  child: const Text('Editar perfil'),
                ),
              ),
              const SizedBox(height: 15),

              // Botón eliminar cuenta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: eliminarCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Eliminar cuenta'),
                ),
              ),

              const SizedBox(height: 30),

              // ── Sección de Privacidad ────────────────────────────────────
              // PRIVACIDAD: El aviso debe estar siempre accesible desde Perfil.
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),

              // Encabezado de privacidad
              Row(
                children: const [
                  Icon(Icons.privacy_tip_outlined,
                      color: Colors.white38, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Privacidad y datos',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Botón Aviso de Privacidad
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.privacy_tip,
                      color: Colors.orangeAccent, size: 18),
                ),
                title: const Text(
                  'Aviso de Privacidad',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Consulta cómo usamos y protegemos tus datos',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AvisoPrivacidadPage()),
                ),
              ),

              // Botón derechos ARCO
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gavel,
                      color: Colors.blueAccent, size: 18),
                ),
                title: const Text(
                  'Ejercer derechos ARCO',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Acceso, rectificación, cancelación u oposición de datos',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1E293B),
                      title: const Row(
                        children: [
                          Icon(Icons.gavel,
                              color: Colors.orangeAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Derechos ARCO',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      content: const Text(
                        'Para ejercer tus derechos de Acceso, Rectificación, '
                        'Cancelación u Oposición de datos personales, envía un '
                        'correo a:\n\nkhalebreyes06@gmail.com\n\ncon el asunto '
                        '"Ejercicio de Derechos ARCO".\n\nResponderemos en un '
                        'máximo de 15 días hábiles.',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              const Text(
                'v1.0 · khalebreyes06@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 20),
            ],

            // ── Vista de edición ──────────────────────────────────────────
            if (editando) ...[
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 30),
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
