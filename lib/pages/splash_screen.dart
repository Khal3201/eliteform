import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'admin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controladores de animación ────────────────────────────────────────────
  late AnimationController _plateController; // platos entrando
  late AnimationController _barController; // barra aparece
  late AnimationController _glowController; // pulso naranja
  late AnimationController _textController; // texto sube
  late AnimationController _exitController; // salida de pantalla

  // Plates: entran desde los lados
  late Animation<double> _leftPlateX;
  late Animation<double> _rightPlateX;
  late Animation<double> _plateScale;

  // Bar: fade + scale
  late Animation<double> _barOpacity;
  late Animation<double> _barScaleX;

  // Glow pulsante
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // Texto
  late Animation<double> _textY;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;

  // Exit
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // 1. Platos (800ms)
    _plateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _leftPlateX = Tween<double>(begin: -180, end: 0).animate(
        CurvedAnimation(parent: _plateController, curve: Curves.elasticOut));
    _rightPlateX = Tween<double>(begin: 180, end: 0).animate(
        CurvedAnimation(parent: _plateController, curve: Curves.elasticOut));
    _plateScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _plateController, curve: Curves.easeOut));

    // 2. Barra (500ms)
    _barController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _barOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _barController, curve: Curves.easeIn));
    _barScaleX = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _barController, curve: Curves.easeOut));

    // 3. Glow (loop)
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _glowScale = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // 4. Texto (600ms)
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textY = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));

    // 5. Salida (400ms)
    _exitController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _exitScale = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 1. Platos entran
    await _plateController.forward();

    // 2. Barra aparece al mismo tiempo que los platos terminan
    await _barController.forward();

    // 3. Glow pulsa (loop) + texto aparece simultáneamente
    _glowController.repeat(reverse: true);
    await _textController.forward();

    // 4. Esperar un momento con todo visible
    await Future.delayed(const Duration(milliseconds: 1200));

    // 5. Salida con fade
    await _exitController.forward();

    // 6. Navegar
    if (mounted) _navigate();
  }

  void _navigate() {
    final user = FirebaseAuth.instance.currentUser;
    Widget dest;
    if (user == null) {
      dest = const LoginPage();
    } else if (user.email == 'admin@admin.com') {
      dest = const AdminPage();
    } else {
      dest = const HomePage();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _barController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _plateController,
        _barController,
        _glowController,
        _textController,
        _exitController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              backgroundColor: const Color(0xFF020617),
              body: Stack(
                children: [
                  // ── Fondo: partículas decorativas ──────────────────────
                  const _BackgroundParticles(),

                  // ── Fondo: líneas de velocidad ──────────────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter:
                          _SpeedLinesPainter(progress: _barController.value),
                    ),
                  ),

                  // ── Centro: barbell + glow ──────────────────────────────
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glow detrás de la mancuerna
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow pulsante
                            Transform.scale(
                              scale: _glowScale.value,
                              child: Opacity(
                                opacity: _glowOpacity.value,
                                child: Container(
                                  width: 280,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF8C00)
                                            .withOpacity(0.5),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Barra central
                            Opacity(
                              opacity: _barOpacity.value,
                              child: Transform.scale(
                                scaleX: _barScaleX.value,
                                child: const _BarbellBar(),
                              ),
                            ),

                            // Plato izquierdo
                            Transform.translate(
                              offset: Offset(_leftPlateX.value, 0),
                              child: Transform.scale(
                                scale: _plateScale.value,
                                child: const _PlateGroup(isLeft: true),
                              ),
                            ),

                            // Plato derecho
                            Transform.translate(
                              offset: Offset(_rightPlateX.value, 0),
                              child: Transform.scale(
                                scale: _plateScale.value,
                                child: const _PlateGroup(isLeft: false),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // ── Texto: ELITE FORM ────────────────────────────
                        Transform.translate(
                          offset: Offset(0, _textY.value),
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                // EF monogram
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFFFB347),
                                          Color(0xFFFF8C00),
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'ELITE',
                                        style: TextStyle(
                                          fontSize: 52,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 6,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'FORM',
                                      style: TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 6,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Línea decorativa
                                Opacity(
                                  opacity: _taglineOpacity.value,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 1.5,
                                        color: const Color(0xFFFF8C00)
                                            .withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'ENTRENA · MEJORA · SUPERA',
                                        style: TextStyle(
                                          color: Color(0xFFFF8C00),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 40,
                                        height: 1.5,
                                        color: const Color(0xFFFF8C00)
                                            .withOpacity(0.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Barra de carga en la parte inferior ─────────────────
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child: Column(
                        children: [
                          const Text(
                            'Cargando...',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white12,
                                  color: const Color(0xFFFF8C00),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BARRA DE LA MANCUERNA
// ═══════════════════════════════════════════════════════════════════════════════

class _BarbellBar extends StatelessWidget {
  const _BarbellBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFCC7700),
            Color(0xFFFFB347),
            Color(0xFFFF8C00),
            Color(0xFFFFB347),
            Color(0xFFCC7700),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      // Brillo en la parte superior de la barra
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRUPO DE PLATOS (izquierdo o derecho)
// ═══════════════════════════════════════════════════════════════════════════════

class _PlateGroup extends StatelessWidget {
  final bool isLeft;
  const _PlateGroup({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final offset = isLeft ? -110.0 : 110.0;
    return Transform.translate(
      offset: Offset(offset, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                _Plate(width: 22, height: 68),
                const SizedBox(width: 3),
                _Plate(width: 14, height: 54),
                const SizedBox(width: 3),
                _Collar(),
              ]
            : [
                _Collar(),
                const SizedBox(width: 3),
                _Plate(width: 14, height: 54),
                const SizedBox(width: 3),
                _Plate(width: 22, height: 68),
              ],
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  final double width;
  final double height;
  const _Plate({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9A2E),
            Color(0xFFCC5500),
            Color(0xFF993D00),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _Collar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: const Color(0xFFFFB347),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PARTÍCULAS DE FONDO
// ═══════════════════════════════════════════════════════════════════════════════

class _BackgroundParticles extends StatelessWidget {
  const _BackgroundParticles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(),
      size: Size.infinite,
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Puntos decorativos esparcidos
    final positions = [
      [0.1, 0.2],
      [0.9, 0.15],
      [0.05, 0.7],
      [0.95, 0.8],
      [0.2, 0.9],
      [0.8, 0.92],
      [0.15, 0.45],
      [0.85, 0.5],
      [0.3, 0.08],
      [0.7, 0.05],
      [0.5, 0.95],
      [0.45, 0.02],
    ];
    for (final pos in positions) {
      paint.color = const Color(0xFFFF8C00).withOpacity(0.15);
      canvas.drawCircle(
          Offset(size.width * pos[0], size.height * pos[1]), 3, paint);
    }

    // Líneas diagonales de fondo (grid industrial)
    final linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 40) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// LÍNEAS DE VELOCIDAD (se dibujan cuando la barra aparece)
// ═══════════════════════════════════════════════════════════════════════════════

class _SpeedLinesPainter extends CustomPainter {
  final double progress;
  _SpeedLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;
    final paint = Paint()..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Líneas horizontales que se expanden desde el centro
    final lineData = [
      [cy - 60.0, 0.9],
      [cy - 40.0, 0.6],
      [cy - 20.0, 0.4],
      [cy, 0.3],
      [cy + 20.0, 0.4],
      [cy + 40.0, 0.6],
      [cy + 60.0, 0.9],
    ];

    for (final ld in lineData) {
      final y = ld[0];
      final opacity = ld[1] * progress * 0.3;
      final lineLen = 80.0 * progress;

      paint.color = const Color(0xFFFF8C00).withOpacity(opacity);
      // izquierda
      canvas.drawLine(
          Offset(cx - 120 - lineLen, y), Offset(cx - 120, y), paint);
      // derecha
      canvas.drawLine(
          Offset(cx + 120, y), Offset(cx + 120 + lineLen, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter old) =>
      old.progress != progress;
}
