import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const List<String> kObjetivosRutina = [
  'Fuerza',
  'Volumen',
  'Resistencia',
  'Definición',
  'Movilidad',
];

const List<String> kNivelesRutina = [
  'Principiante',
  'Intermedio',
  'Avanzado',
];

const List<String> kMusculosDisponibles = [
  'Pecho',
  'Espalda',
  'Hombros',
  'Bíceps',
  'Tríceps',
  'Abdomen',
  'Glúteos',
  'Cuádriceps',
  'Femorales',
  'Pantorrillas',
  'Antebrazo',
  'Full Body',
];

// ─── Helpers de color / icono ─────────────────────────────────────────────────

Color colorObjetivoRutina(String obj) {
  switch (obj) {
    case 'Fuerza':
      return Colors.redAccent;
    case 'Volumen':
      return Colors.blueAccent;
    case 'Resistencia':
      return Colors.greenAccent;
    case 'Definición':
      return Colors.orangeAccent;
    case 'Movilidad':
      return Colors.purpleAccent;
    default:
      return Colors.white54;
  }
}

IconData iconoObjetivoRutina(String obj) {
  switch (obj) {
    case 'Fuerza':
      return Icons.bolt;
    case 'Volumen':
      return Icons.fitness_center;
    case 'Resistencia':
      return Icons.directions_run;
    case 'Definición':
      return Icons.auto_awesome;
    case 'Movilidad':
      return Icons.self_improvement;
    default:
      return Icons.sports_gymnastics;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PÁGINA PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════════

class RutinaPage extends StatelessWidget {
  const RutinaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<RutinaModel?>(
      stream: FirestoreService().streamRutinaActiva(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rutinaActiva = snapshot.data;
        if (rutinaActiva != null) {
          return _RutinaActivaView(rutina: rutinaActiva, uid: user.uid);
        }
        return _RutinaTabs(uid: user.uid);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VISTA: RUTINA ACTIVA
// ═══════════════════════════════════════════════════════════════════════════════

class _RutinaActivaView extends StatelessWidget {
  final RutinaModel rutina;
  final String uid;
  const _RutinaActivaView({required this.rutina, required this.uid});

  Future<void> _abandonar(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Abandonar rutina',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                '¿Seguro que quieres abandonar esta rutina? Podrás elegir otra cuando quieras.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Abandonar',
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await FirestoreService().abandonarRutina(uid);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoRutina(rutina.objetivo);
    final tabCount = rutina.dias.isEmpty ? 1 : rutina.dias.length + 1;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    _TarjetaActiva(rutina: rutina, color: color),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _abandonar(context),
                        icon: const Icon(Icons.exit_to_app,
                            color: Colors.redAccent, size: 18),
                        label: const Text('Abandonar rutina',
                            style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (rutina.dias.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverTabBarDelegate(
                  TabBar(
                    isScrollable: true,
                    indicatorColor: color,
                    labelColor: color,
                    unselectedLabelColor: Colors.white38,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      const Tab(text: 'Resumen'),
                      ...rutina.dias.map((d) => Tab(text: d.nombreDia)),
                    ],
                  ),
                ),
              ),
          ],
          body: rutina.dias.isEmpty
              ? const Center(
                  child: Text('Esta rutina no tiene días definidos.',
                      style: TextStyle(color: Colors.white38)))
              : TabBarView(
                  children: [
                    ResumenRutinaView(rutina: rutina, color: color),
                    ...rutina.dias.map((d) => DiaRutinaView(dia: d)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TarjetaActiva extends StatelessWidget {
  final RutinaModel rutina;
  final Color color;
  const _TarjetaActiva({required this.rutina, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.35), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PillTag(label: 'RUTINA ACTUAL', color: color),
              const Spacer(),
              _PillTag(label: rutina.nivel, color: Colors.white38, small: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(rutina.nombreRutina,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(rutina.descripcion,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: rutina.musculosPrincipales
                .map((m) => ChipMusculo(musculo: m, color: color))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatBox(
                  label: 'Días/semana',
                  valor: '${rutina.diasPorSemana}',
                  color: color),
              const SizedBox(width: 10),
              StatBox(label: 'Objetivo', valor: rutina.objetivo, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABS CUANDO NO HAY RUTINA ACTIVA
// ═══════════════════════════════════════════════════════════════════════════════

class _RutinaTabs extends StatelessWidget {
  final String uid;
  const _RutinaTabs({required this.uid});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF020617),
            bottom: const TabBar(
              indicatorColor: Colors.orangeAccent,
              labelColor: Colors.orangeAccent,
              unselectedLabelColor: Colors.white38,
              tabs: [
                Tab(icon: Icon(Icons.person, size: 18), text: 'Mis Rutinas'),
                Tab(icon: Icon(Icons.star, size: 18), text: 'Recomendadas'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _MisRutinasTab(uid: uid),
            _RecomendadasTab(uid: uid),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CrearRutinaPage(uid: uid, esAdmin: false))),
          icon: const Icon(Icons.add),
          label: const Text('Nueva rutina'),
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

class _MisRutinasTab extends StatelessWidget {
  final String uid;
  const _MisRutinasTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getRutinasDeUsuario(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyState(
            icono: Icons.fitness_center,
            mensaje: 'Aún no has creado ninguna rutina.',
            sub: 'Usa el botón + para crear tu primera rutina.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final rutina = RutinaModel.fromMap(
                docs[i].id, docs[i].data() as Map<String, dynamic>);
            return TarjetaRutina(rutina: rutina, uid: uid, mostrarBorrar: true);
          },
        );
      },
    );
  }
}

class _RecomendadasTab extends StatefulWidget {
  final String uid;
  const _RecomendadasTab({required this.uid});

  @override
  State<_RecomendadasTab> createState() => _RecomendadasTabState();
}

class _RecomendadasTabState extends State<_RecomendadasTab> {
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorObjetivosRutina(
          seleccionado: _filtro,
          onSeleccionado: (v) => setState(() => _filtro = v),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _filtro == null
                ? FirestoreService().getRutinasAdmin()
                : FirestoreService().getRutinasAdminPorObjetivo(_filtro!),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return EmptyState(
                  icono: Icons.search_off,
                  mensaje: 'No hay rutinas recomendadas',
                  sub: _filtro != null
                      ? 'para el objetivo "$_filtro".'
                      : 'El administrador aún no ha publicado rutinas.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final rutina = RutinaModel.fromMap(
                      docs[i].id, docs[i].data() as Map<String, dynamic>);
                  return TarjetaRutina(
                      rutina: rutina, uid: widget.uid, mostrarBorrar: false);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Selector de objetivos ────────────────────────────────────────────────────

class SelectorObjetivosRutina extends StatelessWidget {
  final String? seleccionado;
  final ValueChanged<String?> onSeleccionado;
  const SelectorObjetivosRutina(
      {super.key, required this.seleccionado, required this.onSeleccionado});

  static const Map<String, IconData> _iconos = {
    'Fuerza': Icons.bolt,
    'Volumen': Icons.fitness_center,
    'Resistencia': Icons.directions_run,
    'Definición': Icons.auto_awesome,
    'Movilidad': Icons.self_improvement,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Cuál es tu objetivo?',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChipFiltro(
                  label: 'Todos',
                  icono: Icons.apps,
                  color: Colors.white54,
                  seleccionado: seleccionado == null,
                  onTap: () => onSeleccionado(null),
                ),
                const SizedBox(width: 8),
                ...kObjetivosRutina.map((obj) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChipFiltro(
                        label: obj,
                        icono: _iconos[obj]!,
                        color: colorObjetivoRutina(obj),
                        seleccionado: seleccionado == obj,
                        onTap: () =>
                            onSeleccionado(seleccionado == obj ? null : obj),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TARJETA DE RUTINA
// ═══════════════════════════════════════════════════════════════════════════════

class TarjetaRutina extends StatelessWidget {
  final RutinaModel rutina;
  final String uid;
  final bool mostrarBorrar;
  const TarjetaRutina(
      {super.key,
      required this.rutina,
      required this.uid,
      required this.mostrarBorrar});

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoRutina(rutina.objetivo);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PillTag(label: rutina.objetivo, color: color),
                    const Spacer(),
                    _PillTag(
                        label: rutina.nivel,
                        color: Colors.white38,
                        small: true),
                  ],
                ),
                const SizedBox(height: 10),
                Text(rutina.nombreRutina,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                const SizedBox(height: 4),
                Text(rutina.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: rutina.musculosPrincipales
                      .map((m) => ChipMusculo(musculo: m, color: color))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text('${rutina.diasPorSemana} días/sem',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 14),
                    const Icon(Icons.list_alt, color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text('${rutina.dias.length} días definidos',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              DetalleRutinaPage(rutina: rutina, uid: uid))),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver detalle'),
                ),
                const Spacer(),
                if (mostrarBorrar)
                  IconButton(
                    onPressed: () async {
                      final ok = await _confirmarEliminar(context);
                      if (ok)
                        await FirestoreService().eliminarRutina(rutina.id);
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 18),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    await FirestoreService().activarRutina(uid, rutina.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('¡Rutina activada!'),
                          backgroundColor: Colors.greenAccent));
                    }
                  },
                  child: const Text('Iniciar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar rutina',
                style: TextStyle(color: Colors.white)),
            content: const Text('¿Eliminar esta rutina permanentemente?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DETALLE DE RUTINA
// ═══════════════════════════════════════════════════════════════════════════════

class DetalleRutinaPage extends StatelessWidget {
  final RutinaModel rutina;
  final String uid;
  const DetalleRutinaPage({super.key, required this.rutina, required this.uid});

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoRutina(rutina.objetivo);
    return DefaultTabController(
      length: rutina.dias.isEmpty ? 1 : rutina.dias.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(rutina.nombreRutina),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: color,
            labelColor: color,
            unselectedLabelColor: Colors.white38,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'Resumen'),
              ...rutina.dias.map((d) => Tab(text: d.nombreDia)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ResumenRutinaView(rutina: rutina, color: color),
            ...rutina.dias.map((d) => DiaRutinaView(dia: d)),
          ],
        ),
        bottomNavigationBar: uid != 'admin'
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirestoreService().activarRutina(uid, rutina.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar esta rutina'),
                ),
              )
            : null,
      ),
    );
  }
}

class ResumenRutinaView extends StatelessWidget {
  final RutinaModel rutina;
  final Color color;
  const ResumenRutinaView(
      {super.key, required this.rutina, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Bloque(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Descripción',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                  rutina.descripcion.isNotEmpty
                      ? rutina.descripcion
                      : 'Sin descripción.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Bloque(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Músculos principales',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: rutina.musculosPrincipales
                    .map((m) => ChipMusculo(musculo: m, color: color))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Bloque(
          child: Column(
            children: [
              InfoFila(
                  icono: Icons.bar_chart, label: 'Nivel', valor: rutina.nivel),
              const Divider(color: Colors.white12, height: 20),
              InfoFila(
                  icono: Icons.calendar_today,
                  label: 'Días por semana',
                  valor: '${rutina.diasPorSemana}'),
              const Divider(color: Colors.white12, height: 20),
              InfoFila(
                  icono: Icons.list,
                  label: 'Días definidos',
                  valor: '${rutina.dias.length}'),
            ],
          ),
        ),
      ],
    );
  }
}

class DiaRutinaView extends StatelessWidget {
  final DiaRutinaModel dia;
  const DiaRutinaView({super.key, required this.dia});

  @override
  Widget build(BuildContext context) {
    if (dia.ejercicios.isEmpty) {
      return const Center(
          child: Text('Sin ejercicios para este día.',
              style: TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dia.ejercicios.length,
      itemBuilder: (_, i) {
        final ej = dia.ejercicios[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(ej.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                  _PillTag(
                      label: ej.musculo, color: Colors.white38, small: true),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  MiniStat(label: 'Series', valor: '${ej.series}'),
                  const SizedBox(width: 16),
                  MiniStat(label: 'Reps', valor: ej.repeticiones),
                  const SizedBox(width: 16),
                  MiniStat(label: 'Descanso', valor: ej.descanso),
                ],
              ),
              if (ej.notas != null && ej.notas!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(ej.notas!,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12))),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CREAR RUTINA — formulario manual + JSON
// ═══════════════════════════════════════════════════════════════════════════════

class CrearRutinaPage extends StatefulWidget {
  final String uid;
  final bool esAdmin;
  const CrearRutinaPage({super.key, required this.uid, required this.esAdmin});

  @override
  State<CrearRutinaPage> createState() => _CrearRutinaPageState();
}

class _CrearRutinaPageState extends State<CrearRutinaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Paso 1: datos generales
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _objetivo = kObjetivosRutina.first;
  String _nivel = kNivelesRutina.first;
  int _diasSemana = 3;
  final List<String> _musculos = [];

  // Paso 2: días y ejercicios
  // Lista de días: cada día tiene nombre + lista de ejercicios
  final List<_DiaTemp> _dias = [];

  bool _guardando = false;
  String? _errorJson;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Agregar un día nuevo ──────────────────────────────────────────────────

  void _agregarDia() {
    setState(() {
      _dias.add(_DiaTemp(
        nombreDia: 'Día ${_dias.length + 1}',
        ejercicios: [],
      ));
    });
  }

  // ── Eliminar día ──────────────────────────────────────────────────────────

  void _eliminarDia(int index) {
    setState(() => _dias.removeAt(index));
  }

  // ── Editar nombre de un día ───────────────────────────────────────────────

  Future<void> _editarNombreDia(int index) async {
    final ctrl = TextEditingController(text: _dias[index].nombreDia);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Nombre del día', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Ej: Lunes - Pecho y Tríceps'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _dias[index].nombreDia = result);
    }
  }

  // ── Agregar ejercicio a un día ────────────────────────────────────────────

  Future<void> _agregarEjercicio(int diaIndex) async {
    final result = await Navigator.push<EjercicioRutinaModel>(
      context,
      MaterialPageRoute(builder: (_) => const _FormEjercicioPage()),
    );
    if (result != null) {
      setState(() => _dias[diaIndex].ejercicios.add(result));
    }
  }

  // ── Editar ejercicio existente ────────────────────────────────────────────

  Future<void> _editarEjercicio(int diaIndex, int ejIndex) async {
    final result = await Navigator.push<EjercicioRutinaModel>(
      context,
      MaterialPageRoute(
          builder: (_) => _FormEjercicioPage(
              ejercicio: _dias[diaIndex].ejercicios[ejIndex])),
    );
    if (result != null) {
      setState(() => _dias[diaIndex].ejercicios[ejIndex] = result);
    }
  }

  // ── Guardar rutina manual ─────────────────────────────────────────────────

  Future<void> _guardarManual() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para la rutina')));
      return;
    }
    setState(() => _guardando = true);

    final dias = _dias
        .map((d) => DiaRutinaModel(
              nombreDia: d.nombreDia,
              ejercicios: d.ejercicios,
            ))
        .toList();

    final rutina = RutinaModel(
      id: '',
      nombreRutina: _nombreCtrl.text.trim(),
      objetivo: _objetivo,
      descripcion: _descCtrl.text.trim(),
      musculosPrincipales: _musculos,
      nivel: _nivel,
      diasPorSemana: _diasSemana,
      creadoPor: widget.esAdmin ? 'admin' : widget.uid,
      dias: dias,
    );

    await FirestoreService().crearRutina(rutina);
    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  // ── Importar desde JSON (funciona en web y mobile) ────────────────────────

  Future<void> _importarJson() async {
    setState(() => _errorJson = null);
    try {
      final json = await leerArchivoJson(); // usa bytes, no File

      if (json['nombre_rutina'] == null || json['objetivo'] == null) {
        setState(() =>
            _errorJson = 'El JSON debe incluir "nombre_rutina" y "objetivo".');
        return;
      }

      setState(() => _guardando = true);

      final rutina = RutinaModel.fromMap('', {
        ...json,
        'creado_por': widget.esAdmin ? 'admin' : widget.uid,
      });

      await FirestoreService().crearRutina(rutina);
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✓ Rutina importada correctamente'),
              backgroundColor: Colors.greenAccent),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (e.toString().contains('__cancelado__')) return;
      setState(() {
        _guardando = false;
        _errorJson =
            'Error al leer el archivo: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rutina'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.edit, size: 16), text: 'Manual'),
            Tab(icon: Icon(Icons.upload_file, size: 16), text: 'Desde JSON'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _FormManual(
            nombreCtrl: _nombreCtrl,
            descCtrl: _descCtrl,
            objetivo: _objetivo,
            nivel: _nivel,
            diasSemana: _diasSemana,
            musculos: _musculos,
            dias: _dias,
            guardando: _guardando,
            onObjetivo: (v) => setState(() => _objetivo = v),
            onNivel: (v) => setState(() => _nivel = v),
            onDiasSemana: (v) => setState(() => _diasSemana = v),
            onMusculos: (m, v) => setState(() {
              if (v) {
                _musculos.add(m);
              } else {
                _musculos.remove(m);
              }
            }),
            onAgregarDia: _agregarDia,
            onEliminarDia: _eliminarDia,
            onEditarNombreDia: _editarNombreDia,
            onAgregarEjercicio: _agregarEjercicio,
            onEditarEjercicio: _editarEjercicio,
            onEliminarEjercicio: (diaI, ejI) =>
                setState(() => _dias[diaI].ejercicios.removeAt(ejI)),
            onGuardar: _guardarManual,
          ),
          JsonImportTab(
            tipo: 'rutina',
            onImportar: _importarJson,
            cargando: _guardando,
            error: _errorJson,
          ),
        ],
      ),
    );
  }
}

// ─── Formulario manual (extraído para legibilidad) ────────────────────────────

class _FormManual extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController descCtrl;
  final String objetivo;
  final String nivel;
  final int diasSemana;
  final List<String> musculos;
  final List<_DiaTemp> dias;
  final bool guardando;
  final ValueChanged<String> onObjetivo;
  final ValueChanged<String> onNivel;
  final ValueChanged<int> onDiasSemana;
  final void Function(String m, bool v) onMusculos;
  final VoidCallback onAgregarDia;
  final void Function(int) onEliminarDia;
  final void Function(int) onEditarNombreDia;
  final void Function(int) onAgregarEjercicio;
  final void Function(int, int) onEditarEjercicio;
  final void Function(int, int) onEliminarEjercicio;
  final VoidCallback onGuardar;

  const _FormManual({
    required this.nombreCtrl,
    required this.descCtrl,
    required this.objetivo,
    required this.nivel,
    required this.diasSemana,
    required this.musculos,
    required this.dias,
    required this.guardando,
    required this.onObjetivo,
    required this.onNivel,
    required this.onDiasSemana,
    required this.onMusculos,
    required this.onAgregarDia,
    required this.onEliminarDia,
    required this.onEditarNombreDia,
    required this.onAgregarEjercicio,
    required this.onEditarEjercicio,
    required this.onEliminarEjercicio,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info general ──────────────────────────────────────────────────
          CampoTexto(
              ctrl: nombreCtrl,
              label: 'Nombre de la rutina',
              icono: Icons.fitness_center),
          const SizedBox(height: 14),
          CampoTexto(
              ctrl: descCtrl,
              label: 'Descripción',
              icono: Icons.notes,
              maxLines: 2),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Objetivo'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kObjetivosRutina.map((obj) {
              final sel = objetivo == obj;
              return ChoiceChip(
                label: Text(obj),
                selected: sel,
                selectedColor: Colors.orangeAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => onObjetivo(obj),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Nivel'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: kNivelesRutina.map((n) {
              final sel = nivel == n;
              return ChoiceChip(
                label: Text(n),
                selected: sel,
                selectedColor: Colors.orangeAccent,
                labelStyle:
                    TextStyle(color: sel ? Colors.black : Colors.white70),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => onNivel(n),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const SeccionLabel(titulo: 'Días por semana'),
              const Spacer(),
              Text('$diasSemana días',
                  style: const TextStyle(
                      color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: diasSemana.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$diasSemana días',
            activeColor: Colors.orangeAccent,
            onChanged: (v) => onDiasSemana(v.round()),
          ),
          const SizedBox(height: 8),

          const SeccionLabel(titulo: 'Músculos principales'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMusculosDisponibles.map((m) {
              final sel = musculos.contains(m);
              return FilterChip(
                label: Text(m),
                selected: sel,
                selectedColor: Colors.orangeAccent.withOpacity(0.2),
                checkmarkColor: Colors.orangeAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.orangeAccent : Colors.white54,
                    fontSize: 12),
                backgroundColor: const Color(0xFF1E293B),
                side: BorderSide(
                    color: sel ? Colors.orangeAccent : Colors.white12),
                onSelected: (v) => onMusculos(m, v),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Días y ejercicios ─────────────────────────────────────────────
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            children: [
              const SeccionLabel(titulo: 'Días de entrenamiento'),
              const Spacer(),
              TextButton.icon(
                onPressed: onAgregarDia,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar día'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (dias.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Text(
                  'Sin días. Puedes guardar la rutina así\ny agregar días después.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            ),

          ...List.generate(dias.length, (diaI) {
            final dia = dias[diaI];
            return _TarjetaDiaEditor(
              dia: dia,
              diaIndex: diaI,
              onEditarNombre: () => onEditarNombreDia(diaI),
              onEliminar: () => onEliminarDia(diaI),
              onAgregarEjercicio: () => onAgregarEjercicio(diaI),
              onEditarEjercicio: (ejI) => onEditarEjercicio(diaI, ejI),
              onEliminarEjercicio: (ejI) => onEliminarEjercicio(diaI, ejI),
            );
          }),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: guardando ? null : onGuardar,
              icon: guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.save),
              label: Text(guardando ? 'Guardando...' : 'Guardar rutina'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Tarjeta de edición de un día ─────────────────────────────────────────────

class _TarjetaDiaEditor extends StatelessWidget {
  final _DiaTemp dia;
  final int diaIndex;
  final VoidCallback onEditarNombre;
  final VoidCallback onEliminar;
  final VoidCallback onAgregarEjercicio;
  final void Function(int) onEditarEjercicio;
  final void Function(int) onEliminarEjercicio;

  const _TarjetaDiaEditor({
    required this.dia,
    required this.diaIndex,
    required this.onEditarNombre,
    required this.onEliminar,
    required this.onAgregarEjercicio,
    required this.onEditarEjercicio,
    required this.onEliminarEjercicio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${diaIndex + 1}',
                      style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(dia.nombreDia,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
                IconButton(
                  tooltip: 'Editar nombre',
                  onPressed: onEditarNombre,
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.white38, size: 18),
                ),
                IconButton(
                  tooltip: 'Eliminar día',
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Lista de ejercicios
          if (dia.ejercicios.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Sin ejercicios. Toca "+" para agregar.',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),

          ...List.generate(dia.ejercicios.length, (ejI) {
            final ej = dia.ejercicios[ejI];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.orangeAccent.withOpacity(0.15),
                child: Text('${ejI + 1}',
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              title: Text(ej.nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              subtitle: Text(
                  '${ej.musculo} · ${ej.series}×${ej.repeticiones} · ${ej.descanso}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 18,
                    onPressed: () => onEditarEjercicio(ejI),
                    icon:
                        const Icon(Icons.edit_outlined, color: Colors.white38),
                  ),
                  IconButton(
                    iconSize: 18,
                    onPressed: () => onEliminarEjercicio(ejI),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }),

          // Botón agregar ejercicio
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAgregarEjercicio,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar ejercicio'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orangeAccent.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORMULARIO DE EJERCICIO
// ═══════════════════════════════════════════════════════════════════════════════

class _FormEjercicioPage extends StatefulWidget {
  final EjercicioRutinaModel? ejercicio; // null = nuevo
  const _FormEjercicioPage({this.ejercicio});

  @override
  State<_FormEjercicioPage> createState() => _FormEjercicioPageState();
}

class _FormEjercicioPageState extends State<_FormEjercicioPage> {
  final _nombreCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _descansoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String _musculo = kMusculosDisponibles.first;

  @override
  void initState() {
    super.initState();
    final e = widget.ejercicio;
    if (e != null) {
      _nombreCtrl.text = e.nombre;
      _seriesCtrl.text = '${e.series}';
      _repsCtrl.text = e.repeticiones;
      _descansoCtrl.text = e.descanso;
      _notasCtrl.text = e.notas ?? '';
      _musculo = e.musculo;
    } else {
      _seriesCtrl.text = '3';
      _repsCtrl.text = '10-12';
      _descansoCtrl.text = '60 seg';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _descansoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe el nombre del ejercicio')));
      return;
    }
    final ej = EjercicioRutinaModel(
      nombre: _nombreCtrl.text.trim(),
      musculo: _musculo,
      series: int.tryParse(_seriesCtrl.text) ?? 3,
      repeticiones:
          _repsCtrl.text.trim().isEmpty ? '10' : _repsCtrl.text.trim(),
      descanso: _descansoCtrl.text.trim().isEmpty
          ? '60 seg'
          : _descansoCtrl.text.trim(),
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );
    Navigator.pop(context, ej);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.ejercicio == null ? 'Nuevo ejercicio' : 'Editar ejercicio'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar',
                style: TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(
                ctrl: _nombreCtrl,
                label: 'Nombre del ejercicio',
                icono: Icons.sports_gymnastics),
            const SizedBox(height: 14),
            const SeccionLabel(titulo: 'Músculo trabajado'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kMusculosDisponibles.map((m) {
                final sel = _musculo == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: sel,
                  selectedColor: Colors.orangeAccent,
                  labelStyle: TextStyle(
                      color: sel ? Colors.black : Colors.white70, fontSize: 12),
                  backgroundColor: const Color(0xFF1E293B),
                  onSelected: (_) => setState(() => _musculo = m),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CampoTexto(
                      ctrl: _seriesCtrl,
                      label: 'Series',
                      icono: Icons.repeat,
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoTexto(
                      ctrl: _repsCtrl,
                      label: 'Repeticiones',
                      icono: Icons.format_list_numbered),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CampoTexto(
                ctrl: _descansoCtrl,
                label: 'Descanso (ej: 60 seg, 2 min)',
                icono: Icons.timer_outlined),
            const SizedBox(height: 14),
            CampoTexto(
                ctrl: _notasCtrl,
                label: 'Notas / tips (opcional)',
                icono: Icons.info_outline,
                maxLines: 2),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.check),
                label: const Text('Guardar ejercicio'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CLASES TEMPORALES (para el estado del formulario)
// ═══════════════════════════════════════════════════════════════════════════════

class _DiaTemp {
  String nombreDia;
  List<EjercicioRutinaModel> ejercicios;

  _DiaTemp({required this.nombreDia, required this.ejercicios});
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _Bloque extends StatelessWidget {
  final Widget child;
  const _Bloque({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14)),
      child: child,
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: small ? 0 : 0.8,
        ),
      ),
    );
  }
}
