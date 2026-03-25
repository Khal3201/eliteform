import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirmacion_pago_page.dart';

class ResumenPagoPage extends StatefulWidget {
  final Map<String, dynamic> plan;
  const ResumenPagoPage({super.key, required this.plan});

  @override
  State<ResumenPagoPage> createState() => _ResumenPagoPageState();
}

class _ResumenPagoPageState extends State<ResumenPagoPage> {
  // Método de pago seleccionado
  String _metodoPago = 'Efectivo';
  bool _procesando = false;
  String _nombreUsuario = '';

  final List<Map<String, dynamic>> _metodos = [
    {
      'label': 'Efectivo',
      'icono': Icons.payments_outlined,
      'descripcion': 'Paga directamente en recepción',
    },
    {
      'label': 'Transferencia',
      'icono': Icons.account_balance,
      'descripcion': 'Transferencia bancaria o SPEI',
    },
    {
      'label': 'Tarjeta',
      'icono': Icons.credit_card,
      'descripcion': 'Crédito o débito en recepción',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _nombreUsuario = doc['nombre'] ?? '';
      });
    }
  }

  Future<void> _confirmarPedido() async {
    setState(() => _procesando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Guardar el pedido en Firestore
      await FirebaseFirestore.instance.collection('pedidos').add({
        'uid_usuario': user.uid,
        'nombre_usuario': _nombreUsuario,
        'plan': widget.plan['nombre'],
        'precio': widget.plan['precio'],
        'metodo_pago': _metodoPago,
        'estado': 'Pendiente',
        'fecha_pedido': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      // Navegar a confirmación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmacionPagoPage(
            plan: widget.plan,
            metodoPago: _metodoPago,
          ),
        ),
      );
    } catch (e) {
      setState(() => _procesando = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar el pedido. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del plan elegido
            const Text(
              'Plan seleccionado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (widget.plan['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.plan['icono'] as IconData,
                      color: widget.plan['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan['nombre'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.plan['duracion'],
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${widget.plan['precio']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Datos del usuario
            const Text(
              'Titular de la membresía',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.orangeAccent),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombreUsuario.isEmpty ? 'Cargando...' : _nombreUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Método de pago
            const Text(
              'Método de pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            ..._metodos.map((metodo) {
              final bool seleccionado = _metodoPago == metodo['label'];
              return GestureDetector(
                onTap: () {
                  setState(() => _metodoPago = metodo['label']);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? Colors.orangeAccent.withOpacity(0.12)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: seleccionado
                          ? Colors.orangeAccent
                          : Colors.white12,
                      width: seleccionado ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        metodo['icono'] as IconData,
                        color: seleccionado
                            ? Colors.orangeAccent
                            : Colors.white54,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metodo['label'],
                              style: TextStyle(
                                color: seleccionado
                                    ? Colors.orangeAccent
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              metodo['descripcion'],
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (seleccionado)
                        const Icon(Icons.check_circle,
                            color: Colors.orangeAccent, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 28),

            // Total final
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${widget.plan['precio']} MXN',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón de confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _procesando ? null : _confirmarPedido,
                icon: _procesando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                    _procesando ? 'Procesando...' : 'Confirmar pedido'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Regresar',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
