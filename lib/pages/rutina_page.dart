import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class RutinaPage extends StatelessWidget {
  const RutinaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final firestoreService = FirestoreService();

    return StreamBuilder<RutinaModel?>(
      stream: firestoreService.streamRutinaDeUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rutina = snapshot.data;

        if (rutina == null) {
          return _SinRutina(uid: user.uid, firestoreService: firestoreService);
        }

        return _VistaRutina(
          rutina: rutina,
          uid: user.uid,
          firestoreService: firestoreService,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sin rutina asignada
// ─────────────────────────────────────────────────────────────────────────────

class _SinRutina extends StatelessWidget {
  final String uid;
  final FirestoreService firestoreService;

  const _SinRutina({required this.uid, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: Colors.orangeAccent, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aún no tienes una rutina',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El administrador puede asignarte una rutina personalizada según tus objetivos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Muestra rutinas disponibles en el sistema
          const _CatalogoRutinas(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vista con rutina asignada
// ─────────────────────────────────────────────────────────────────────────────

class _VistaRutina extends StatelessWidget {
  final RutinaModel rutina;
  final String uid;
  final FirestoreService firestoreService;

  const _VistaRutina({
    required this.rutina,
    required this.uid,
    required this.firestoreService,
  });

  Color _colorObjetivo(String objetivo) {
    switch (objetivo.toLowerCase()) {
      case 'fuerza':
        return Colors.redAccent;
      case 'volumen':
        return Colors.blueAccent;
      case 'resistencia':
        return Colors.greenAccent;
      case 'definición':
        return Colors.orangeAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  IconData _iconoObjetivo(String objetivo) {
    switch (objetivo.toLowerCase()) {
      case 'fuerza':
        return Icons.bolt;
      case 'volumen':
        return Icons.fitness_center;
      case 'resistencia':
        return Icons.directions_run;
      case 'definición':
        return Icons.auto_awesome;
      default:
        return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color colorObj = _colorObjetivo(rutina.objetivo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta principal de la rutina
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorObj.withOpacity(0.3), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorObj.withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorObj.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: colorObj.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(_iconoObjetivo(rutina.objetivo),
                              color: colorObj, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            rutina.objetivo.toUpperCase(),
                            style: TextStyle(
                                color: colorObj,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Text('EliteForm',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            letterSpacing: 2)),
                  ],
                ),
                const SizedBox(height: 20),
                Icon(_iconoObjetivo(rutina.objetivo),
                    color: colorObj, size: 52),
                const SizedBox(height: 12),
                Text(
                  rutina.nombreRutina,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
                const Text(
                  'Descripción de la rutina',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  rutina.descripcion.isNotEmpty
                      ? rutina.descripcion
                      : 'Sin descripción adicional.',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info extra
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icono: _iconoObjetivo(rutina.objetivo),
                    label: 'Objetivo',
                    valor: rutina.objetivo,
                    color: colorObj,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white12),
                Expanded(
                  child: _InfoChip(
                    icono: Icons.fitness_center,
                    label: 'Tipo',
                    valor: 'Personalizada',
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta rutina fue asignada especialmente para ti por el equipo de EliteForm.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Catálogo de rutinas disponibles (cuando no hay una asignada)
// ─────────────────────────────────────────────────────────────────────────────

class _CatalogoRutinas extends StatelessWidget {
  const _CatalogoRutinas();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("rutinas").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final rutinas = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rutinas disponibles',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...rutinas.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _TarjetaRutinaPreview(
                  rutina: RutinaModel.fromMap(doc.id, data));
            }).toList(),
          ],
        );
      },
    );
  }
}

class _TarjetaRutinaPreview extends StatelessWidget {
  final RutinaModel rutina;
  const _TarjetaRutinaPreview({required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
                color: Colors.orangeAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rutina.nombreRutina,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text('Objetivo: ${rutina.objetivo}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget auxiliar
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color color;

  const _InfoChip({
    required this.icono,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: color, size: 22),
        const SizedBox(height: 4),
        Text(valor,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
