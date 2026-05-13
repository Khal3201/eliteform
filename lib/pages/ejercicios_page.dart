import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const List<String> kGruposMusculares = [
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
  'Cardio',
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color colorGrupo(String grupo) {
  switch (grupo) {
    case 'Pecho':
      return Colors.redAccent;
    case 'Espalda':
      return Colors.blueAccent;
    case 'Hombros':
      return Colors.purpleAccent;
    case 'Bíceps':
      return Colors.orangeAccent;
    case 'Tríceps':
      return Colors.tealAccent;
    case 'Abdomen':
      return Colors.yellowAccent;
    case 'Glúteos':
      return Colors.pinkAccent;
    case 'Cuádriceps':
      return Colors.greenAccent;
    case 'Femorales':
      return Colors.lightGreenAccent;
    case 'Pantorrillas':
      return Colors.cyanAccent;
    case 'Antebrazo':
      return Colors.amberAccent;
    case 'Full Body':
      return Colors.deepOrangeAccent;
    case 'Cardio':
      return Colors.lightBlueAccent;
    default:
      return Colors.white54;
  }
}

IconData iconoGrupo(String grupo) {
  switch (grupo) {
    case 'Pecho':
      return Icons.fitness_center;
    case 'Espalda':
      return Icons.airline_seat_flat;
    case 'Hombros':
      return Icons.accessibility_new;
    case 'Bíceps':
    case 'Tríceps':
    case 'Antebrazo':
      return Icons.sports_gymnastics;
    case 'Abdomen':
      return Icons.self_improvement;
    case 'Glúteos':
    case 'Cuádriceps':
    case 'Femorales':
    case 'Pantorrillas':
      return Icons.directions_walk;
    case 'Full Body':
      return Icons.person;
    case 'Cardio':
      return Icons.directions_run;
    default:
      return Icons.sports_gymnastics;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MODELO
// ═══════════════════════════════════════════════════════════════════════════════

class EjercicioModel {
  final String id;
  final String nombre;
  final String grupoMuscular;
  final String descripcion;
  final String? urlImagen; // opcional, para futuras versiones
  final String? creadoPor; // 'admin' | uid

  EjercicioModel({
    required this.id,
    required this.nombre,
    required this.grupoMuscular,
    required this.descripcion,
    this.urlImagen,
    this.creadoPor,
  });

  factory EjercicioModel.fromMap(String id, Map<String, dynamic> data) {
    return EjercicioModel(
      id: id,
      nombre: data['nombre'] ?? '',
      grupoMuscular: data['grupo_muscular'] ?? '',
      descripcion: data['descripcion'] ?? '',
      urlImagen: data['url_imagen'],
      creadoPor: data['creado_por'],
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'grupo_muscular': grupoMuscular,
        'descripcion': descripcion,
        if (urlImagen != null) 'url_imagen': urlImagen,
        if (creadoPor != null) 'creado_por': creadoPor,
      };
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
  String? _filtroGrupo;
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _buildStream() {
    if (_filtroGrupo != null) {
      return FirebaseFirestore.instance
          .collection('ejercicios')
          .where('grupo_muscular', isEqualTo: _filtroGrupo)
          .snapshots();
    }
    return FirebaseFirestore.instance.collection('ejercicios').snapshots();
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
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _busqueda = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Chips de filtro por grupo muscular ─────────────────────────
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipFiltro(
                    label: 'Todos',
                    icono: Icons.apps,
                    color: Colors.white54,
                    seleccionado: _filtroGrupo == null,
                    onTap: () => setState(() => _filtroGrupo = null),
                  ),
                  const SizedBox(width: 8),
                  ...kGruposMusculares.map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChipFiltro(
                          label: g,
                          icono: iconoGrupo(g),
                          color: colorGrupo(g),
                          seleccionado: _filtroGrupo == g,
                          onTap: () => setState(
                              () => _filtroGrupo = _filtroGrupo == g ? null : g),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Lista de ejercicios ────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snap.data?.docs ?? [];

                // Filtro por búsqueda
                if (_busqueda.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final nombre =
                        (data['nombre'] ?? '').toString().toLowerCase();
                    final grupo = (data['grupo_muscular'] ?? '')
                        .toString()
                        .toLowerCase();
                    final desc =
                        (data['descripcion'] ?? '').toString().toLowerCase();
                    return nombre.contains(_busqueda) ||
                        grupo.contains(_busqueda) ||
                        desc.contains(_busqueda);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return EmptyState(
                    icono: Icons.sports_gymnastics,
                    mensaje: _busqueda.isNotEmpty
                        ? 'No se encontró "$_busqueda"'
                        : 'No hay ejercicios disponibles',
                    sub: _filtroGrupo != null
                        ? 'No hay ejercicios para "$_filtroGrupo" aún.'
                        : 'El administrador aún no ha publicado ejercicios.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final ejercicio = EjercicioModel.fromMap(
                        docs[i].id,
                        docs[i].data() as Map<String, dynamic>);
                    return _TarjetaEjercicio(ejercicio: ejercicio);
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

// ═══════════════════════════════════════════════════════════════════════════════
// TARJETA DE EJERCICIO
// ═══════════════════════════════════════════════════════════════════════════════

class _TarjetaEjercicio extends StatelessWidget {
  final EjercicioModel ejercicio;
  const _TarjetaEjercicio({required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    final color = colorGrupo(ejercicio.grupoMuscular);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleEjercicioPage(ejercicio: ejercicio),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del grupo muscular
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(iconoGrupo(ejercicio.grupoMuscular),
                    color: color, size: 26),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ejercicio.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        ejercicio.grupoMuscular,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ejercicio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DETALLE DEL EJERCICIO
// ═══════════════════════════════════════════════════════════════════════════════

class DetalleEjercicioPage extends StatelessWidget {
  final EjercicioModel ejercicio;
  const DetalleEjercicioPage({super.key, required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    final color = colorGrupo(ejercicio.grupoMuscular);

    return Scaffold(
      appBar: AppBar(
        title: Text(ejercicio.nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner superior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    const Color(0xFF1E293B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Icon(iconoGrupo(ejercicio.grupoMuscular),
                        color: color, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ejercicio.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      ejercicio.grupoMuscular,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Descripción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: color, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ejercicio.descripcion.isNotEmpty
                        ? ejercicio.descripcion
                        : 'Sin descripción disponible.',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Consejos generales por grupo muscular
            _ConsejosTarjeta(grupo: ejercicio.grupoMuscular, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Consejos por grupo muscular ──────────────────────────────────────────────

class _ConsejosTarjeta extends StatelessWidget {
  final String grupo;
  final Color color;
  const _ConsejosTarjeta({required this.grupo, required this.color});

  static const Map<String, List<String>> _consejos = {
    'Pecho': [
      'Mantén los codos a 45° del cuerpo para proteger los hombros.',
      'Contrae el pecho al subir el peso, no solo los brazos.',
      'Respira: inhala al bajar, exhala al subir.',
    ],
    'Espalda': [
      'Nunca redondees la espalda baja durante el movimiento.',
      'Enfócate en jalar con los codos, no con las manos.',
      'Mantén el pecho erguido durante los jalones.',
    ],
    'Hombros': [
      'No eleves las mancuernas por encima de los hombros en elevaciones laterales.',
      'Evita usar impulso del torso para subir el peso.',
      'Trabaja el rango completo de movimiento con control.',
    ],
    'Bíceps': [
      'No balancees el cuerpo; mantén los codos pegados al torso.',
      'El movimiento negativo (bajar) es tan importante como subir.',
      'Squeeze (aprieta) el bíceps en la parte superior del movimiento.',
    ],
    'Tríceps': [
      'Mantén los codos apuntando hacia el frente, no hacia afuera.',
      'Extiende completamente el codo para activar todo el músculo.',
      'Controla la fase negativa para mayor hipertrofia.',
    ],
    'Abdomen': [
      'La respiración es clave: exhala al contraer, inhala al regresar.',
      'No jalones del cuello en los crunches; lleva el movimiento desde el abdomen.',
      'La consistencia y la dieta son más importantes que el volumen de series.',
    ],
    'Cuádriceps': [
      'En sentadillas, las rodillas no deben sobrepasar la punta de los pies.',
      'Mantén el peso en los talones para mayor activación del cuádriceps.',
      'Profundidad completa = mayor activación muscular.',
    ],
    'Femorales': [
      'El peso muerto rumano activa fuertemente los femorales.',
      'Mantén la espalda neutra durante todos los movimientos de bisagra.',
      'Estira bien los femorales antes y después del entrenamiento.',
    ],
    'Glúteos': [
      'Aprieta el glúteo en la parte superior del movimiento.',
      'El hip thrust es uno de los ejercicios más efectivos para glúteos.',
      'Trabaja el rango completo de movimiento sin compensar con la espalda.',
    ],
    'Cardio': [
      'La zona de frecuencia cardíaca del 60–70% es ideal para quemar grasa.',
      'Varía entre cardio de baja intensidad y HIIT para mejores resultados.',
      'El descanso y la recuperación son parte del entrenamiento cardiovascular.',
    ],
    'Full Body': [
      'Los ejercicios compuestos (sentadilla, peso muerto, press) activan más músculos.',
      'Asegura una buena técnica antes de añadir más peso.',
      'El descanso entre sesiones full body es esencial: mínimo 48 horas.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final lista = _consejos[grupo] ??
        [
          'Aprende la técnica correcta antes de incrementar el peso.',
          'La consistencia supera a la intensidad ocasional.',
          'Descansa adecuadamente para maximizar la recuperación muscular.',
        ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                'Consejos para $grupo',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...lista.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 8),
                      child: Icon(Icons.circle, color: color, size: 5),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN — CATÁLOGO DE EJERCICIOS
// ═══════════════════════════════════════════════════════════════════════════════

class AdminEjerciciosPage extends StatelessWidget {
  const AdminEjerciciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Ejercicios')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('ejercicios').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icono: Icons.sports_gymnastics,
              mensaje: 'No hay ejercicios en el catálogo',
              sub: 'Crea el primero con el botón +',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final ej = EjercicioModel.fromMap(
                  docs[i].id, docs[i].data() as Map<String, dynamic>);
              return _AdminEjercicioCard(ejercicio: ej);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrearEditarEjercicioPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo ejercicio'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

class _AdminEjercicioCard extends StatelessWidget {
  final EjercicioModel ejercicio;
  const _AdminEjercicioCard({required this.ejercicio});

  Future<void> _eliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar ejercicio',
                style: TextStyle(color: Colors.white)),
            content: Text('¿Eliminar "${ejercicio.nombre}"?',
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
          .collection('ejercicios')
          .doc(ejercicio.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorGrupo(ejercicio.grupoMuscular);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child:
                  Icon(iconoGrupo(ejercicio.grupoMuscular), color: color, size: 20),
            ),
            title: Text(ejercicio.nombre,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(ejercicio.grupoMuscular,
                    style: TextStyle(color: color, fontSize: 12)),
                Text(
                  ejercicio.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetalleEjercicioPage(ejercicio: ejercicio)),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CrearEditarEjercicioPage(ejercicio: ejercicio)),
                  ),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.amberAccent),
                  label: const Text('Editar',
                      style: TextStyle(color: Colors.amberAccent)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _eliminar(context),
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
// CREAR / EDITAR EJERCICIO
// ═══════════════════════════════════════════════════════════════════════════════

class CrearEditarEjercicioPage extends StatefulWidget {
  final EjercicioModel? ejercicio; // null = crear nuevo
  const CrearEditarEjercicioPage({super.key, this.ejercicio});

  @override
  State<CrearEditarEjercicioPage> createState() =>
      _CrearEditarEjercicioPageState();
}

class _CrearEditarEjercicioPageState extends State<CrearEditarEjercicioPage> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  late String _grupoSeleccionado;
  bool _guardando = false;

  bool get _esEdicion => widget.ejercicio != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl =
        TextEditingController(text: widget.ejercicio?.nombre ?? '');
    _descCtrl =
        TextEditingController(text: widget.ejercicio?.descripcion ?? '');
    _grupoSeleccionado =
        widget.ejercicio?.grupoMuscular ?? kGruposMusculares.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para el ejercicio')));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega una descripción del ejercicio')));
      return;
    }

    setState(() => _guardando = true);

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'grupo_muscular': _grupoSeleccionado,
      'descripcion': _descCtrl.text.trim(),
      'creado_por': 'admin',
    };

    try {
      if (_esEdicion) {
        await FirebaseFirestore.instance
            .collection('ejercicios')
            .doc(widget.ejercicio!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('ejercicios').add(data);
      }

      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _esEdicion ? 'Ejercicio actualizado' : 'Ejercicio creado'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar ejercicio' : 'Nuevo ejercicio'),
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
            // Nombre
            CampoTexto(
              ctrl: _nombreCtrl,
              label: 'Nombre del ejercicio',
              icono: Icons.sports_gymnastics,
            ),
            const SizedBox(height: 16),

            // Grupo muscular
            const SeccionLabel(titulo: 'Grupo muscular'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kGruposMusculares.map((g) {
                final sel = _grupoSeleccionado == g;
                final color = colorGrupo(g);
                return GestureDetector(
                  onTap: () => setState(() => _grupoSeleccionado = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? color.withOpacity(0.2)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: sel ? color : Colors.white12,
                          width: sel ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconoGrupo(g),
                            color: sel ? color : Colors.white38, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          g,
                          style: TextStyle(
                            color: sel ? color : Colors.white54,
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Descripción
            const SeccionLabel(titulo: 'Descripción / Instrucciones'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Describe la técnica correcta, músculos trabajados, variaciones posibles...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.notes),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 30),

            // Preview del color/icono seleccionado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorGrupo(_grupoSeleccionado).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorGrupo(_grupoSeleccionado).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(iconoGrupo(_grupoSeleccionado),
                      color: colorGrupo(_grupoSeleccionado), size: 28),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombreCtrl.text.isEmpty
                            ? 'Nombre del ejercicio'
                            : _nombreCtrl.text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Text(
                        _grupoSeleccionado,
                        style: TextStyle(
                            color: colorGrupo(_grupoSeleccionado),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
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
                    : _esEdicion
                        ? 'Guardar cambios'
                        : 'Crear ejercicio'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
