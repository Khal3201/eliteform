import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../pages/aviso_privacidad_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGET DE CONSENTIMIENTO
// Muestra 3 casillas antes de permitir crear una cuenta:
//   1. Acepta aviso de privacidad         (OBLIGATORIA)
//   2. Acepta tratamiento de datos        (OBLIGATORIA)
//   3. Acepta notificaciones              (OPCIONAL)
//
// Uso en register_page.dart:
//   ConsentimientoWidget(onChanged: (valido) => setState(() => _consentimientoValido = valido))
// ═══════════════════════════════════════════════════════════════════════════════

class ConsentimientoWidget extends StatefulWidget {
  /// Callback que recibe `true` cuando las dos casillas obligatorias están marcadas.
  final ValueChanged<bool> onChanged;

  const ConsentimientoWidget({super.key, required this.onChanged});

  @override
  State<ConsentimientoWidget> createState() => _ConsentimientoWidgetState();
}

class _ConsentimientoWidgetState extends State<ConsentimientoWidget> {
  bool _aceptaAviso = false;
  bool _aceptaTratamiento = false;
  bool _aceptaNotificaciones = false; // opcional

  void _actualizar() {
    widget.onChanged(_aceptaAviso && _aceptaTratamiento);
  }

  void _abrirAviso() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AvisoPrivacidadPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: const [
              Icon(Icons.privacy_tip, color: Colors.orangeAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'Consentimiento y privacidad',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Casilla 1: Aviso de privacidad (OBLIGATORIA) ──────────────────
          _CasillaConsentimiento(
            valor: _aceptaAviso,
            onChanged: (v) {
              setState(() => _aceptaAviso = v ?? false);
              _actualizar();
            },
            obligatoria: true,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                children: [
                  const TextSpan(text: 'He leído y acepto el '),
                  TextSpan(
                    text: 'Aviso de Privacidad',
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()..onTap = _abrirAviso,
                  ),
                  const TextSpan(text: ' de EliteForm.'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Casilla 2: Tratamiento de datos (OBLIGATORIA) ─────────────────
          _CasillaConsentimiento(
            valor: _aceptaTratamiento,
            onChanged: (v) {
              setState(() => _aceptaTratamiento = v ?? false);
              _actualizar();
            },
            obligatoria: true,
            child: const Text(
              'Acepto que mis datos (nombre, correo, teléfono, asistencia al gimnasio) '
              'sean tratados para gestionar mi cuenta y membresía.',
              style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
            ),
          ),

          const SizedBox(height: 8),

          // ── Casilla 3: Notificaciones (OPCIONAL) ──────────────────────────
          _CasillaConsentimiento(
            valor: _aceptaNotificaciones,
            onChanged: (v) {
              setState(() => _aceptaNotificaciones = v ?? false);
              // No llama a _actualizar() porque es opcional
            },
            obligatoria: false,
            child: const Text(
              '(Opcional) Acepto recibir notificaciones sobre mi membresía, '
              'renovaciones y eventos del gimnasio.',
              style: TextStyle(color: Colors.white54, fontSize: 12.5, height: 1.4),
            ),
          ),

          const SizedBox(height: 10),

          // Nota explicativa
          const Text(
            '* Las dos primeras casillas son obligatorias para crear tu cuenta. '
            'La tercera es opcional y puedes revocarla desde Perfil en cualquier momento.',
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── Casilla individual ───────────────────────────────────────────────────────

class _CasillaConsentimiento extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool?> onChanged;
  final bool obligatoria;
  final Widget child;

  const _CasillaConsentimiento({
    required this.valor,
    required this.onChanged,
    required this.obligatoria,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.orangeAccent,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white38, width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              if (obligatoria)
                const Text(
                  '* Obligatorio',
                  style: TextStyle(
                      color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
