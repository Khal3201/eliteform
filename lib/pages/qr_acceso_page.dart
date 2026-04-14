import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/firestore_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PÁGINA QR DE ACCESO AL GYM
// ═══════════════════════════════════════════════════════════════════════════════

class QrAccesoPage extends StatelessWidget {
  const QrAccesoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || !snap.data!.exists) {
          return const Center(
              child: Text('Error al cargar perfil',
                  style: TextStyle(color: Colors.white54)));
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final membresiaActiva = data['membresia_activa'] == true;
        final dentroDelGym = data['dentro_del_gym'] == true;
        final nombre = data['nombre'] ?? 'Usuario';

        // Sin membresía activa: bloquear QR
        if (!membresiaActiva) {
          return _SinMembresia(nombre: nombre);
        }

        return _QrView(
          uid: user.uid,
          nombre: nombre,
          dentroDelGym: dentroDelGym,
        );
      },
    );
  }
}

// ─── Vista: sin membresía ─────────────────────────────────────────────────────

class _SinMembresia extends StatelessWidget {
  final String nombre;
  const _SinMembresia({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.redAccent.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.qr_code_2,
                  color: Colors.redAccent, size: 64),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sin acceso al QR',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Necesitas una membresía activa para generar\ntu código QR de acceso al gym.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar a planes — el usuario sabe dónde ir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ve a la sección "Planes" para suscribirte'),
                      backgroundColor: Colors.orangeAccent),
                );
              },
              icon: const Icon(Icons.card_membership),
              label: const Text('Ver planes disponibles'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vista: QR activo ─────────────────────────────────────────────────────────

class _QrView extends StatefulWidget {
  final String uid;
  final String nombre;
  final bool dentroDelGym;

  const _QrView({
    required this.uid,
    required this.nombre,
    required this.dentroDelGym,
  });

  @override
  State<_QrView> createState() => _QrViewState();
}

class _QrViewState extends State<_QrView> {
  // true = mostrando QR de ENTRADA, false = mostrando QR de SALIDA
  late bool _mostrandoEntrada;

  @override
  void initState() {
    super.initState();
    // Si ya está dentro del gym, mostrar QR de salida por defecto
    _mostrandoEntrada = !widget.dentroDelGym;
  }

  @override
  void didUpdateWidget(covariant _QrView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar automáticamente si cambia el estatus
    if (oldWidget.dentroDelGym != widget.dentroDelGym) {
      _mostrandoEntrada = !widget.dentroDelGym;
    }
  }

  // El dato que se codifica en el QR
  // Formato: "ELITEFORM|uid|tipo"
  // tipo: ENTRADA o SALIDA
  String get _qrData {
    final tipo = _mostrandoEntrada ? 'ENTRADA' : 'SALIDA';
    return 'ELITEFORM|${widget.uid}|$tipo';
  }

  Color get _colorActual =>
      _mostrandoEntrada ? Colors.greenAccent : Colors.orangeAccent;

  IconData get _iconoActual =>
      _mostrandoEntrada ? Icons.login : Icons.logout;

  String get _etiquetaActual =>
      _mostrandoEntrada ? 'ENTRADA' : 'SALIDA';

  @override
  Widget build(BuildContext context) {
    // Si ya está dentro: solo mostrar salida (bloquear entrada)
    // Si está fuera: solo mostrar entrada (bloquear salida)
    final qrBloqueado =
        (widget.dentroDelGym && _mostrandoEntrada) ||
        (!widget.dentroDelGym && !_mostrandoEntrada);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Estatus actual ──────────────────────────────────────────────
          _EstatusBadge(dentroDelGym: widget.dentroDelGym),
          const SizedBox(height: 24),

          // ── Tarjeta del QR ──────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: qrBloqueado
                    ? Colors.white12
                    : _colorActual.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: qrBloqueado
                  ? []
                  : [
                      BoxShadow(
                        color: _colorActual.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 4,
                      )
                    ],
            ),
            child: Column(
              children: [
                // Etiqueta tipo de QR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconoActual,
                        color: qrBloqueado ? Colors.white24 : _colorActual,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'QR de $_etiquetaActual',
                      style: TextStyle(
                        color: qrBloqueado ? Colors.white24 : _colorActual,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // QR o mensaje de bloqueado
                if (qrBloqueado)
                  _QrBloqueado(dentroDelGym: widget.dentroDelGym, esEntrada: _mostrandoEntrada)
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Muestra este código en recepción',
                        style: TextStyle(
                            color: _colorActual.withOpacity(0.8),
                            fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Botón toggle entrada/salida ──────────────────────────────────
          _ToggleButton(
            mostrandoEntrada: _mostrandoEntrada,
            dentroDelGym: widget.dentroDelGym,
            onToggle: () => setState(() => _mostrandoEntrada = !_mostrandoEntrada),
          ),
          const SizedBox(height: 20),

          // ── Info / instrucciones ─────────────────────────────────────────
          _InfoPanel(dentroDelGym: widget.dentroDelGym),
        ],
      ),
    );
  }
}

// ─── Badge de estatus ─────────────────────────────────────────────────────────

class _EstatusBadge extends StatelessWidget {
  final bool dentroDelGym;
  const _EstatusBadge({required this.dentroDelGym});

  @override
  Widget build(BuildContext context) {
    final color = dentroDelGym ? Colors.greenAccent : Colors.white38;
    final texto = dentroDelGym ? 'Estás dentro del gym' : 'Estás fuera del gym';
    final icono = dentroDelGym ? Icons.sports_gymnastics : Icons.home_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 10),
          Text(texto,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── QR bloqueado ─────────────────────────────────────────────────────────────

class _QrBloqueado extends StatelessWidget {
  final bool dentroDelGym;
  final bool esEntrada;
  const _QrBloqueado({required this.dentroDelGym, required this.esEntrada});

  @override
  Widget build(BuildContext context) {
    String mensaje;
    if (dentroDelGym && esEntrada) {
      mensaje = 'Ya estás dentro del gym.\nUsa el QR de Salida para registrar tu salida.';
    } else {
      mensaje = 'No estás dentro del gym.\nUsa el QR de Entrada para ingresar.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.block, color: Colors.white24, size: 72),
          const SizedBox(height: 16),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white38, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Botón toggle ─────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final bool mostrandoEntrada;
  final bool dentroDelGym;
  final VoidCallback onToggle;

  const _ToggleButton({
    required this.mostrandoEntrada,
    required this.dentroDelGym,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _TabBtn(
            label: 'QR Entrada',
            icono: Icons.login,
            activo: mostrandoEntrada,
            color: Colors.greenAccent,
            onTap: mostrandoEntrada ? null : onToggle,
          ),
          _TabBtn(
            label: 'QR Salida',
            icono: Icons.logout,
            activo: !mostrandoEntrada,
            color: Colors.orangeAccent,
            onTap: !mostrandoEntrada ? null : onToggle,
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool activo;
  final Color color;
  final VoidCallback? onTap;

  const _TabBtn({
    required this.label,
    required this.icono,
    required this.activo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: activo ? color.withOpacity(0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono,
                  color: activo ? color : Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: activo ? color : Colors.white38,
                      fontWeight: activo
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Panel de información ─────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final bool dentroDelGym;
  const _InfoPanel({required this.dentroDelGym});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
              SizedBox(width: 8),
              Text('¿Cómo funciona?',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          _InfoItem(
              icono: Icons.login,
              texto: 'Muestra el QR de Entrada al llegar al gym',
              color: Colors.greenAccent),
          const SizedBox(height: 6),
          _InfoItem(
              icono: Icons.logout,
              texto: 'Muestra el QR de Salida al irte',
              color: Colors.orangeAccent),
          const SizedBox(height: 6),
          _InfoItem(
              icono: Icons.admin_panel_settings,
              texto: 'El staff escanea tu QR en recepción',
              color: Colors.white54),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  const _InfoItem(
      {required this.icono, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
            child: Text(texto,
                style: const TextStyle(color: Colors.white54, fontSize: 12))),
      ],
    );
  }
}
