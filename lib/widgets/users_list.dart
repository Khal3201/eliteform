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
          return const Center(
              child: Text("Error cargando usuarios",
                  style: TextStyle(color: Colors.white54)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No hay usuarios registrados",
                  style: TextStyle(color: Colors.white54)));
        }
        final users = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
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

class _TarjetaUsuario extends StatelessWidget {
  final UserModel user;
  const _TarjetaUsuario({required this.user});

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: _DetalleUsuarioSheet(user: user),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneRutina = user.idRutinaActiva?.isNotEmpty == true;
    final tieneDieta = user.idDietaActiva?.isNotEmpty == true;

    return GestureDetector(
      onTap: () => _verDetalle(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
                  Text(user.nombre,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(user.correo,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(
                          icono: Icons.fitness_center,
                          label: 'Rutina',
                          activo: tieneRutina),
                      const SizedBox(width: 8),
                      _Badge(
                          icono: Icons.restaurant,
                          label: 'Dieta',
                          activo: tieneDieta),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icono;
  final String label;
  final bool activo;
  const _Badge(
      {required this.icono, required this.label, required this.activo});

  @override
  Widget build(BuildContext context) {
    final color = activo ? Colors.greenAccent : Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
// DETALLE USUARIO — el admin asigna rutina y dieta
// ─────────────────────────────────────────────────────────────────────────────

class _DetalleUsuarioSheet extends StatelessWidget {
  final UserModel user;
  const _DetalleUsuarioSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final svc = FirestoreService();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          // Header
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF334155),
                child: Icon(Icons.person, color: Colors.white54, size: 28),
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
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          _SeccionLabel(icono: Icons.fitness_center, label: 'Rutina asignada'),
          const SizedBox(height: 8),
          _DropdownRutina(user: user, svc: svc),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          _SeccionLabel(icono: Icons.restaurant, label: 'Dieta asignada'),
          const SizedBox(height: 8),
          _DropdownDieta(user: user, svc: svc),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SeccionLabel extends StatelessWidget {
  final IconData icono;
  final String label;
  const _SeccionLabel({required this.icono, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.orangeAccent, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }
}

// ─── Dropdown Rutina ──────────────────────────────────────────────────────────

class _DropdownRutina extends StatelessWidget {
  final UserModel user;
  final FirestoreService svc;
  const _DropdownRutina({required this.user, required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.getRutinasAdmin(),
      builder: (context, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();
        final docs = snap.data!.docs;

        final valorActual = user.idRutinaActiva?.isNotEmpty == true
            ? user.idRutinaActiva
            : null;
        final ids = docs.map((d) => d.id).toList();
        final valorValido = (valorActual != null && ids.contains(valorActual))
            ? valorActual
            : null;

        return DropdownButtonFormField<String>(
          value: valorValido,
          dropdownColor: const Color(0xFF1E293B),
          decoration: const InputDecoration(
            hintText: 'Sin rutina asignada',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(Icons.fitness_center,
                color: Colors.orangeAccent, size: 18),
            filled: true,
            fillColor: Color(0xFF0F172A),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '__ninguna__',
              child:
                  Text('Sin rutina', style: TextStyle(color: Colors.white54)),
            ),
            ...docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return DropdownMenuItem<String>(
                value: d.id,
                child: Text(data['nombre_rutina'] ?? d.id,
                    style: const TextStyle(color: Colors.white)),
              );
            }),
          ],
          onChanged: (value) async {
            if (value == null) return;
            if (value == '__ninguna__') {
              await svc.adminRemoverRutina(user.id);
            } else {
              await svc.adminAsignarRutina(user.id, value);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Rutina actualizada'),
                    backgroundColor: Colors.greenAccent,
                    duration: Duration(seconds: 2)),
              );
            }
          },
        );
      },
    );
  }
}

// ─── Dropdown Dieta ───────────────────────────────────────────────────────────

class _DropdownDieta extends StatelessWidget {
  final UserModel user;
  final FirestoreService svc;
  const _DropdownDieta({required this.user, required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.getDietasAdmin(),
      builder: (context, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();
        final docs = snap.data!.docs;

        final valorActual =
            user.idDietaActiva?.isNotEmpty == true ? user.idDietaActiva : null;
        final ids = docs.map((d) => d.id).toList();
        final valorValido = (valorActual != null && ids.contains(valorActual))
            ? valorActual
            : null;

        return DropdownButtonFormField<String>(
          value: valorValido,
          dropdownColor: const Color(0xFF1E293B),
          decoration: const InputDecoration(
            hintText: 'Sin dieta asignada',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon:
                Icon(Icons.restaurant, color: Colors.greenAccent, size: 18),
            filled: true,
            fillColor: Color(0xFF0F172A),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '__ninguna__',
              child: Text('Sin dieta', style: TextStyle(color: Colors.white54)),
            ),
            ...docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return DropdownMenuItem<String>(
                value: d.id,
                child: Text(data['nombre'] ?? d.id,
                    style: const TextStyle(color: Colors.white)),
              );
            }),
          ],
          onChanged: (value) async {
            if (value == null) return;
            if (value == '__ninguna__') {
              await svc.adminRemoverDieta(user.id);
            } else {
              await svc.adminAsignarDieta(user.id, value);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Dieta actualizada'),
                    backgroundColor: Colors.greenAccent,
                    duration: Duration(seconds: 2)),
              );
            }
          },
        );
      },
    );
  }
}
