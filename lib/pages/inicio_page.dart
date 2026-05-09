import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// INICIO PAGE —
// ═══════════════════════════════════════════════════════════════════════════════

class InicioPage extends StatefulWidget {
  /// Callback para cambiar la pestaña del BottomNavigationBar del padre.
  final void Function(int index)? onNavegar;

  const InicioPage({super.key, this.onNavegar});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final PageController _carruselCtrl = PageController();
  int _paginaCarrusel = 0;

  @override
  void dispose() {
    _carruselCtrl.dispose();
    super.dispose();
  }

  // Índices del BottomNavigationBar en home_page.dart
  static const int _idxRutina = 1;
  static const int _idxDieta = 2;
  static const int _idxAcceso = 4;

  void _navegar(int index) {
    if (widget.onNavegar != null) {
      widget.onNavegar!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Saludo ──────────────────────────────────────────────────────
          _Saludo(uid: user?.uid ?? ''),
          const SizedBox(height: 20),

          // ── Contador de personas en el gym ──────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _ContadorGym(),
          ),
          const SizedBox(height: 24),

          // ── Sección de eventos (carrusel desde Firestore) ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text('Eventos y clases',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Carrusel de eventos desde Firestore
          _CarruselEventos(
            carruselCtrl: _carruselCtrl,
            paginaActual: _paginaCarrusel,
            onPageChanged: (i) => setState(() => _paginaCarrusel = i),
          ),

          const SizedBox(height: 24),

          // ── Accesos rápidos funcionales ──────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Accesos rápidos',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _AccesoRapido(
                  icono: Icons.fitness_center,
                  label: 'Mi Rutina',
                  color: Colors.orangeAccent,
                  onTap: () => _navegar(_idxRutina),
                ),
                const SizedBox(width: 12),
                _AccesoRapido(
                  icono: Icons.restaurant,
                  label: 'Mi Dieta',
                  color: Colors.greenAccent,
                  onTap: () => _navegar(_idxDieta),
                ),
                const SizedBox(width: 12),
                _AccesoRapido(
                  icono: Icons.qr_code,
                  label: 'Mi QR',
                  color: Colors.blueAccent,
                  onTap: () => _navegar(_idxAcceso),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Carrusel de eventos desde Firestore ──────────────────────────────────────

class _CarruselEventos extends StatelessWidget {
  final PageController carruselCtrl;
  final int paginaActual;
  final ValueChanged<int> onPageChanged;

  const _CarruselEventos({
    required this.carruselCtrl,
    required this.paginaActual,
    required this.onPageChanged,
  });

  static const List<Map<String, dynamic>> _fallback = [
    {
      'titulo': 'Clase de Spinning',
      'descripcion': 'Todos los martes y jueves a las 7:00 AM',
      'icono': 'directions_bike',
      'color': 0xFFEA580C,
      'horario': 'Mar y Jue · 7:00 AM',
    },
  ];

  IconData _iconoDesde(String nombre) {
    const m = {
      'directions_bike': Icons.directions_bike,
      'self_improvement': Icons.self_improvement,
      'fitness_center': Icons.fitness_center,
      'monitor_weight': Icons.monitor_weight,
      'sports': Icons.sports,
      'pool': Icons.pool,
      'run_circle': Icons.run_circle,
      'sports_gymnastics': Icons.sports_gymnastics,
    };
    return m[nombre] ?? Icons.event;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventos')
          .where('activo', isEqualTo: true)
          .orderBy('orden')
          .snapshots(),
      builder: (context, snap) {
        List<Map<String, dynamic>> eventos;

        if (snap.hasData && snap.data!.docs.isNotEmpty) {
          eventos = snap.data!.docs
              .map((d) => d.data() as Map<String, dynamic>)
              .toList();
        } else {
          eventos = _fallback;
        }

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: carruselCtrl,
                onPageChanged: onPageChanged,
                itemCount: eventos.length,
                itemBuilder: (_, i) {
                  final e = eventos[i];
                  final color = Color(e['color'] as int? ?? 0xFFEA580C);
                  final icono = e['icono'] is String
                      ? _iconoDesde(e['icono'])
                      : Icons.event;
                  return _TarjetaEvento(
                    titulo: e['titulo'] ?? '',
                    descripcion: e['descripcion'] ?? '',
                    horario: e['horario'] ?? '',
                    icono: icono,
                    color: color,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                eventos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: paginaActual == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: paginaActual == i
                        ? Colors.orangeAccent
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Saludo personalizado ──────────────────────────────────────────────────────

class _Saludo extends StatelessWidget {
  final String uid;
  const _Saludo({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text('¡Bienvenido!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snap) {
        final nombre = (snap.data?.data() as Map<String, dynamic>?)?['nombre']
                ?.toString()
                .split(' ')
                .first ??
            'Atleta';

        final hora = DateTime.now().hour;
        String saludo;
        if (hora < 12) {
          saludo = 'Buenos días';
        } else if (hora < 19) {
          saludo = 'Buenas tardes';
        } else {
          saludo = 'Buenas noches';
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$saludo, $nombre 👋',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aquí está el resumen de hoy',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Contador de personas en el gym ───────────────────────────────────────────

class _ContadorGym extends StatelessWidget {
  const _ContadorGym();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('dentro_del_gym', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        final personas = snap.data?.docs
                .map((d) =>
                    (d.data() as Map<String, dynamic>)['nombre']?.toString() ??
                    '')
                .where((n) => n.isNotEmpty)
                .take(5)
                .toList() ??
            [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent.withOpacity(0.25),
                const Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.orangeAccent.withOpacity(0.4), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people,
                        color: Colors.orangeAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personas en el gym ahora',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text('personas',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.greenAccent,
                                blurRadius: 8,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('En vivo',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              if (personas.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: personas
                      .map((nombre) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sports_gymnastics,
                                    color: Colors.orangeAccent, size: 12),
                                const SizedBox(width: 5),
                                Text(nombre,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                if (count > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'y ${count - 5} más...',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
              ] else if (count == 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'El gym está vacío por ahora. ¡Sé el primero en llegar!',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Tarjeta de evento ────────────────────────────────────────────────────────

class _TarjetaEvento extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String horario;
  final IconData icono;
  final Color color;

  const _TarjetaEvento({
    required this.titulo,
    required this.descripcion,
    required this.horario,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.35), const Color(0xFF1E293B)],
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                        color: Colors.white54, fontSize: 12, height: 1.4)),
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
    );
  }
}

// ─── Acceso rápido ────────────────────────────────────────────────────────────

class _AccesoRapido extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icono,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 26),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
