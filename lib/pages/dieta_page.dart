import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const List<String> kObjetivosDieta = [
  'Pérdida de peso',
  'Volumen',
  'Mantenimiento',
  'Definición',
];

const List<String> kNivelesDieta = [
  'Básica',
  'Intermedia',
  'Estricta',
];

const List<String> kPreferenciasDieta = [
  'Sin restricciones',
  'Vegetariana',
  'Vegana',
  'Sin gluten',
  'Sin lactosa',
  'Alta en proteínas',
  'Baja en carbohidratos',
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color colorObjetivoDieta(String obj) {
  switch (obj) {
    case 'Pérdida de peso':
      return Colors.blueAccent;
    case 'Volumen':
      return Colors.orangeAccent;
    case 'Mantenimiento':
      return Colors.greenAccent;
    case 'Definición':
      return Colors.purpleAccent;
    default:
      return Colors.white54;
  }
}

IconData iconoObjetivoDieta(String obj) {
  switch (obj) {
    case 'Pérdida de peso':
      return Icons.trending_down;
    case 'Volumen':
      return Icons.trending_up;
    case 'Mantenimiento':
      return Icons.balance;
    case 'Definición':
      return Icons.auto_awesome;
    default:
      return Icons.restaurant;
  }
}

IconData iconoPreferencia(String p) {
  switch (p) {
    case 'Vegetariana':
      return Icons.eco;
    case 'Vegana':
      return Icons.grass;
    case 'Sin gluten':
      return Icons.no_food;
    case 'Alta en proteínas':
      return Icons.egg_alt;
    default:
      return Icons.restaurant_menu;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PÁGINA PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════════

class DietaPage extends StatelessWidget {
  const DietaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DietaModel?>(
      stream: FirestoreService().streamDietaActiva(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dietaActiva = snapshot.data;
        if (dietaActiva != null) {
          return _DietaActivaView(dieta: dietaActiva, uid: user.uid);
        }
        return _RecomendadasDietaTab(uid: user.uid);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VISTA: DIETA ACTIVA
// ═══════════════════════════════════════════════════════════════════════════════

class _DietaActivaView extends StatelessWidget {
  final DietaModel dieta;
  final String uid;
  const _DietaActivaView({required this.dieta, required this.uid});

  Future<void> _abandonar(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Abandonar dieta',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                '¿Seguro que quieres abandonar este plan? Podrás elegir otro cuando quieras.',
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
    await FirestoreService().abandonarDieta(uid);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoDieta(dieta.objetivo);
    final tabCount = dieta.comidas.isEmpty ? 1 : dieta.comidas.length + 1;

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
                    // Tarjeta principal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            const Color(0xFF1E293B)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: color.withOpacity(0.5), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _PillTag(label: 'DIETA ACTIVA', color: color),
                              const Spacer(),
                              _PillTag(
                                  label: dieta.nivel,
                                  color: Colors.white38,
                                  small: true),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(dieta.nombre,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(dieta.descripcion,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                StatDieta(
                                    valor: '${dieta.calorias}',
                                    label: 'kcal/día',
                                    color: color),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white12),
                                StatDieta(
                                    valor:
                                        '${(dieta.calorias * 0.30 / 4).round()}g',
                                    label: 'Proteínas',
                                    color: Colors.redAccent),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white12),
                                StatDieta(
                                    valor:
                                        '${(dieta.calorias * 0.45 / 4).round()}g',
                                    label: 'Carbs',
                                    color: Colors.amberAccent),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: dieta.preferenciasCompatibles
                                .map((p) => ChipPref(label: p, color: color))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _abandonar(context),
                        icon: const Icon(Icons.exit_to_app,
                            color: Colors.redAccent, size: 18),
                        label: const Text('Abandonar dieta',
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
            if (dieta.comidas.isNotEmpty)
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
                      ...dieta.comidas.map((c) => Tab(text: c.momento)),
                    ],
                  ),
                ),
              ),
          ],
          body: dieta.comidas.isEmpty
              ? const Center(
                  child: Text('Esta dieta no tiene comidas definidas.',
                      style: TextStyle(color: Colors.white38)))
              : TabBarView(
                  children: [
                    ResumenDietaView(dieta: dieta, color: color),
                    ...dieta.comidas.map((c) => _ComidaView(comida: c)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CATÁLOGO CON FILTROS
// ═══════════════════════════════════════════════════════════════════════════════

class _RecomendadasDietaTab extends StatefulWidget {
  final String uid;
  const _RecomendadasDietaTab({required this.uid});

  @override
  State<_RecomendadasDietaTab> createState() => _RecomendadasDietaTabState();
}

class _RecomendadasDietaTabState extends State<_RecomendadasDietaTab> {
  String? _objetivoFiltro;
  String? _prefFiltro;

  Stream<QuerySnapshot> _buildStream() {
    if (_objetivoFiltro != null) {
      return FirestoreService().getDietasAdminPorObjetivo(_objetivoFiltro!);
    }
    return FirestoreService().getDietasAdmin();
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
          _FiltrosDieta(
            objetivoSeleccionado: _objetivoFiltro,
            prefSeleccionada: _prefFiltro,
            onObjetivo: (v) => setState(() => _objetivoFiltro = v),
            onPref: (v) => setState(() => _prefFiltro = v),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snap.data?.docs ?? [];

                if (_prefFiltro != null) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final prefs = List<String>.from(
                        data['preferencias_compatibles'] ?? []);
                    return prefs.contains(_prefFiltro);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const EmptyState(
                    icono: Icons.search_off,
                    mensaje: 'No hay dietas disponibles',
                    sub:
                        'Prueba con otros filtros o espera a que el administrador publique planes.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final dieta = DietaModel.fromMap(
                        docs[i].id, docs[i].data() as Map<String, dynamic>);
                    return TarjetaDieta(dieta: dieta, uid: widget.uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltrosDieta extends StatelessWidget {
  final String? objetivoSeleccionado;
  final String? prefSeleccionada;
  final ValueChanged<String?> onObjetivo;
  final ValueChanged<String?> onPref;

  const _FiltrosDieta({
    required this.objetivoSeleccionado,
    required this.prefSeleccionada,
    required this.onObjetivo,
    required this.onPref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Objetivo',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChipFiltro(
                  label: 'Todos',
                  icono: Icons.apps,
                  color: Colors.white54,
                  seleccionado: objetivoSeleccionado == null,
                  onTap: () => onObjetivo(null),
                ),
                const SizedBox(width: 8),
                ...kObjetivosDieta.map((obj) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChipFiltro(
                        label: obj,
                        icono: iconoObjetivoDieta(obj),
                        color: colorObjetivoDieta(obj),
                        seleccionado: objetivoSeleccionado == obj,
                        onTap: () => onObjetivo(
                            objetivoSeleccionado == obj ? null : obj),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Preferencia',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChipFiltro(
                  label: 'Cualquiera',
                  icono: Icons.restaurant,
                  color: Colors.white54,
                  seleccionado: prefSeleccionada == null,
                  onTap: () => onPref(null),
                ),
                const SizedBox(width: 8),
                ...kPreferenciasDieta.map((p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChipFiltro(
                        label: p,
                        icono: iconoPreferencia(p),
                        color: Colors.greenAccent,
                        seleccionado: prefSeleccionada == p,
                        onTap: () => onPref(prefSeleccionada == p ? null : p),
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
// TARJETA DE DIETA
// ═══════════════════════════════════════════════════════════════════════════════

class TarjetaDieta extends StatelessWidget {
  final DietaModel dieta;
  final String uid;
  const TarjetaDieta({super.key, required this.dieta, required this.uid});

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoDieta(dieta.objetivo);
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
                    _PillTag(label: dieta.objetivo, color: color),
                    const Spacer(),
                    Text('${dieta.calorias} kcal',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(dieta.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                const SizedBox(height: 4),
                Text(dieta.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: dieta.preferenciasCompatibles
                      .map((p) => ChipPref(label: p, color: color))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text('${dieta.comidas.length} comidas',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 14),
                    const Icon(Icons.bar_chart,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(dieta.nivel,
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
                              DetalleDietaPage(dieta: dieta, uid: uid))),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver detalle'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await FirestoreService().activarDieta(uid, dieta.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('¡Dieta activada!'),
                          backgroundColor: Colors.greenAccent));
                    }
                  },
                  child: const Text('Seguir esta dieta'),
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
// DETALLE DE DIETA
// ═══════════════════════════════════════════════════════════════════════════════

class DetalleDietaPage extends StatelessWidget {
  final DietaModel dieta;
  final String uid;
  const DetalleDietaPage({super.key, required this.dieta, required this.uid});

  @override
  Widget build(BuildContext context) {
    final color = colorObjetivoDieta(dieta.objetivo);
    return DefaultTabController(
      length: dieta.comidas.isEmpty ? 1 : dieta.comidas.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(dieta.nombre),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: color,
            labelColor: color,
            unselectedLabelColor: Colors.white38,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'Resumen'),
              ...dieta.comidas.map((c) => Tab(text: c.momento)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ResumenDietaView(dieta: dieta, color: color),
            ...dieta.comidas.map((c) => _ComidaView(comida: c)),
          ],
        ),
        bottomNavigationBar: uid != 'admin'
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirestoreService().activarDieta(uid, dieta.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Seguir esta dieta'),
                ),
              )
            : null,
      ),
    );
  }
}

class ResumenDietaView extends StatelessWidget {
  final DietaModel dieta;
  final Color color;
  const ResumenDietaView({super.key, required this.dieta, required this.color});

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
                  dieta.descripcion.isNotEmpty
                      ? dieta.descripcion
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
              const Text('Distribución calórica estimada',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 14),
              MacroBar(
                  label: 'Proteínas (30%)',
                  gramos: (dieta.calorias * 0.30 / 4).round(),
                  color: Colors.redAccent,
                  porcentaje: 0.30),
              const SizedBox(height: 10),
              MacroBar(
                  label: 'Carbohidratos (45%)',
                  gramos: (dieta.calorias * 0.45 / 4).round(),
                  color: Colors.amberAccent,
                  porcentaje: 0.45),
              const SizedBox(height: 10),
              MacroBar(
                  label: 'Grasas (25%)',
                  gramos: (dieta.calorias * 0.25 / 9).round(),
                  color: Colors.blueAccent,
                  porcentaje: 0.25),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Bloque(
          child: Column(
            children: [
              InfoFila(
                  icono: Icons.local_fire_department,
                  label: 'Calorías totales',
                  valor: '${dieta.calorias} kcal'),
              const Divider(color: Colors.white12, height: 20),
              InfoFila(
                  icono: Icons.bar_chart, label: 'Nivel', valor: dieta.nivel),
              const Divider(color: Colors.white12, height: 20),
              InfoFila(
                  icono: Icons.restaurant,
                  label: 'Comidas definidas',
                  valor: '${dieta.comidas.length}'),
            ],
          ),
        ),
        if (dieta.preferenciasCompatibles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Bloque(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compatible con',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: dieta.preferenciasCompatibles
                      .map((p) => ChipPref(label: p, color: color))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ComidaView extends StatelessWidget {
  final ComidaDiaModel comida;
  const _ComidaView({required this.comida});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Bloque(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant_menu,
                        color: Colors.greenAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comida.momento,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      Text('~${comida.caloriasAprox} kcal',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(comida.descripcion,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.5)),
              const SizedBox(height: 14),
              const Text('Alimentos incluidos',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 10),
              ...comida.alimentos.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(a,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CREAR DIETA — manual + JSON
// ═══════════════════════════════════════════════════════════════════════════════

class CrearDietaPage extends StatefulWidget {
  final String uid;
  final bool esAdmin;
  const CrearDietaPage({super.key, required this.uid, required this.esAdmin});

  @override
  State<CrearDietaPage> createState() => _CrearDietaPageState();
}

class _CrearDietaPageState extends State<CrearDietaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  String _objetivo = kObjetivosDieta.first;
  String _nivel = kNivelesDieta.first;
  final List<String> _preferencias = [];
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
    _calCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarManual() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para la dieta')));
      return;
    }
    setState(() => _guardando = true);
    final dieta = DietaModel(
      id: '',
      nombre: _nombreCtrl.text.trim(),
      calorias: int.tryParse(_calCtrl.text) ?? 2000,
      descripcion: _descCtrl.text.trim(),
      objetivo: _objetivo,
      preferenciasCompatibles: _preferencias,
      nivel: _nivel,
      creadoPor: widget.esAdmin ? 'admin' : widget.uid,
      comidas: [],
    );
    await FirestoreService().crearDieta(dieta);
    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _importarJson() async {
    setState(() => _errorJson = null);
    try {
      final json = await leerArchivoJson(); // usa bytes, no File

      if (json['nombre'] == null || json['objetivo'] == null) {
        setState(() => _errorJson =
            'El JSON debe incluir los campos "nombre" y "objetivo".');
        return;
      }

      setState(() => _guardando = true);

      final dieta = DietaModel.fromMap('', {
        ...json,
        'creado_por': widget.esAdmin ? 'admin' : widget.uid,
      });

      await FirestoreService().crearDieta(dieta);
      setState(() => _guardando = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✓ Dieta importada correctamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Dieta'),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampoTexto(
                    ctrl: _nombreCtrl,
                    label: 'Nombre de la dieta',
                    icono: Icons.restaurant_menu),
                const SizedBox(height: 14),
                CampoTexto(
                    ctrl: _descCtrl,
                    label: 'Descripción',
                    icono: Icons.notes,
                    maxLines: 2),
                const SizedBox(height: 14),
                CampoTexto(
                    ctrl: _calCtrl,
                    label: 'Calorías diarias (kcal)',
                    icono: Icons.local_fire_department,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                const SeccionLabel(titulo: 'Objetivo'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kObjetivosDieta.map((obj) {
                    final sel = _objetivo == obj;
                    return ChoiceChip(
                      label: Text(obj),
                      selected: sel,
                      selectedColor: Colors.orangeAccent,
                      labelStyle: TextStyle(
                          color: sel ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (_) => setState(() => _objetivo = obj),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const SeccionLabel(titulo: 'Nivel'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: kNivelesDieta.map((n) {
                    final sel = _nivel == n;
                    return ChoiceChip(
                      label: Text(n),
                      selected: sel,
                      selectedColor: Colors.orangeAccent,
                      labelStyle:
                          TextStyle(color: sel ? Colors.black : Colors.white70),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (_) => setState(() => _nivel = n),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const SeccionLabel(
                    titulo: 'Preferencias alimentarias compatibles'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kPreferenciasDieta.map((p) {
                    final sel = _preferencias.contains(p);
                    return FilterChip(
                      label: Text(p),
                      selected: sel,
                      selectedColor: Colors.greenAccent.withOpacity(0.2),
                      checkmarkColor: Colors.greenAccent,
                      labelStyle: TextStyle(
                          color: sel ? Colors.greenAccent : Colors.white54,
                          fontSize: 12),
                      backgroundColor: const Color(0xFF1E293B),
                      side: BorderSide(
                          color: sel ? Colors.greenAccent : Colors.white12),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _preferencias.add(p);
                        } else {
                          _preferencias.remove(p);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarManual,
                    icon: _guardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.save),
                    label: Text(_guardando ? 'Guardando...' : 'Guardar dieta'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          JsonImportTab(
            tipo: 'dieta',
            onImportar: _importarJson,
            cargando: _guardando,
            error: _errorJson,
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares internos ──────────────────────────────────────────────

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
