import 'package:flutter/material.dart';
import 'resumen_pago_page.dart';

class DetallePlanPage extends StatelessWidget {
  final Map<String, dynamic> plan;
  const DetallePlanPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final List<String> beneficios = plan['beneficios'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text(plan['nombre']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner superior del plan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (plan['color'] as Color).withOpacity(0.4),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: (plan['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: plan['color'] as Color,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      plan['icono'] as IconData,
                      color: plan['color'] as Color,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    plan['nombre'],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan['descripcion'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Precio grande
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${plan['precio']}',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            '/ mes',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lista de beneficios completa
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lo que incluye este plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: beneficios.map((b) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orangeAccent.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.orangeAccent,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline,
                            color: Colors.blueAccent, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'La membresía se activa el día en que realizas el pago. Puedes cancelar en cualquier momento desde tu perfil.',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón de contratar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResumenPagoPage(plan: plan),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: Text('Contratar ${plan['nombre']}'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón de cancelar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Volver a los planes',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
