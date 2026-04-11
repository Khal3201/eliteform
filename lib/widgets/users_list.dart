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

class _TarjetaUsuario extends StatelessWidget {
  final UserModel user;
  const _TarjetaUsuario({required this.user});

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: _DetalleUsuarioSheet(user: user),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar usuario',
                style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Eliminar a ${user.nombre}?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Se eliminarán su perfil y pedidos de Firestore. '
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amberAccent, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La cuenta Auth debe eliminarse manualmente '
                          'desde Firebase Console.',
                          style: TextStyle(
                              color: Colors.amberAccent, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;

    if (!ok) return;
    try {
      await FirestoreService().adminEliminarUsuario(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Usuario ${user.nombre} eliminado'),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneRutina = user.idRutinaActiva?.isNotEmpty == true;
    final tieneDieta = user.idDietaActiva?.isNotEmpty == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _verDetalle(context),
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF334155),
              child: Icon(Icons.person, color: Colors.white54, size: 24),
            ),
            title: Text(user.nombre,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.correo,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                        icono: Icons.fitness_center,
                        label: 'Rutina',
                        activo: tieneRutina),
                    const SizedBox(width: 6),
                    _Badge(
                        icono: Icons.restaurant,
                        label: 'Dieta',
                        activo: tieneDieta),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _verDetalle(context),
                  icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                  label: const Text('Gestionar'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _confirmarEliminar(context),
                  icon: const Icon(Icons.person_remove_outlined,
                      size: 16, color: Colors.redAccent),
                  label: const Text('Eliminar',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 10),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Rutina actualizada'),
                  backgroundColor: Colors.greenAccent,
                  duration: Duration(seconds: 2)));
            }
          },
        );
      },
    );
  }
}

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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Dieta actualizada'),
                  backgroundColor: Colors.greenAccent,
                  duration: Duration(seconds: 2)));
            }
          },
        );
      },
    );
  }
}
