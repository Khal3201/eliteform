import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class DietaPage extends StatelessWidget {
  const DietaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final firestoreService = FirestoreService();

    return StreamBuilder<DietaModel?>(
      stream: firestoreService.streamDietaDeUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final dieta = snapshot.data;

        if (dieta == null) {
          return const _SinDieta();
        }

        return _VistaDieta(dieta: dieta);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sin dieta asignada
// ─────────────────────────────────────────────────────────────────────────────

class _SinDieta extends StatelessWidget {
  const _SinDieta();

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
                    color: Colors.greenAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.restaurant,
                      color: Colors.greenAccent, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aún no tienes una dieta',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El administrador puede asignarte un plan alimenticio personalizado según tus metas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Muestra dietas disponibles en el sistema
          const _CatalogoDietas(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vista con dieta asignada
// ─────────────────────────────────────────────────────────────────────────────

class _VistaDieta extends StatelessWidget {
  final DietaModel dieta;

  const _VistaDieta({required this.dieta});

  Color _colorCalorias(int calorias) {
    if (calorias < 1500) return Colors.blueAccent;
    if (calorias < 2500) return Colors.greenAccent;
    return Colors.orangeAccent;
  }

  String _etiquetaCalorias(int calorias) {
    if (calorias < 1500) return 'Déficit calórico';
    if (calorias < 2500) return 'Mantenimiento';
    return 'Superávit calórico';
  }

  @override
  Widget build(BuildContext context) {
    final Color colorCal = _colorCalorias(dieta.calorias);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta principal de la dieta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorCal.withOpacity(0.3), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorCal.withOpacity(0.5), width: 2),
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
                        color: colorCal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: colorCal.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: colorCal, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _etiquetaCalorias(dieta.calorias).toUpperCase(),
                            style: TextStyle(
                                color: colorCal,
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
                const Icon(Icons.restaurant_menu,
                    color: Colors.white70, size: 52),
                const SizedBox(height: 12),
                Text(
                  dieta.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Bloque de calorías
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${dieta.calorias}',
                        style: TextStyle(
                            color: colorCal,
                            fontSize: 38,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'kcal / día',
                        style: TextStyle(
                            color: colorCal.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
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
                const Text(
                  'Descripción del plan',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  dieta.descripcion.isNotEmpty
                      ? dieta.descripcion
                      : 'Sin descripción adicional.',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Resumen de macros estimados
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
                  'Distribución estimada',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 14),
                _MacroFila(
                  label: 'Proteínas',
                  icono: Icons.egg_alt,
                  porcentaje: 0.30,
                  calorias: dieta.calorias,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                _MacroFila(
                  label: 'Carbohidratos',
                  icono: Icons.grain,
                  porcentaje: 0.45,
                  calorias: dieta.calorias,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 10),
                _MacroFila(
                  label: 'Grasas',
                  icono: Icons.water_drop,
                  porcentaje: 0.25,
                  calorias: dieta.calorias,
                  color: Colors.blueAccent,
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
                    'Este plan fue diseñado especialmente para ti. Consulta con tu entrenador para mayor detalle.',
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
// Catálogo de dietas disponibles (cuando no hay una asignada)
// ─────────────────────────────────────────────────────────────────────────────

class _CatalogoDietas extends StatelessWidget {
  const _CatalogoDietas();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("dietas").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final dietas = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planes disponibles',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...dietas.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _TarjetaDietaPreview(
                  dieta: DietaModel.fromMap(doc.id, data));
            }).toList(),
          ],
        );
      },
    );
  }
}

class _TarjetaDietaPreview extends StatelessWidget {
  final DietaModel dieta;
  const _TarjetaDietaPreview({required this.dieta});

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
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant,
                color: Colors.greenAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dieta.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text('${dieta.calorias} kcal / día',
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
// Widget auxiliar de macros
// ─────────────────────────────────────────────────────────────────────────────

class _MacroFila extends StatelessWidget {
  final String label;
  final IconData icono;
  final double porcentaje;
  final int calorias;
  final Color color;

  const _MacroFila({
    required this.label,
    required this.icono,
    required this.porcentaje,
    required this.calorias,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final int kcal = (calorias * porcentaje).round();
    final int gramos = (kcal / 4).round(); // aprox para prot/carbs

    return Row(
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const Spacer(),
        Text(
          '~$kcal kcal',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text('(~${gramos}g)',
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
