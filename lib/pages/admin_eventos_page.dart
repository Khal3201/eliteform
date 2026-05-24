import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN: EVENTOS
// Permite crear, editar, reordenar y eliminar eventos del carrusel del home.
// ═══════════════════════════════════════════════════════════════════════════════

class AdminEventosPage extends StatelessWidget {
  const AdminEventosPage({super.key});

  Future<void> _eliminar(BuildContext context, String id, String titulo) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar evento',
                style: TextStyle(color: Colors.white)),
            content: Text('¿Eliminar "$titulo"?',
                style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;
    if (ok) {
      await FirebaseFirestore.instance
          .collection('eventos')
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos del carrusel')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('eventos')
            .orderBy('orden')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note,
                      color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  const Text('No hay eventos publicados',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Usa el botón + para crear el primero',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _TarjetaEvento(
                id: doc.id,
                data: data,
                orden: i,
                totalEventos: docs.length,
                onEliminar: () =>
                    _eliminar(context, doc.id, data['titulo'] ?? ''),
                onEditar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FormEventoPage(
                      id: doc.id,
                      datos: data,
                    ),
                  ),
                ),
                onSubir: i == 0
                    ? null
                    : () => _cambiarOrden(doc.id, data, docs[i - 1].id,
                        (docs[i - 1].data() as Map<String, dynamic>)),
                onBajar: i == docs.length - 1
                    ? null
                    : () => _cambiarOrden(docs[i + 1].id,
                        (docs[i + 1].data() as Map<String, dynamic>),
                        doc.id, data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _FormEventoPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }

  Future<void> _cambiarOrden(
    String idA,
    Map<String, dynamic> dataA,
    String idB,
    Map<String, dynamic> dataB,
  ) async {
    final ordenA = dataA['orden'] ?? 0;
    final ordenB = dataB['orden'] ?? 0;
    final batch = FirebaseFirestore.instance.batch();
    batch.update(
        FirebaseFirestore.instance.collection('eventos').doc(idA),
        {'orden': ordenB});
    batch.update(
        FirebaseFirestore.instance.collection('eventos').doc(idB),
        {'orden': ordenA});
    await batch.commit();
  }
}

// ─── Tarjeta de evento ────────────────────────────────────────────────────────

class _TarjetaEvento extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final int orden;
  final int totalEventos;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;
  final VoidCallback? onSubir;
  final VoidCallback? onBajar;

  const _TarjetaEvento({
    required this.id,
    required this.data,
    required this.orden,
    required this.totalEventos,
    required this.onEliminar,
    required this.onEditar,
    this.onSubir,
    this.onBajar,
  });

  static const Map<String, IconData> _iconosDisponibles = {
    'directions_bike': Icons.directions_bike,
    'self_improvement': Icons.self_improvement,
    'fitness_center': Icons.fitness_center,
    'monitor_weight': Icons.monitor_weight,
    'sports': Icons.sports,
    'pool': Icons.pool,
    'run_circle': Icons.run_circle,
    'sports_gymnastics': Icons.sports_gymnastics,
    'event': Icons.event,
    'local_fire_department': Icons.local_fire_department,
    'emoji_events': Icons.emoji_events,
  };

  @override
  Widget build(BuildContext context) {
    final color = Color(data['color'] as int? ?? 0xFFEA580C);
    final iconoNombre = data['icono'] as String? ?? 'event';
    final icono = _iconosDisponibles[iconoNombre] ?? Icons.event;
    final activo = data['activo'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: activo
                ? color.withOpacity(0.4)
                : Colors.white12),
      ),
      child: Column(
        children: [
          // Preview del evento
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ícono con color
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['titulo'] ?? 'Sin título',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          // Badge activo/inactivo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: activo
                                  ? Colors.greenAccent.withOpacity(0.15)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: activo
                                      ? Colors.greenAccent.withOpacity(0.4)
                                      : Colors.white24),
                            ),
                            child: Text(
                              activo ? 'Visible' : 'Oculto',
                              style: TextStyle(
                                  color: activo
                                      ? Colors.greenAccent
                                      : Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data['descripcion'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      if ((data['horario'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.schedule,
                                  color: color, size: 12),
                              const SizedBox(width: 4),
                              Text(data['horario'],
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Acciones
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Reordenar
                IconButton(
                  tooltip: 'Subir',
                  onPressed: onSubir,
                  icon: Icon(Icons.keyboard_arrow_up,
                      color: onSubir != null
                          ? Colors.white54
                          : Colors.white12,
                      size: 20),
                ),
                IconButton(
                  tooltip: 'Bajar',
                  onPressed: onBajar,
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: onBajar != null
                          ? Colors.white54
                          : Colors.white12,
                      size: 20),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.amberAccent),
                  label: const Text('Editar',
                      style: TextStyle(color: Colors.amberAccent)),
                ),
                const SizedBox(width: 4),
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
// FORMULARIO CREAR / EDITAR EVENTO
// ═══════════════════════════════════════════════════════════════════════════════

class _FormEventoPage extends StatefulWidget {
  final String? id; // null = crear nuevo
  final Map<String, dynamic>? datos;

  const _FormEventoPage({this.id, this.datos});

  @override
  State<_FormEventoPage> createState() => _FormEventoPageState();
}

class _FormEventoPageState extends State<_FormEventoPage> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();

  String _iconoSeleccionado = 'fitness_center';
  Color _colorSeleccionado = const Color(0xFFEA580C);
  bool _activo = true;
  bool _guardando = false;

  // Íconos disponibles (mismo set que usa _CarruselEventos en inicio_page)
  static const Map<String, IconData> _iconos = {
    'fitness_center': Icons.fitness_center,
    'directions_bike': Icons.directions_bike,
    'self_improvement': Icons.self_improvement,
    'run_circle': Icons.run_circle,
    'sports_gymnastics': Icons.sports_gymnastics,
    'monitor_weight': Icons.monitor_weight,
    'sports': Icons.sports,
    'pool': Icons.pool,
    'local_fire_department': Icons.local_fire_department,
    'emoji_events': Icons.emoji_events,
    'event': Icons.event,
  };

  // Colores predefinidos
  static const List<Color> _colores = [
    Color(0xFFEA580C), // naranja
    Color(0xFFDC2626), // rojo
    Color(0xFF2563EB), // azul
    Color(0xFF16A34A), // verde
    Color(0xFF9333EA), // morado
    Color(0xFFCA8A04), // amarillo
    Color(0xFF0891B2), // cyan
    Color(0xFFDB2777), // rosa
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.datos;
    if (d != null) {
      _tituloCtrl.text = d['titulo'] ?? '';
      _descCtrl.text = d['descripcion'] ?? '';
      _horarioCtrl.text = d['horario'] ?? '';
      _iconoSeleccionado = d['icono'] ?? 'fitness_center';
      _colorSeleccionado = Color(d['color'] as int? ?? 0xFFEA580C);
      _activo = d['activo'] as bool? ?? true;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _horarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    setState(() => _guardando = true);

    final datos = {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descCtrl.text.trim(),
      'horario': _horarioCtrl.text.trim(),
      'icono': _iconoSeleccionado,
      'color': _colorSeleccionado.value,
      'activo': _activo,
    };

    try {
      final col = FirebaseFirestore.instance.collection('eventos');
      if (widget.id == null) {
        // Crear: calcular el siguiente orden
        final snap = await col.orderBy('orden', descending: true).limit(1).get();
        final siguienteOrden =
            snap.docs.isEmpty ? 0 : ((snap.docs.first['orden'] as int) + 1);
        await col.add({...datos, 'orden': siguienteOrden});
      } else {
        // Editar: conservar el orden actual
        await col.doc(widget.id).update(datos);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.id == null
              ? 'Evento creado correctamente'
              : 'Evento actualizado'),
          backgroundColor: Colors.greenAccent,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.id == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esNuevo ? 'Nuevo evento' : 'Editar evento'),
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
            // ── Preview del carrusel ─────────────────────────────────────
            _PreviewEvento(
              titulo: _tituloCtrl.text.isEmpty
                  ? 'Título del evento'
                  : _tituloCtrl.text,
              descripcion: _descCtrl.text.isEmpty
                  ? 'Descripción...'
                  : _descCtrl.text,
              horario: _horarioCtrl.text.isEmpty
                  ? 'Horario...'
                  : _horarioCtrl.text,
              icono: _iconos[_iconoSeleccionado] ?? Icons.event,
              color: _colorSeleccionado,
            ),
            const SizedBox(height: 24),

            // ── Campos de texto ──────────────────────────────────────────
            _SecLabel(titulo: 'Título *'),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Ej: Clase de Spinning',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            _SecLabel(titulo: 'Descripción'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Ej: Todos los martes y jueves',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 16),

            _SecLabel(titulo: 'Horario'),
            const SizedBox(height: 8),
            TextField(
              controller: _horarioCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Ej: Mar y Jue · 7:00 AM',
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 24),

            // ── Selector de ícono ────────────────────────────────────────
            _SecLabel(titulo: 'Ícono'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconos.entries.map((entry) {
                final sel = _iconoSeleccionado == entry.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _iconoSeleccionado = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? _colorSeleccionado.withOpacity(0.2)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? _colorSeleccionado
                              : Colors.white12,
                          width: sel ? 2 : 1),
                    ),
                    child: Icon(entry.value,
                        color: sel
                            ? _colorSeleccionado
                            : Colors.white38,
                        size: 26),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Selector de color ────────────────────────────────────────
            _SecLabel(titulo: 'Color'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colores.map((c) {
                final sel = _colorSeleccionado.value == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _colorSeleccionado = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 3),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2)
                            ]
                          : [],
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Toggle visibilidad ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined,
                      color: Colors.white54, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Visible en el carrusel',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text(
                          _activo
                              ? 'Los usuarios verán este evento'
                              : 'El evento está oculto para los usuarios',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _activo,
                    onChanged: (v) => setState(() => _activo = v),
                    activeColor: Colors.orangeAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Botón guardar ────────────────────────────────────────────
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
                    : esNuevo
                        ? 'Crear evento'
                        : 'Guardar cambios'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Preview del evento (igual al carrusel del home) ─────────────────────────

class _PreviewEvento extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String horario;
  final IconData icono;
  final Color color;

  const _PreviewEvento({
    required this.titulo,
    required this.descripcion,
    required this.horario,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vista previa',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.35),
                const Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: color, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: color, size: 13),
                        const SizedBox(width: 4),
                        Text(horario,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Widget auxiliar ──────────────────────────────────────────────────────────

class _SecLabel extends StatelessWidget {
  final String titulo;
  const _SecLabel({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(titulo,
        style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13));
  }
}
