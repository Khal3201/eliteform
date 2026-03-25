import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPedidosPage extends StatelessWidget {
  const AdminPedidosPage({super.key});

  Future<void> _aceptarPedido(BuildContext context, String pedidoId,
      String uidUsuario, Map<String, dynamic> pedidoData) async {
    final bool confirmar = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Aceptar pedido',
                style: TextStyle(color: Colors.white)),
            content: Text(
              '¿Confirmar pago de ${pedidoData['nombre_usuario']} por el ${pedidoData['plan']}?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Aceptar pago'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    // Calcular próxima fecha de pago (1 mes desde hoy)
    final DateTime hoy = DateTime.now();
    final DateTime proximoPago = DateTime(hoy.year, hoy.month + 1, hoy.day);

    final batch = FirebaseFirestore.instance.batch();

    // 1. Actualizar el pedido a "Aceptado"
    final pedidoRef =
        FirebaseFirestore.instance.collection('pedidos').doc(pedidoId);
    batch.update(pedidoRef, {
      'estado': 'Aceptado',
      'fecha_aceptacion': FieldValue.serverTimestamp(),
      'fecha_proximo_pago': Timestamp.fromDate(proximoPago),
    });

    // 2. Actualizar el documento del usuario con su membresía activa
    final usuarioRef =
        FirebaseFirestore.instance.collection('usuarios').doc(uidUsuario);
    batch.update(usuarioRef, {
      'membresia_activa': true,
      'plan_activo': pedidoData['plan'],
      'fecha_proximo_pago': Timestamp.fromDate(proximoPago),
      'pedido_id': pedidoId,
    });

    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Membresía de ${pedidoData['nombre_usuario']} activada ✓'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _rechazarPedido(BuildContext context, String pedidoId,
      String uidUsuario, String nombreUsuario) async {
    final bool confirmar = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Eliminar pedido',
                style: TextStyle(color: Colors.white)),
            content: Text(
              '¿Eliminar el pedido de $nombreUsuario? El usuario podrá solicitar un nuevo plan.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    final batch = FirebaseFirestore.instance.batch();

    // 1. Eliminar el pedido
    batch
        .delete(FirebaseFirestore.instance.collection('pedidos').doc(pedidoId));

    // 2. Limpiar membresía del usuario si la tenía
    batch.update(
        FirebaseFirestore.instance.collection('usuarios').doc(uidUsuario), {
      'membresia_activa': false,
      'plan_activo': FieldValue.delete(),
      'fecha_proximo_pago': FieldValue.delete(),
      'pedido_id': FieldValue.delete(),
    });

    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido eliminado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Colors.greenAccent;
      case 'Pendiente':
        return Colors.amberAccent;
      default:
        return Colors.white54;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .orderBy('fecha_pedido', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando pedidos'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox_outlined, color: Colors.white24, size: 64),
                SizedBox(height: 16),
                Text('No hay pedidos aún',
                    style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }

        final pedidos = snapshot.data!.docs;
        final pendientes =
            pedidos.where((p) => p['estado'] == 'Pendiente').toList();
        final aceptados =
            pedidos.where((p) => p['estado'] == 'Aceptado').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Contador rápido
            Row(
              children: [
                _ContadorChip(
                  label: 'Pendientes',
                  count: pendientes.length,
                  color: Colors.amberAccent,
                ),
                const SizedBox(width: 10),
                _ContadorChip(
                  label: 'Aceptados',
                  count: aceptados.length,
                  color: Colors.greenAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pedidos pendientes primero
            if (pendientes.isNotEmpty) ...[
              const _SeccionHeader(
                  titulo: 'Pendientes de pago',
                  icono: Icons.access_time,
                  color: Colors.amberAccent),
              const SizedBox(height: 10),
              ...pendientes.map((doc) => _TarjetaPedido(
                    pedidoId: doc.id,
                    data: doc.data() as Map<String, dynamic>,
                    onAceptar: (id, uid, data) =>
                        _aceptarPedido(context, id, uid, data),
                    onRechazar: (id, uid, nombre) =>
                        _rechazarPedido(context, id, uid, nombre),
                  )),
              const SizedBox(height: 20),
            ],

            // Pedidos aceptados
            if (aceptados.isNotEmpty) ...[
              const _SeccionHeader(
                  titulo: 'Membresías activas',
                  icono: Icons.check_circle,
                  color: Colors.greenAccent),
              const SizedBox(height: 10),
              ...aceptados.map((doc) => _TarjetaPedido(
                    pedidoId: doc.id,
                    data: doc.data() as Map<String, dynamic>,
                    onAceptar: (id, uid, data) =>
                        _aceptarPedido(context, id, uid, data),
                    onRechazar: (id, uid, nombre) =>
                        _rechazarPedido(context, id, uid, nombre),
                  )),
            ],
          ],
        );
      },
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────

class _ContadorChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _ContadorChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  const _SeccionHeader(
      {required this.titulo, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}

class _TarjetaPedido extends StatelessWidget {
  final String pedidoId;
  final Map<String, dynamic> data;
  final Function(String id, String uid, Map<String, dynamic> data) onAceptar;
  final Function(String id, String uid, String nombre) onRechazar;

  const _TarjetaPedido({
    required this.pedidoId,
    required this.data,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final String estado = data['estado'] ?? 'Pendiente';
    final bool esAceptado = estado == 'Aceptado';
    final Color colorEstado =
        esAceptado ? Colors.greenAccent : Colors.amberAccent;

    String fechaStr = '—';
    if (data['fecha_pedido'] != null) {
      final DateTime fecha = (data['fecha_pedido'] as Timestamp).toDate();
      fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';
    }

    String proximoPagoStr = '—';
    if (data['fecha_proximo_pago'] != null) {
      final DateTime fp = (data['fecha_proximo_pago'] as Timestamp).toDate();
      proximoPagoStr = '${fp.day}/${fp.month}/${fp.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esAceptado
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.amberAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nombre + estado
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF334155),
                  child: Icon(Icons.person, color: Colors.white54, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nombre_usuario'] ?? 'Usuario',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Text(
                        'Pedido: $fechaStr',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: colorEstado.withOpacity(0.4)),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                        color: colorEstado,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),

            // Info del pedido
            _InfoFila(
                icono: Icons.fitness_center,
                label: 'Plan',
                valor: data['plan'] ?? '—'),
            const SizedBox(height: 6),
            _InfoFila(
                icono: Icons.attach_money,
                label: 'Monto',
                valor: '\$${data['precio']} MXN',
                valorColor: Colors.orangeAccent),
            const SizedBox(height: 6),
            _InfoFila(
                icono: Icons.payment,
                label: 'Método',
                valor: data['metodo_pago'] ?? '—'),
            if (esAceptado) ...[
              const SizedBox(height: 6),
              _InfoFila(
                  icono: Icons.event,
                  label: 'Próximo pago',
                  valor: proximoPagoStr,
                  valorColor: Colors.greenAccent),
            ],

            const SizedBox(height: 14),

            // Botones de acción
            if (!esAceptado)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onAceptar(pedidoId, data['uid_usuario'], data),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aceptar pago'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => onRechazar(pedidoId, data['uid_usuario'],
                        data['nombre_usuario'] ?? 'usuario'),
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.redAccent),
                    label: const Text('Eliminar',
                        style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            if (esAceptado)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onRechazar(pedidoId, data['uid_usuario'],
                      data['nombre_usuario'] ?? 'usuario'),
                  icon: const Icon(Icons.cancel_outlined,
                      size: 16, color: Colors.redAccent),
                  label: const Text('Cancelar membresía',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color? valorColor;
  const _InfoFila(
      {required this.icono,
      required this.label,
      required this.valor,
      this.valorColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.white38, size: 15),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
              color: valorColor ?? Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
