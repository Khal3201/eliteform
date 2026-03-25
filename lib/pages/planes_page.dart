import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalle_plan_page.dart';

class PlanesPage extends StatelessWidget {
  const PlanesPage({super.key});

  static const List<Map<String, dynamic>> planes = [
    {
      'nombre': 'Plan Básico',
      'precio': 299,
      'duracion': '1 mes',
      'icono': Icons.fitness_center,
      'color': Color(0xFF334155),
      'descripcion': 'Ideal para comenzar tu transformación.',
      'beneficios': [
        'Acceso al gym de lunes a viernes',
        'Horario: 6am – 8pm',
        'Uso de máquinas cardiovasculares',
        'Uso de área de pesas',
        'Casillero incluido',
      ],
    },
    {
      'nombre': 'Plan Pro',
      'precio': 499,
      'duracion': '1 mes',
      'icono': Icons.bolt,
      'color': Color(0xFFEA580C),
      'descripcion': 'El más popular. Acceso completo y clases grupales.',
      'beneficios': [
        'Acceso ilimitado todos los días',
        'Horario: 5am – 10pm',
        'Incluye clases grupales (yoga, spinning, crossfit)',
        'Uso de todas las áreas',
        'Casillero incluido',
        '1 sesión de evaluación física',
      ],
    },
    {
      'nombre': 'Plan Elite',
      'precio': 799,
      'duracion': '1 mes',
      'icono': Icons.workspace_premium,
      'color': Color(0xFFD97706),
      'descripcion': 'La experiencia completa con entrenador personal.',
      'beneficios': [
        'Acceso ilimitado todos los días',
        'Horario: 24 horas',
        'Clases grupales ilimitadas',
        'Uso de todas las áreas',
        'Casillero premium',
        '4 sesiones con entrenador personal',
        'Plan de nutrición personalizado',
        'Acceso a área de spa y sauna',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final bool membresiaActiva = userData['membresia_activa'] == true;
        final String? pedidoId = userData['pedido_id'];

        // ESTADO 3: Membresía activa
        if (membresiaActiva && pedidoId != null) {
          return _VistaMembresia(
            userData: userData,
            pedidoId: pedidoId,
            uid: user.uid,
          );
        }

        // ESTADO 2: Pedido pendiente
        if (!membresiaActiva && pedidoId != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .doc(pedidoId)
                .snapshots(),
            builder: (context, pedidoSnap) {
              if (pedidoSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!pedidoSnap.hasData || !pedidoSnap.data!.exists) {
                return _VistaPlanes(uid: user.uid);
              }
              final pedidoData =
                  pedidoSnap.data!.data() as Map<String, dynamic>;
              return _VistaPedidoPendiente(
                pedidoId: pedidoId,
                pedidoData: pedidoData,
                uid: user.uid,
              );
            },
          );
        }

        // ESTADO 1: Sin pedido
        return _VistaPlanes(uid: user.uid);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO 1: Catálogo de planes
// ─────────────────────────────────────────────────────────────────────────────
class _VistaPlanes extends StatelessWidget {
  final String uid;
  const _VistaPlanes({required this.uid});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.orangeAccent.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.star, color: Colors.orangeAccent, size: 32),
                SizedBox(height: 8),
                Text(
                  'Elige tu membresía',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Selecciona el plan que mejor se adapte a tus objetivos.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...PlanesPage.planes.map((plan) => _PlanCard(plan: plan)).toList(),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final bool esPopular = plan['nombre'] == 'Plan Pro';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: esPopular
            ? Border.all(color: Colors.orangeAccent, width: 2)
            : Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          if (esPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Center(
                child: Text('⭐ MÁS POPULAR',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (plan['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(plan['icono'] as IconData,
                          color: plan['color'] as Color, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan['nombre'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(plan['descripcion'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${plan['precio']}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent)),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text('/ mes',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...((plan['beneficios'] as List<String>)
                    .take(3)
                    .map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.orangeAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(b,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13))),
                            ],
                          ),
                        ))),
                if ((plan['beneficios'] as List<String>).length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(
                        '+ ${(plan['beneficios'] as List<String>).length - 3} beneficios más...',
                        style: const TextStyle(
                            color: Colors.orangeAccent, fontSize: 12)),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetallePlanPage(plan: plan))),
                    child: const Text('Ver plan completo'),
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
// ESTADO 2: Pedido pendiente
// ─────────────────────────────────────────────────────────────────────────────
class _VistaPedidoPendiente extends StatelessWidget {
  final String pedidoId;
  final Map<String, dynamic> pedidoData;
  final String uid;
  const _VistaPedidoPendiente(
      {required this.pedidoId, required this.pedidoData, required this.uid});

  Future<void> _cancelarPedido(BuildContext context) async {
    final bool confirmar = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Cancelar pedido',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                '¿Quieres cancelar este pedido? Podrás solicitar un nuevo plan.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sí, cancelar')),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    final batch = FirebaseFirestore.instance.batch();
    batch
        .delete(FirebaseFirestore.instance.collection('pedidos').doc(pedidoId));
    batch.update(FirebaseFirestore.instance.collection('usuarios').doc(uid), {
      'pedido_id': FieldValue.delete(),
      'membresia_activa': false,
    });
    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Pedido cancelado. Ya puedes elegir otro plan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fechaStr = '—';
    if (pedidoData['fecha_pedido'] != null) {
      final DateTime f = (pedidoData['fecha_pedido'] as Timestamp).toDate();
      fechaStr = '${f.day}/${f.month}/${f.year}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: const [
                Icon(Icons.access_time, color: Colors.amberAccent, size: 48),
                SizedBox(height: 12),
                Text(
                  'Pedido en revisión',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  'Tu pedido fue recibido. El administrador verificará tu pago y activará tu membresía pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                const Text('Detalle de tu pedido',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 14),
                _FilaPedido(
                    icono: Icons.fitness_center,
                    label: 'Plan',
                    valor: pedidoData['plan'] ?? '—'),
                const Divider(color: Colors.white12, height: 20),
                _FilaPedido(
                    icono: Icons.attach_money,
                    label: 'Monto',
                    valor: '\$${pedidoData['precio']} MXN',
                    valorColor: Colors.orangeAccent),
                const Divider(color: Colors.white12, height: 20),
                _FilaPedido(
                    icono: Icons.payment,
                    label: 'Método de pago',
                    valor: pedidoData['metodo_pago'] ?? '—'),
                const Divider(color: Colors.white12, height: 20),
                _FilaPedido(
                    icono: Icons.calendar_today,
                    label: 'Fecha del pedido',
                    valor: fechaStr),
                const Divider(color: Colors.white12, height: 20),
                const _FilaPedido(
                    icono: Icons.info_outline,
                    label: 'Estado',
                    valor: 'Pendiente de confirmación',
                    valorColor: Colors.amberAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.blueAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pedidoData['metodo_pago'] == 'Efectivo'
                        ? 'Acércate a recepción con este pedido para realizar tu pago en efectivo.'
                        : pedidoData['metodo_pago'] == 'Transferencia'
                            ? 'Solicita los datos bancarios en recepción y envía tu comprobante.'
                            : 'Preséntate en recepción con tu tarjeta para que procesen el cobro.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelarPedido(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              label: const Text('Cancelar pedido',
                  style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO 3: Membresía activa
// ─────────────────────────────────────────────────────────────────────────────
class _VistaMembresia extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String pedidoId;
  final String uid;

  const _VistaMembresia(
      {required this.userData, required this.pedidoId, required this.uid});

  Future<void> _cancelarMembresia(BuildContext context) async {
    final bool confirmar = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Cancelar membresía',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                '¿Estás seguro? Perderás el acceso al gym y podrás contratar un nuevo plan cuando quieras.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No, conservar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sí, cancelar')),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    final batch = FirebaseFirestore.instance.batch();
    batch
        .delete(FirebaseFirestore.instance.collection('pedidos').doc(pedidoId));
    batch.update(FirebaseFirestore.instance.collection('usuarios').doc(uid), {
      'membresia_activa': false,
      'plan_activo': FieldValue.delete(),
      'fecha_proximo_pago': FieldValue.delete(),
      'pedido_id': FieldValue.delete(),
    });
    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Membresía cancelada.'), backgroundColor: Colors.red),
    );
  }

  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return '—';
    final DateTime f = (timestamp as Timestamp).toDate();
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${f.day} de ${meses[f.month]} de ${f.year}';
  }

  int _diasRestantes(dynamic timestamp) {
    if (timestamp == null) return 0;
    final DateTime fp = (timestamp as Timestamp).toDate();
    return fp.difference(DateTime.now()).inDays.clamp(0, 999);
  }

  @override
  Widget build(BuildContext context) {
    final String planActivo = userData['plan_activo'] ?? 'Plan';
    final dynamic proximoPagoTs = userData['fecha_proximo_pago'];
    final int diasRestantes = _diasRestantes(proximoPagoTs);

    final Map<String, dynamic> planInfo = PlanesPage.planes.firstWhere(
        (p) => p['nombre'] == planActivo,
        orElse: () => PlanesPage.planes[0]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta principal membresía
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (planInfo['color'] as Color).withOpacity(0.3),
                  const Color(0xFF1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.4), width: 2),
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
                        color: Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle,
                              color: Colors.greenAccent, size: 14),
                          SizedBox(width: 6),
                          Text('ACTIVA',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
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
                Icon(planInfo['icono'] as IconData,
                    color: planInfo['color'] as Color, size: 52),
                const SizedBox(height: 12),
                Text(planActivo,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(planInfo['descripcion'],
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatMembresia(
                          valor: '\$${planInfo['precio']}',
                          label: 'Mensualidad',
                          color: Colors.orangeAccent),
                      Container(width: 1, height: 36, color: Colors.white12),
                      _StatMembresia(
                          valor: '$diasRestantes',
                          label: 'Días restantes',
                          color: diasRestantes < 7
                              ? Colors.redAccent
                              : Colors.greenAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Próximo pago
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
                const Text('Información de membresía',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 14),
                _FilaPedido(
                    icono: Icons.event_repeat,
                    label: 'Próximo pago',
                    valor: _formatearFecha(proximoPagoTs),
                    valorColor:
                        diasRestantes < 7 ? Colors.redAccent : Colors.white),
                const Divider(color: Colors.white12, height: 20),
                _FilaPedido(
                    icono: Icons.attach_money,
                    label: 'Monto a pagar',
                    valor: '\$${planInfo['precio']} MXN',
                    valorColor: Colors.orangeAccent),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Beneficios activos
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
                const Text('Tu plan incluye',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 12),
                ...(planInfo['beneficios'] as List<String>).map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.greenAccent, size: 13),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13))),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cancelar membresía
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelarMembresia(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              label: const Text('Cancelar membresía',
                  style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Al cancelar perderás el acceso al gym. Podrás contratar un nuevo plan cuando quieras.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Widgets compartidos ──────────────────────────────────────────────────────

class _FilaPedido extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color? valorColor;
  const _FilaPedido(
      {required this.icono,
      required this.label,
      required this.valor,
      this.valorColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Text(valor,
            style: TextStyle(
                color: valorColor ?? Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StatMembresia extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;
  const _StatMembresia(
      {required this.valor, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
