import 'package:flutter/material.dart';

class ConfirmacionPagoPage extends StatelessWidget {
  final Map<String, dynamic> plan;
  final String metodoPago;

  const ConfirmacionPagoPage({
    super.key,
    required this.plan,
    required this.metodoPago,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Ícono de éxito animado
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: 72,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                '¡Pedido confirmado!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Text(
                'Tu solicitud fue registrada exitosamente. Preséntate en recepción para completar tu pago y activar tu membresía.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Detalle del pedido
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _FilaDetalle(
                      icono: Icons.fitness_center,
                      label: 'Plan',
                      valor: plan['nombre'],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _FilaDetalle(
                      icono: Icons.attach_money,
                      label: 'Total',
                      valor: '\$${plan['precio']} MXN',
                      valorColor: Colors.orangeAccent,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _FilaDetalle(
                      icono: Icons.payment,
                      label: 'Método de pago',
                      valor: metodoPago,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _FilaDetalle(
                      icono: Icons.info_outline,
                      label: 'Estado',
                      valor: 'Pendiente de pago',
                      valorColor: Colors.amberAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Nota según método de pago
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
                        metodoPago == 'Efectivo'
                            ? 'Acércate a recepción y muestra este pedido para completar tu pago.'
                            : metodoPago == 'Transferencia'
                                ? 'Solicita los datos de transferencia en recepción y envía tu comprobante.'
                                : 'Preséntate en recepción con tu tarjeta para completar el cobro.',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botón de volver — cierra todas las pantallas apiladas
              // (confirmacion → resumen → detalle) y regresa al HomePage
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Elimina todas las rutas hasta llegar al HomePage,
                    // que ya contiene PlanesPage en su BottomNavigationBar.
                    // PlanesPage detectará el pedido y mostrará el estado correcto.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Volver a los planes'),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para las filas del resumen
class _FilaDetalle extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color? valorColor;

  const _FilaDetalle({
    required this.icono,
    required this.label,
    required this.valor,
    this.valorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
            color: valorColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
