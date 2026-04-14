import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ESCÁNER DE QR — Panel del admin (registra entradas y salidas)
// ═══════════════════════════════════════════════════════════════════════════════

class ScannerQrPage extends StatefulWidget {
  const ScannerQrPage({super.key});

  @override
  State<ScannerQrPage> createState() => _ScannerQrPageState();
}

class _ScannerQrPageState extends State<ScannerQrPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _procesando = false;
  String? _ultimoResultado;
  bool? _exitoUltimo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _procesarQr(String rawValue) async {
    if (_procesando) return;

    // Validar formato: ELITEFORM|uid|ENTRADA o SALIDA
    final partes = rawValue.split('|');
    if (partes.length != 3 || partes[0] != 'ELITEFORM') {
      _mostrarResultado('QR no reconocido. No es un código de EliteForm.', false);
      return;
    }

    final uid = partes[1];
    final tipo = partes[2]; // 'ENTRADA' o 'SALIDA'

    if (tipo != 'ENTRADA' && tipo != 'SALIDA') {
      _mostrarResultado('Tipo de QR inválido.', false);
      return;
    }

    setState(() => _procesando = true);
    await _controller.stop(); // Pausar cámara mientras procesa

    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuarios').doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        _mostrarResultado('Usuario no encontrado en el sistema.', false);
        return;
      }

      final data = docSnap.data()!;
      final nombre = data['nombre'] ?? 'Usuario desconocido';
      final membresiaActiva = data['membresia_activa'] == true;
      final dentroDelGym = data['dentro_del_gym'] == true;

      // Validar membresía
      if (!membresiaActiva) {
        _mostrarResultado(
            '$nombre no tiene membresía activa. Acceso denegado.', false);
        return;
      }

      // Validar lógica de entrada/salida
      if (tipo == 'ENTRADA' && dentroDelGym) {
        _mostrarResultado(
            '$nombre ya está dentro del gym. No puede escanear entrada de nuevo.',
            false);
        return;
      }

      if (tipo == 'SALIDA' && !dentroDelGym) {
        _mostrarResultado(
            '$nombre no está dentro del gym. No puede registrar salida.',
            false);
        return;
      }

      // Todo válido — actualizar Firestore
      final batch = FirebaseFirestore.instance.batch();

      if (tipo == 'ENTRADA') {
        batch.update(docRef, {
          'dentro_del_gym': true,
          'ultima_entrada': FieldValue.serverTimestamp(),
        });
        // Registrar en colección de visitas (historial)
        final visitaRef =
            FirebaseFirestore.instance.collection('visitas_gym').doc();
        batch.set(visitaRef, {
          'uid_usuario': uid,
          'nombre_usuario': nombre,
          'tipo': 'ENTRADA',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        batch.update(docRef, {
          'dentro_del_gym': false,
          'ultima_salida': FieldValue.serverTimestamp(),
        });
        final visitaRef =
            FirebaseFirestore.instance.collection('visitas_gym').doc();
        batch.set(visitaRef, {
          'uid_usuario': uid,
          'nombre_usuario': nombre,
          'tipo': 'SALIDA',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      final accion = tipo == 'ENTRADA' ? 'ingresó al' : 'salió del';
      _mostrarResultado('✓ $nombre $accion gym correctamente.', true);
    } catch (e) {
      _mostrarResultado('Error al procesar: $e', false);
    }
  }

  void _mostrarResultado(String mensaje, bool exito) {
    setState(() {
      _ultimoResultado = mensaje;
      _exitoUltimo = exito;
      _procesando = false;
    });

    // Reactivar cámara después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.start();
        setState(() {
          _ultimoResultado = null;
          _exitoUltimo = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR de acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _controller.switchCamera,
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(state.torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off);
              },
            ),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Cámara ────────────────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _procesarQr(barcode!.rawValue!);
              }
            },
          ),

          // ── Overlay: marco de escaneo ─────────────────────────────────────
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orangeAccent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Apunta al código QR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    backgroundColor: Colors.black45,
                  ),
                ),
              ),
            ),
          ),

          // ── Resultado del escaneo ─────────────────────────────────────────
          if (_ultimoResultado != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_exitoUltimo == true
                            ? Colors.greenAccent
                            : Colors.redAccent)
                        .withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _exitoUltimo == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: Colors.black87,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _ultimoResultado!,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Indicador de procesando ───────────────────────────────────────
          if (_procesando)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            ),
        ],
      ),
    );
  }
}
