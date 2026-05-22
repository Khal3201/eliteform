// ── AÑADIR AL FINAL DE admin_contenido_page.dart ─────────────────────────────
// Pega este bloque completo después del último widget en admin_contenido_page.dart

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN: EJERCICIOS
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ejercicio_model.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

class AdminEjerciciosPage extends StatelessWidget {
  const AdminEjerciciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejercicios del sistema')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getEjerciciosAdmin(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icono: Icons.sports_gymnastics,
              mensaje: 'No hay ejercicios publicados',
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
            MaterialPageRoute(
                builder: (_) => const CrearEjercicioPage(esAdmin: true))),
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

  Color get _color {
    switch (ejercicio.categoria) {
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

  IconData get _icono {
    switch (ejercicio.categoria) {
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
    if (ok) await FirestoreService().eliminarEjercicio(ejercicio.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _color.withOpacity(0.15),
              child: Icon(_icono, color: _color, size: 20),
            ),
            title: Text(ejercicio.nombre,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                    '${ejercicio.categoria} · ${ejercicio.musculo} · ${ejercicio.nivel}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                if (ejercicio.equipamiento.isNotEmpty)
                  Text(ejercicio.equipamiento.join(', '),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EditarEjercicioPage(ejercicio: ejercicio))),
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

// ══════════════════════════════════════════════════════════════════════════
// CREAR EJERCICIO — manual + JSON
// ══════════════════════════════════════════════════════════════════════════

class CrearEjercicioPage extends StatefulWidget {
  final bool esAdmin;
  const CrearEjercicioPage({super.key, required this.esAdmin});

  @override
  State<CrearEjercicioPage> createState() => _CrearEjercicioPageState();
}

class _CrearEjercicioPageState extends State<CrearEjercicioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _instrCtrl = TextEditingController();
  String _musculo = kMusculosEjercicioAdmin.first;
  String _categoria = kCategoriasEjercicioAdmin.first;
  String _nivel = kNivelesEjercicioAdmin.first;
  final List<String> _equipamiento = [];
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
    _instrCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarManual() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para el ejercicio')));
      return;
    }
    setState(() => _guardando = true);
    final ej = EjercicioModel(
      id: '',
      nombre: _nombreCtrl.text.trim(),
      musculo: _musculo,
      categoria: _categoria,
      nivel: _nivel,
      descripcion: _descCtrl.text.trim(),
      instrucciones: _instrCtrl.text.trim().isEmpty
          ? null
          : _instrCtrl.text.trim(),
      equipamiento: List<String>.from(_equipamiento),
      creadoPor: 'admin',
    );
    await FirestoreService().crearEjercicio(ej);
    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _importarJson() async {
    setState(() => _errorJson = null);
    try {
      final json = await leerArchivoJson();
      if (json['nombre'] == null || json['musculo'] == null) {
        setState(() =>
            _errorJson = 'El JSON debe incluir "nombre" y "musculo".');
        return;
      }
      setState(() => _guardando = true);
      final ej = EjercicioModel.fromMap('', {
        ...json,
        'creado_por': 'admin',
      });
      await FirestoreService().crearEjercicio(ej);
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✓ Ejercicio importado correctamente'),
              backgroundColor: Colors.greenAccent),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (e.toString().contains('__cancelado__')) return;
      setState(() {
        _guardando = false;
        _errorJson =
            'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Ejercicio'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.edit, size: 16), text: 'Manual'),
            Tab(
                icon: Icon(Icons.upload_file, size: 16),
                text: 'Desde JSON'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _FormManualEjercicio(
            nombreCtrl: _nombreCtrl,
            descCtrl: _descCtrl,
            instrCtrl: _instrCtrl,
            musculo: _musculo,
            categoria: _categoria,
            nivel: _nivel,
            equipamiento: _equipamiento,
            guardando: _guardando,
            onMusculo: (v) => setState(() => _musculo = v),
            onCategoria: (v) => setState(() => _categoria = v),
            onNivel: (v) => setState(() => _nivel = v),
            onEquipamiento: (e, v) => setState(() {
              if (v)
                _equipamiento.add(e);
              else
                _equipamiento.remove(e);
            }),
            onGuardar: _guardarManual,
          ),
          _JsonImportEjercicioTab(
            onImportar: _importarJson,
            cargando: _guardando,
            error: _errorJson,
          ),
        ],
      ),
    );
  }
}

// ── Formulario manual ejercicio ───────────────────────────────────────────────

const List<String> kMusculosEjercicioAdmin = [
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

const List<String> kCategoriasEjercicioAdmin = [
  'Fuerza',
  'Cardio',
  'Flexibilidad',
  'Resistencia',
];

const List<String> kNivelesEjercicioAdmin = [
  'Principiante',
  'Intermedio',
  'Avanzado',
];

const List<String> kEquipamientoDisponible = [
  'Barra',
  'Mancuernas',
  'Máquina de polea',
  'Máquina de prensa',
  'Banco',
  'Rack',
  'Paralelas',
  'Barra de dominadas',
  'Cuerda para saltar',
  'Rueda abdominal',
  'Tapete de yoga',
  'Bandas elásticas',
  'Kettlebell',
  'TRX',
];

class _FormManualEjercicio extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController descCtrl;
  final TextEditingController instrCtrl;
  final String musculo;
  final String categoria;
  final String nivel;
  final List<String> equipamiento;
  final bool guardando;
  final ValueChanged<String> onMusculo;
  final ValueChanged<String> onCategoria;
  final ValueChanged<String> onNivel;
  final void Function(String e, bool v) onEquipamiento;
  final VoidCallback onGuardar;

  const _FormManualEjercicio({
    required this.nombreCtrl,
    required this.descCtrl,
    required this.instrCtrl,
    required this.musculo,
    required this.categoria,
    required this.nivel,
    required this.equipamiento,
    required this.guardando,
    required this.onMusculo,
    required this.onCategoria,
    required this.onNivel,
    required this.onEquipamiento,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoTexto(
              ctrl: nombreCtrl,
              label: 'Nombre del ejercicio',
              icono: Icons.sports_gymnastics),
          const SizedBox(height: 14),
          CampoTexto(
              ctrl: descCtrl,
              label: 'Descripción',
              icono: Icons.notes,
              maxLines: 2),
          const SizedBox(height: 14),
          CampoTexto(
              ctrl: instrCtrl,
              label: 'Instrucciones paso a paso (opcional)',
              icono: Icons.list_alt,
              maxLines: 4),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Músculo principal'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMusculosEjercicioAdmin.map((m) {
              final sel = musculo == m;
              return ChoiceChip(
                label: Text(m),
                selected: sel,
                selectedColor: Colors.blueAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => onMusculo(m),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Categoría'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: kCategoriasEjercicioAdmin.map((c) {
              final sel = categoria == c;
              return ChoiceChip(
                label: Text(c),
                selected: sel,
                selectedColor: Colors.orangeAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.black : Colors.white70),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => onCategoria(c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Nivel'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: kNivelesEjercicioAdmin.map((n) {
              final sel = nivel == n;
              return ChoiceChip(
                label: Text(n),
                selected: sel,
                selectedColor: Colors.greenAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.black : Colors.white70),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => onNivel(n),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const SeccionLabel(titulo: 'Equipamiento necesario'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kEquipamientoDisponible.map((e) {
              final sel = equipamiento.contains(e);
              return FilterChip(
                label: Text(e),
                selected: sel,
                selectedColor: Colors.white12,
                checkmarkColor: Colors.orangeAccent,
                labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.white54,
                    fontSize: 12),
                backgroundColor: const Color(0xFF1E293B),
                side: BorderSide(
                    color: sel ? Colors.orangeAccent : Colors.white12),
                onSelected: (v) => onEquipamiento(e, v),
              );
            }).toList(),
          ),
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
              label: Text(guardando ? 'Guardando...' : 'Guardar ejercicio'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── JSON Import Tab para ejercicios ──────────────────────────────────────────

const String _kJsonEjemploEjercicio = r'''
{
  "nombre": "Press de Banca Inclinado",
  "musculo": "Pecho",
  "categoria": "Fuerza",
  "nivel": "Intermedio",
  "descripcion": "Variante del press de banca que enfatiza la parte superior del pecho.",
  "instrucciones": "Ajusta el banco a 30-45°. Agarra la barra con agarre prono. Baja hasta el pecho superior y empuja hacia arriba.",
  "equipamiento": ["Barra", "Banco"]
}''';

class _JsonImportEjercicioTab extends StatelessWidget {
  final VoidCallback onImportar;
  final bool cargando;
  final String? error;

  const _JsonImportEjercicioTab({
    required this.onImportar,
    required this.cargando,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selecciona un archivo .json con la estructura del ejercicio.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Estructura requerida:',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              _kJsonEjemploEjercicio,
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(error!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12))),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cargando ? null : onImportar,
              icon: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.upload_file),
              label: Text(
                  cargando ? 'Importando...' : 'Seleccionar archivo JSON'),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EDITAR EJERCICIO
// ══════════════════════════════════════════════════════════════════════════

class EditarEjercicioPage extends StatefulWidget {
  final EjercicioModel ejercicio;
  const EditarEjercicioPage({super.key, required this.ejercicio});

  @override
  State<EditarEjercicioPage> createState() => _EditarEjercicioPageState();
}

class _EditarEjercicioPageState extends State<EditarEjercicioPage> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _instrCtrl;
  late String _musculo;
  late String _categoria;
  late String _nivel;
  late List<String> _equipamiento;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final e = widget.ejercicio;
    _nombreCtrl = TextEditingController(text: e.nombre);
    _descCtrl = TextEditingController(text: e.descripcion);
    _instrCtrl = TextEditingController(text: e.instrucciones ?? '');
    _musculo = e.musculo;
    _categoria = e.categoria;
    _nivel = e.nivel;
    _equipamiento = List<String>.from(e.equipamiento);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para el ejercicio')));
      return;
    }
    setState(() => _guardando = true);
    final data = EjercicioModel(
      id: widget.ejercicio.id,
      nombre: _nombreCtrl.text.trim(),
      musculo: _musculo,
      categoria: _categoria,
      nivel: _nivel,
      descripcion: _descCtrl.text.trim(),
      instrucciones: _instrCtrl.text.trim().isEmpty
          ? null
          : _instrCtrl.text.trim(),
      equipamiento: _equipamiento,
      creadoPor: widget.ejercicio.creadoPor,
    );
    await FirestoreService()
        .actualizarEjercicio(widget.ejercicio.id, data.toMap());
    setState(() => _guardando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ejercicio actualizado'),
            backgroundColor: Colors.greenAccent),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ejercicio'),
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
      body: _FormManualEjercicio(
        nombreCtrl: _nombreCtrl,
        descCtrl: _descCtrl,
        instrCtrl: _instrCtrl,
        musculo: _musculo,
        categoria: _categoria,
        nivel: _nivel,
        equipamiento: _equipamiento,
        guardando: _guardando,
        onMusculo: (v) => setState(() => _musculo = v),
        onCategoria: (v) => setState(() => _categoria = v),
        onNivel: (v) => setState(() => _nivel = v),
        onEquipamiento: (e, v) => setState(() {
          if (v)
            _equipamiento.add(e);
          else
            _equipamiento.remove(e);
        }),
        onGuardar: _guardar,
      ),
    );
  }
}
