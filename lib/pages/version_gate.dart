import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../config/app_version.dart';

class VersionGate extends StatelessWidget {
  final Widget child;

  const VersionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('config')
          .doc('version')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _CargandoScreen();
        }

        if (!snap.hasData || !snap.data!.exists) {
          return child;
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final versionMinima = data['version_minima'] as String? ?? '1.0.0';
        final mensaje = data['mensaje'] as String? ??
            'Esta versión de EliteForm ya no es compatible. Por favor actualiza la aplicación para continuar.';
        final urlTienda = data['url_tienda'] as String?;

        if (versionMayorOIgual(kVersionActual, versionMinima)) {
          return child;
        }

        return _PantallaActualizacion(
          versionActual: kVersionActual,
          versionMinima: versionMinima,
          mensaje: mensaje,
          urlTienda: urlTienda,
        );
      },
    );
  }
}

class _CargandoScreen extends StatelessWidget {
  const _CargandoScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      ),
    );
  }
}

class _PantallaActualizacion extends StatelessWidget {
  final String versionActual;
  final String versionMinima;
  final String mensaje;
  final String? urlTienda;

  const _PantallaActualizacion({
    required this.versionActual,
    required this.versionMinima,
    required this.mensaje,
    this.urlTienda,
  });

  Future<void> _abrirUrl(BuildContext context) async {
    if (urlTienda == null || urlTienda!.isEmpty) return;

    final uri = Uri.tryParse(urlTienda!);
    if (uri == null) {
      _mostrarSnack(context, 'URL inválida');
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      _mostrarSnack(context, 'No se pudo abrir la tienda');
    }
  }

  Future<void> _copiarUrl(BuildContext context) async {
    if (urlTienda == null || urlTienda!.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: urlTienda!));
    _mostrarSnack(context, 'Enlace copiado');
  }

  void _mostrarSnack(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111827),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hayUrl = urlTienda != null && urlTienda!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 25,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orangeAccent.withOpacity(0.25),
                            Colors.deepOrange.withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.35),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.system_update_alt_rounded,
                        color: Colors.orangeAccent,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Actualización requerida',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _VersionCard(
                            titulo: 'Tu versión',
                            version: versionActual,
                            color: Colors.redAccent,
                            icon: Icons.close_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _VersionCard(
                            titulo: 'Versión mínima',
                            version: versionMinima,
                            color: Colors.greenAccent,
                            icon: Icons.check_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (hayUrl) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enlace de actualización',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              urlTienda!,
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirUrl(context),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text(
                            'Abrir tienda',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _copiarUrl(context),
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copiar enlace'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white12),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'EliteForm • v$versionActual',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String titulo;
  final String version;
  final Color color;
  final IconData icon;

  const _VersionCard({
    required this.titulo,
    required this.version,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'v$version',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}