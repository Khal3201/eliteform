import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';
import 'rutina_page.dart' show DetalleRutinaPage, CrearRutinaPage;
import 'dieta_page.dart' show DetalleDietaPage, CrearDietaPage;

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN: RUTINAS
// ═══════════════════════════════════════════════════════════════════════════════

class AdminRutinasPage extends StatelessWidget {
  const AdminRutinasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas del sistema')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getRutinasAdmin(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icono: Icons.fitness_center,
              mensaje: 'No hay rutinas publicadas',
              sub: 'Crea la primera rutina con el botón +',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final rutina = RutinaModel.fromMap(
                  docs[i].id, docs[i].data() as Map<String, dynamic>);
              return _AdminRutinaCard(rutina: rutina);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const CrearRutinaPage(uid: 'admin', esAdmin: true))),
        icon: const Icon(Icons.add),
        label: const Text('Nueva rutina'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

class _AdminRutinaCard extends StatelessWidget {
  final RutinaModel rutina;
  const _AdminRutinaCard({required this.rutina});

  Color get _color {
    switch (rutina.objetivo) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.15),
          child: Icon(Icons.fitness_center, color: _color, size: 20),
        ),
        title: Text(rutina.nombreRutina,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${rutina.objetivo} · ${rutina.nivel}',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(
                '${rutina.diasPorSemana} días/sem · '
                '${rutina.dias.length} días definidos',
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined,
                  color: Colors.white54, size: 20),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          DetalleRutinaPage(rutina: rutina, uid: 'admin'))),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () async {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E293B),
                        title: const Text('Eliminar rutina',
                            style: TextStyle(color: Colors.white)),
                        content: Text('¿Eliminar "${rutina.nombreRutina}"?',
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
                  await FirestoreService().eliminarRutina(rutina.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL ADMIN: DIETAS
// ═══════════════════════════════════════════════════════════════════════════════

class AdminDietasPage extends StatelessWidget {
  const AdminDietasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dietas del sistema')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getDietasAdmin(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icono: Icons.restaurant_menu,
              mensaje: 'No hay dietas publicadas',
              sub: 'Crea la primera dieta con el botón +',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final dieta = DietaModel.fromMap(
                  docs[i].id, docs[i].data() as Map<String, dynamic>);
              return _AdminDietaCard(dieta: dieta);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const CrearDietaPage(uid: 'admin', esAdmin: true))),
        icon: const Icon(Icons.add),
        label: const Text('Nueva dieta'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

class _AdminDietaCard extends StatelessWidget {
  final DietaModel dieta;
  const _AdminDietaCard({required this.dieta});

  Color get _color {
    switch (dieta.objetivo) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.15),
          child: Icon(Icons.restaurant, color: _color, size: 20),
        ),
        title: Text(dieta.nombre,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${dieta.objetivo} · ${dieta.nivel}',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text('${dieta.calorias} kcal · ${dieta.comidas.length} comidas',
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined,
                  color: Colors.white54, size: 20),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          DetalleDietaPage(dieta: dieta, uid: 'admin'))),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () async {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E293B),
                        title: const Text('Eliminar dieta',
                            style: TextStyle(color: Colors.white)),
                        content: Text('¿Eliminar "${dieta.nombre}"?',
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
                  await FirestoreService().eliminarDieta(dieta.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
