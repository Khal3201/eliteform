import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ejercicio_model.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const List<String> kMusculosEjercicio = [
  'Pecho',
  'Espalda',
  'Hombros',
  'Bíceps',
  'Tríceps',
  'Abdomen',
  'Glúteos',
  'Piernas',
  'Full Body',
];

const List<String> kCategoriasEjercicio = [
  'Fuerza',
  'Cardio',
  'Flexibilidad',
  'Resistencia',
];

const List<String> kNivelesEjercicio = [
  'Principiante',
  'Intermedio',
  'Avanzado',
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color colorCategoria(String cat) {
  switch (cat) {
    case 'Fuerza':
      return Colors.redAccent;
    case 'Cardio':
      return Colors.orangeAccent;
    case 'Flexibilidad':
      return Colors.purpleAccent;
    case 'Resistencia':
      return Colors.greenAccent;
    default:
      return Colors.white54;
  }
}

IconData iconoCategoria(String cat) {
  switch (cat) {
    case 'Fuerza':
      return Icons.fitness_center;
    case 'Cardio':
      return Icons.directions_run;
    case 'Flexibilidad':
      return Icons.self_improvement;
    case 'Resistencia':
      return Icons.loop;
    default:
      return Icons.sports_gymnastics;
  }
}

Color colorNivel(String nivel) {
  switch (nivel) {
    case 'Principiante':
      return Colors.greenAccent;
    case 'Intermedio':
      return Colors.amberAccent;
    case 'Avanzado':
      return Colors.redAccent;
    default:
      return Colors.white54;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PÁGINA PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════════

class EjerciciosPage extends StatefulWidget {
  const EjerciciosPage({super.key});

  @override
  State<EjerciciosPage> createState() => _EjerciciosPageState();
}

class _EjerciciosPageState extends State<EjerciciosPage> {
  String? _musculoFiltro;
  String? _categoriaFiltro;
  String? _nivelFiltro;
  String _busqueda = '';
  final _busquedaCtrl = TextEditingController();

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _buildStream() {
    // Filtramos por categoría en Firestore si hay filtro, resto en cliente
    if (_categoriaFiltro != null) {
      return FirestoreService().getEjerciciosPorCategoria(_categoriaFiltro!);
    }
    return FirestoreService().getEjerciciosAdmin();
  }

  List<EjercicioModel> _aplicarFiltros(List<QueryDocumentSnapshot> docs) {
    var lista = docs
        .map((d) =>
            EjercicioModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();

    if (_musculoFiltro != null) {
      lista = lista.where((e) => e.musculo == _musculoFiltro).toList();
    }
    if (_nivelFiltro != null) {
      lista = lista.where((e) => e.nivel == _nivelFiltro).toList();
    }
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista
          .where((e) =>
              e.nombre.toLowerCase().contains(q) ||
              e.musculo.toLowerCase().contains(q) ||
              e.descripcion.toLowerCase().contains(q))
          .toList();
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Filtros ──────────────────────────────────────────────────────
          _FiltrosEjercicios(
            musculoSeleccionado: _musculoFiltro,
            categoriaSeleccionada: _categoriaFiltro,
            nivelSeleccionado: _nivelFiltro,
            onMusculo: (v) => setState(() => _musculoFiltro = v),
            onCategoria: (v) => setState(() => _categoriaFiltro = v),
            onNivel: (v) => setState(() => _nivelFiltro = v),
          ),

          // ── Lista ────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                final ejercicios = _aplicarFiltros(docs);

                if (ejercicios.isEmpty) {
                  return EmptyState(
                    icono: Icons.sports_gymnastics,
                    mensaje: docs.isEmpty
                        ? 'No hay ejercicios en el catálogo'
                        : 'No hay ejercicios con esos filtros',
                    sub: docs.isEmpty
                        ? 'El administrador aún no ha publicado ejercicios.'
                        : 'Prueba con otros filtros o borra la búsqueda.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ejercicios.length,
                  itemBuilder: (_, i) =>
                      _TarjetaEjercicio(ejercicio: ejercicios[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filtros ──────────────────────────────────────────────────────────────────

class _FiltrosEjercicios extends StatelessWidget {
  final String? musculoSeleccionado;
  final String? categoriaSeleccionada;
  final String? nivelSeleccionado;
  final ValueChanged<String?> onMusculo;
  final ValueChanged<String?> onCategoria;
  final ValueChanged<String?> onNivel;

  const _FiltrosEjercicios({
    required this.musculoSeleccionado,
    required this.categoriaSeleccionada,
    required this.nivelSeleccionado,
    required this.onMusculo,
    required this.onCategoria,
    required this.onNivel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChipFiltro(
                  label: 'Todos',
                  icono: Icons.apps,
                  color: Colors.white54,
                  seleccionado: categoriaSeleccionada == null,
                  onTap: () => onCategoria(null),
                ),
                const SizedBox(width: 8),
                ...kCategoriasEjercicio.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChipFiltro(
                        label: c,
                        icono: iconoCategoria(c),
                        color: colorCategoria(c),
                        seleccionado: categoriaSeleccionada == c,
                        onTap: () =>
                            onCategoria(categoriaSeleccionada == c ? null : c),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Músculo + Nivel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Musculo dropdown-chip
                _DropChip(
                  label: musculoSeleccionado ?? 'Músculo',
                  icono: Icons.accessibility_new,
                  color: Colors.blueAccent,
                  activo: musculoSeleccionado != null,
                  onTap: () => _mostrarOpciones(
                    context,
                    'Músculo',
                    kMusculosEjercicio,
                    musculoSeleccionado,
                    onMusculo,
                  ),
                ),
                const SizedBox(width: 8),
                _DropChip(
                  label: nivelSeleccionado ?? 'Nivel',
                  icono: Icons.bar_chart,
                  color: Colors.amberAccent,
                  activo: nivelSeleccionado != null,
                  onTap: () => _mostrarOpciones(
                    context,
                    'Nivel',
                    kNivelesEjercicio,
                    nivelSeleccionado,
                    onNivel,
                  ),
                ),
                if (musculoSeleccionado != null || nivelSeleccionado != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      onMusculo(null);
                      onNivel(null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, color: Colors.redAccent, size: 13),
                          SizedBox(width: 4),
                          Text('Limpiar',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpciones(
    BuildContext context,
    String titulo,
    List<String> opciones,
    String? seleccionado,
    ValueChanged<String?> onSeleccion,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.apps, color: Colors.white38),
            title: const Text('Todos',
                style: TextStyle(color: Colors.white54)),
            trailing: seleccionado == null
                ? const Icon(Icons.check, color: Colors.orangeAccent)
                : null,
            onTap: () {
              onSeleccion(null);
              Navigator.pop(context);
            },
          ),
          ...opciones.map((o) => ListTile(
                leading: Icon(Icons.circle,
                    color: Colors.orangeAccent.withOpacity(0.5), size: 8),
                title: Text(o, style: const TextStyle(color: Colors.white)),
                trailing: seleccionado == o
                    ? const Icon(Icons.check, color: Colors.orangeAccent)
                    : null,
                onTap: () {
                  onSeleccion(o);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DropChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final bool activo;
  final VoidCallback onTap;
  const _DropChip({
    required this.label,
    required this.icono,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? color.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
              color: activo ? color : Colors.white12,
              width: activo ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: activo ? color : Colors.white38, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: activo ? color : Colors.white54,
                    fontSize: 12,
                    fontWeight:
                        activo ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down,
                color: activo ? color : Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de ejercicio ─────────────────────────────────────────────────────

class _TarjetaEjercicio extends StatelessWidget {
  final EjercicioModel ejercicio;
  const _TarjetaEjercicio({required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    final color = colorCategoria(ejercicio.categoria);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconoCategoria(ejercicio.categoria),
                          color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ejercicio.nombre,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _MiniChip(
                                  label: ejercicio.musculo,
                                  color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              _MiniChip(
                                  label: ejercicio.nivel,
                                  color: colorNivel(ejercicio.nivel)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _PillTag(
                        label: ejercicio.categoria, color: color, small: true),
                  ],
                ),
                const SizedBox(height: 10),
                Text(ejercicio.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4)),
                if (ejercicio.equipamiento.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.build_outlined,
                          color: Colors.white24, size: 13),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          ejercicio.equipamiento.join(' · '),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _mostrarDetalle(context),
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('Ver detalle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: _DetalleEjercicioSheet(ejercicio: ejercicio),
        ),
      ),
    );
  }
}

class _DetalleEjercicioSheet extends StatelessWidget {
  final EjercicioModel ejercicio;
  const _DetalleEjercicioSheet({required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    final color = colorCategoria(ejercicio.categoria);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconoCategoria(ejercicio.categoria),
                    color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ejercicio.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniChip(
                            label: ejercicio.categoria, color: color),
                        const SizedBox(width: 6),
                        _MiniChip(
                            label: ejercicio.musculo,
                            color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        _MiniChip(
                            label: ejercicio.nivel,
                            color: colorNivel(ejercicio.nivel)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          const Text('Descripción',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(ejercicio.descripcion,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.6)),
          if (ejercicio.instrucciones != null &&
              ejercicio.instrucciones!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Instrucciones',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(ejercicio.instrucciones!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.6)),
            ),
          ],
          if (ejercicio.equipamiento.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Equipamiento necesario',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ejercicio.equipamiento.isEmpty
                  ? [
                      const _MiniChip(
                          label: 'Sin equipamiento',
                          color: Colors.greenAccent)
                    ]
                  : ejercicio.equipamiento
                      .map((e) => _MiniChip(label: e, color: Colors.white54))
                      .toList(),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                SizedBox(width: 8),
                Text('No requiere equipamiento',
                    style:
                        TextStyle(color: Colors.greenAccent, fontSize: 13)),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;
  const _PillTag(
      {required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: small ? 0 : 0.5)),
    );
  }
}