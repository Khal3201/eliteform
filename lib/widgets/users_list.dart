import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("usuarios").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error cargando usuarios"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No hay usuarios registrados"));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            final user = UserModel.fromMap(data);
            return _TarjetaUsuario(user: user);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de usuario con info de rutina y dieta
// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaUsuario extends StatelessWidget {
  final UserModel user;
  const _TarjetaUsuario({required this.user});

  void _mostrarDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => _DetalleUsuarioSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneRutina = user.idRutina != null && user.idRutina!.isNotEmpty;
    final bool tieneDieta = user.idDieta != null && user.idDieta!.isNotEmpty;

    return GestureDetector(
      onTap: () => _mostrarDetalle(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF334155),
              child: Icon(Icons.person, color: Colors.white54, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.correo,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _BadgeAsignacion(
                        icono: Icons.fitness_center,
                        label: 'Rutina',
                        asignado: tieneRutina,
                      ),
                      const SizedBox(width: 8),
                      _BadgeAsignacion(
                        icono: Icons.restaurant,
                        label: 'Dieta',
                        asignado: tieneDieta,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BadgeAsignacion extends StatelessWidget {
  final IconData icono;
  final String label;
  final bool asignado;

  const _BadgeAsignacion({
    required this.icono,
    required this.label,
    required this.asignado,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = asignado ? Colors.greenAccent : Colors.white24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet de detalle del usuario (admin puede asignar / cambiar rutina y dieta)
// ─────────────────────────────────────────────────────────────────────────────

class _DetalleUsuarioSheet extends StatelessWidget {
  final UserModel user;
  const _DetalleUsuarioSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Info del usuario
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF334155),
                child: Icon(Icons.person, color: Colors.white54, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(user.correo,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13)),
                    Text('Tel: ${user.telefono}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          // Sección rutina
          const Text('Rutina asignada',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          _SeccionRutinaAdmin(user: user, firestoreService: firestoreService),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          // Sección dieta
          const Text('Dieta asignada',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          _SeccionDietaAdmin(user: user, firestoreService: firestoreService),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sección de administración de rutina del usuario
// ─────────────────────────────────────────────────────────────────────────────

class _SeccionRutinaAdmin extends StatelessWidget {
  final UserModel user;
  final FirestoreService firestoreService;

  const _SeccionRutinaAdmin(
      {required this.user, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getRutinas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final rutinas = snapshot.data!.docs;

        if (rutinas.isEmpty) {
          return const Text('No hay rutinas registradas en el sistema.',
              style: TextStyle(color: Colors.white38, fontSize: 12));
        }

        return DropdownButtonFormField<String>(
          value: (user.idRutina != null && user.idRutina!.isNotEmpty)
              ? user.idRutina
              : null,
          dropdownColor: const Color(0xFF1E293B),
          decoration: InputDecoration(
            hintText: 'Sin rutina asignada',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: const Icon(Icons.fitness_center,
                color: Colors.orangeAccent, size: 18),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '__ninguna__',
              child:
                  Text('Sin rutina', style: TextStyle(color: Colors.white54)),
            ),
            ...rutinas.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(
                  data['nombre_rutina'] ?? doc.id,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
          ],
          onChanged: (value) async {
            if (value == null) return;
            if (value == '__ninguna__') {
              await firestoreService.removerRutinaDeUsuario(user.id);
            } else {
              await firestoreService.asignarRutinaAUsuario(user.id, value);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rutina actualizada'),
                  backgroundColor: Colors.greenAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sección de administración de dieta del usuario
// ─────────────────────────────────────────────────────────────────────────────

class _SeccionDietaAdmin extends StatelessWidget {
  final UserModel user;
  final FirestoreService firestoreService;

  const _SeccionDietaAdmin(
      {required this.user, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getDietas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final dietas = snapshot.data!.docs;

        if (dietas.isEmpty) {
          return const Text('No hay dietas registradas en el sistema.',
              style: TextStyle(color: Colors.white38, fontSize: 12));
        }

        return DropdownButtonFormField<String>(
          value: (user.idDieta != null && user.idDieta!.isNotEmpty)
              ? user.idDieta
              : null,
          dropdownColor: const Color(0xFF1E293B),
          decoration: InputDecoration(
            hintText: 'Sin dieta asignada',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: const Icon(Icons.restaurant,
                color: Colors.greenAccent, size: 18),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '__ninguna__',
              child: Text('Sin dieta', style: TextStyle(color: Colors.white54)),
            ),
            ...dietas.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(
                  data['nombre'] ?? doc.id,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
          ],
          onChanged: (value) async {
            if (value == null) return;
            if (value == '__ninguna__') {
              await firestoreService.removerDietaDeUsuario(user.id);
            } else {
              await firestoreService.asignarDietaAUsuario(user.id, value);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dieta actualizada'),
                  backgroundColor: Colors.greenAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}
