import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN: CHATBOT — Gestión de respuestas predeterminadas
// ═══════════════════════════════════════════════════════════════════════════════

class AdminChatbotPage extends StatelessWidget {
  const AdminChatbotPage({super.key});

  Future<void> _eliminar(BuildContext context, String id, String titulo) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar respuesta',
                style: TextStyle(color: Colors.white)),
            content: Text('¿Eliminar "$titulo"?',
                style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;
    if (ok) {
      await FirebaseFirestore.instance
          .collection('chatbot_respuestas')
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respuestas del chatbot')),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Agrega palabras clave y su respuesta. El chatbot buscará coincidencias en los mensajes de los usuarios.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatbot_respuestas')
                  .orderBy('orden')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const EmptyState(
                    icono: Icons.chat_bubble_outline,
                    mensaje: 'No hay respuestas configuradas',
                    sub: 'Usa el botón + para agregar la primera',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _TarjetaRespuesta(
                      id: doc.id,
                      data: data,
                      onEliminar: () => _eliminar(
                          context, doc.id, data['titulo'] ?? ''),
                      onEditar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _FormRespuestaPage(
                              id: doc.id, datos: data),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _FormRespuestaPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva respuesta'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

// ─── Tarjeta de respuesta ─────────────────────────────────────────────────────

class _TarjetaRespuesta extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;

  const _TarjetaRespuesta({
    required this.id,
    required this.data,
    required this.onEliminar,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final palabras = List<String>.from(data['palabras_clave'] ?? []);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_bubble,
                  color: Colors.orangeAccent, size: 18),
            ),
            title: Text(
              data['titulo'] ?? 'Sin título',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              data['respuesta'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          if (palabras.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: palabras
                    .map((p) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color:
                                    Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Text(p,
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 11)),
                        ))
                    .toList(),
              ),
            ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.amberAccent),
                  label: const Text('Editar',
                      style: TextStyle(color: Colors.amberAccent)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORMULARIO CREAR / EDITAR RESPUESTA
// ═══════════════════════════════════════════════════════════════════════════════

class _FormRespuestaPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? datos;
  const _FormRespuestaPage({this.id, this.datos});

  @override
  State<_FormRespuestaPage> createState() => _FormRespuestaPageState();
}

class _FormRespuestaPageState extends State<_FormRespuestaPage> {
  final _tituloCtrl = TextEditingController();
  final _respuestaCtrl = TextEditingController();
  final _palabraCtrl = TextEditingController();
  List<String> _palabras = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final d = widget.datos;
    if (d != null) {
      _tituloCtrl.text = d['titulo'] ?? '';
      _respuestaCtrl.text = d['respuesta'] ?? '';
      _palabras = List<String>.from(d['palabras_clave'] ?? []);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _respuestaCtrl.dispose();
    _palabraCtrl.dispose();
    super.dispose();
  }

  void _agregarPalabra() {
    final p = _palabraCtrl.text.trim().toLowerCase();
    if (p.isEmpty || _palabras.contains(p)) return;
    setState(() => _palabras.add(p));
    _palabraCtrl.clear();
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _respuestaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa título y respuesta')));
      return;
    }
    if (_palabras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos una palabra clave')));
      return;
    }
    setState(() => _guardando = true);

    final datos = {
      'titulo': _tituloCtrl.text.trim(),
      'respuesta': _respuestaCtrl.text.trim(),
      'palabras_clave': _palabras,
    };

    try {
      final col = FirebaseFirestore.instance
          .collection('chatbot_respuestas');
      if (widget.id == null) {
        final snap =
            await col.orderBy('orden', descending: true).limit(1).get();
        final orden = snap.docs.isEmpty
            ? 0
            : ((snap.docs.first['orden'] as int? ?? 0) + 1);
        await col.add({...datos, 'orden': orden});
      } else {
        await col.doc(widget.id).update(datos);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null
            ? 'Nueva respuesta'
            : 'Editar respuesta'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.orangeAccent))
                : const Text('Guardar',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const SeccionLabel(titulo: 'Título (interno)'),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej: Horarios del gym',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Respuesta
            const SeccionLabel(titulo: 'Respuesta del bot'),
            const SizedBox(height: 8),
            TextField(
              controller: _respuestaCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Ej: Nuestros horarios son: Lunes a Viernes 6am - 10pm...',
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Palabras clave
            const SeccionLabel(titulo: 'Palabras clave (el bot detectará estas)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _palabraCtrl,
                    onSubmitted: (_) => _agregarPalabra(),
                    decoration: const InputDecoration(
                      hintText: 'Ej: horario, hora, abierto...',
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _agregarPalabra,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_palabras.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _palabras
                    .map((p) => Chip(
                          label: Text(p,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor:
                              Colors.blueAccent.withOpacity(0.2),
                          deleteIconColor: Colors.redAccent,
                          side: BorderSide(
                              color:
                                  Colors.blueAccent.withOpacity(0.4)),
                          onDeleted: () =>
                              setState(() => _palabras.remove(p)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.save),
                label: Text(_guardando
                    ? 'Guardando...'
                    : widget.id == null
                        ? 'Crear respuesta'
                        : 'Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
