import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scanner_qr_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MONITOR DEL GYM — Vista del administrador
// Muestra en tiempo real cuántas personas están dentro del gym
// ═══════════════════════════════════════════════════════════════════════════════

class GymMonitorPage extends StatelessWidget {
  const GymMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor del Gym'),
        actions: [
          // Botón para abrir el escáner
          IconButton(
            tooltip: 'Escanear QR',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.black, size: 20),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerQrPage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta principal: contador grande ──────────────────────────
            const _TarjetaContadorPrincipal(),
            const SizedBox(height: 20),

            // ── Lista de personas dentro ────────────────────────────────────
            const _ListaPersonasDentro(),
            const SizedBox(height: 20),

            // ── Historial reciente de accesos ────────────────────────────────
            const _HistorialReciente(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScannerQrPage()),
        ),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear QR'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

// ─── Tarjeta contador grande ──────────────────────────────────────────────────

class _TarjetaContadorPrincipal extends StatelessWidget {
  const _TarjetaContadorPrincipal();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('dentro_del_gym', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        final cargando = snap.connectionState == ConnectionState.waiting;

        Color statusColor;
        String statusTexto;
        if (count == 0) {
          statusColor = Colors.white38;
          statusTexto = 'Gym vacío';
        } else if (count < 10) {
          statusColor = Colors.greenAccent;
          statusTexto = 'Poca concurrencia';
        } else if (count < 25) {
          statusColor = Colors.amberAccent;
          statusTexto = 'Concurrencia moderada';
        } else {
          statusColor = Colors.redAccent;
          statusTexto = 'Alta concurrencia';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.2),
                const Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
          ),
          child: Column(
            children: [
              // Indicador en vivo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: statusColor, blurRadius: 6)
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('EN VIVO',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Número grande
              cargando
                  ? const CircularProgressIndicator(color: Colors.orangeAccent)
                  : Text(
                      '$count',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 88,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                count == 1
                    ? 'persona dentro del gym'
                    : 'personas dentro del gym',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Badge de nivel
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                  border:
                      Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(statusTexto,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Lista de personas dentro del gym ─────────────────────────────────────────

class _ListaPersonasDentro extends StatelessWidget {
  const _ListaPersonasDentro();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('dentro_del_gym', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 8),
                const Text('Dentro ahora',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const Spacer(),
                Text('${docs.length} total',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            if (docs.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'No hay nadie en el gym en este momento.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = data['nombre'] ?? 'Sin nombre';
                final correo = data['correo'] ?? '';
                final ultimaEntrada =
                    data['ultima_entrada'] as Timestamp?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_gymnastics,
                            color: Colors.greenAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombre,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(correo,
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      if (ultimaEntrada != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Entró',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            Text(
                              _formatHora(ultimaEntrada.toDate()),
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Historial reciente de accesos ────────────────────────────────────────────

class _HistorialReciente extends StatelessWidget {
  const _HistorialReciente();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('visitas_gym')
          .orderBy('timestamp', descending: true)
          .limit(15)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.white54, size: 18),
                SizedBox(width: 8),
                Text('Actividad reciente',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),

            if (docs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Sin actividad registrada hoy.',
                      style: TextStyle(color: Colors.white38)),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = data['nombre_usuario'] ?? 'Usuario';
                final tipo = data['tipo'] ?? 'ENTRADA';
                final ts = data['timestamp'] as Timestamp?;
                final esEntrada = tipo == 'ENTRADA';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: esEntrada
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.orangeAccent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        esEntrada ? Icons.login : Icons.logout,
                        color: esEntrada
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$nombre ${esEntrada ? 'ingresó' : 'salió'}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      if (ts != null)
                        Text(
                          _formatHora(ts.toDate()),
                          style: TextStyle(
                              color: esEntrada
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
