import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CHATBOT PAGE — Respuestas predeterminadas desde Firestore
// ═══════════════════════════════════════════════════════════════════════════════

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_Mensaje> _mensajes = [];
  List<Map<String, dynamic>> _respuestas = [];
  bool _cargandoRespuestas = true;

  static const String _msgBienvenida =
      '¡Hola! Soy el asistente de EliteForm 💪\n\n'
      'Puedo ayudarte con:\n'
      '• Horarios del gimnasio\n'
      '• Membresías, precios y pagos\n'
      '• Rutinas, ejercicios y técnica básica\n'
      '• Nutrición y recomendaciones generales\n'
      '• Contacto\n\n'
      'Escribe tu pregunta y te respondo con lo que tengo guardado.';

  static const Map<String, List<String>> _intenciones = {
    'precio': [
      'precio', 'precios', 'barata', 'barato', 'económica', 'economica',
      'costo', 'coste', 'membresia', 'membresía', 'mensualidad', 'plan',
      'promocion', 'promoción', 'oferta', 'descuento'
    ],
    'rutina': [
      'rutina', 'rutinas', 'entrenamiento', 'ejercicio', 'ejercicios',
      'musculo', 'músculo', 'pecho', 'espalda', 'piernas', 'hombros',
      'biceps', 'bíceps', 'triceps', 'tríceps', 'abdomen', 'gluteos', 'glúteos'
    ],
    'nutricion': [
      'nutricion', 'nutrición', 'dieta', 'dieta', 'comida', 'comer',
      'proteina', 'proteína', 'carbohidratos', 'grasas', 'calorias',
      'calorías', 'volumen', 'definicion', 'definición', 'peso'
    ],
    'horario': [
      'horario', 'horarios', 'hora', 'abren', 'abierto', 'cierran',
      'cierra', 'apertura', 'cerramos', 'atencion', 'atención'
    ],
    'ubicacion': [
      'ubicacion', 'ubicación', 'direccion', 'dirección', 'donde',
      'dónde', 'estan', 'están', 'lugar', 'sucursal', 'mapa'
    ],
  };

  @override
  void initState() {
    super.initState();
    _mensajes.add(_Mensaje(texto: _msgBienvenida, esBot: true));
    _cargarRespuestas();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarRespuestas() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('chatbot_respuestas')
          .orderBy('orden')
          .get();

      if (!mounted) return;

      setState(() {
        _respuestas = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _cargandoRespuestas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoRespuestas = false;
      });
    }
  }
String _normalizarTexto(String texto) {
  texto = texto.toLowerCase().trim();

  const mapa = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };

  mapa.forEach((original, reemplazo) {
    texto = texto.replaceAll(original, reemplazo);
  });

  texto = texto.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  texto = texto.replaceAll(RegExp(r'\s+'), ' ').trim();

  return texto;
}


List<String> _tokenizar(String texto) {
  if (texto.isEmpty) return [];
  return texto
      .split(' ')
      .map(_simplificarPalabra)
      .where((e) => e.isNotEmpty)
      .toList();
}

String _simplificarPalabra(String palabra) {
  palabra = palabra.toLowerCase().trim();

  if (palabra.length > 4 && palabra.endsWith('es')) {
    palabra = palabra.substring(0, palabra.length - 2);
  } else if (palabra.length > 3 && palabra.endsWith('s')) {
    palabra = palabra.substring(0, palabra.length - 1);
  }

  return palabra;
}

bool _sonParecidas(String a, String b) {
  if (a == b) return true;
  if (a.isEmpty || b.isEmpty) return false;

  final minLen = a.length < b.length ? a.length : b.length;
  if (minLen < 4) return false;

  // Coincidencia parcial razonable
  if (a.contains(b) || b.contains(a)) return true;

  // Comparación simple por prefijo
  final prefijo = minLen >= 4 ? 4 : minLen;
  return a.substring(0, prefijo) == b.substring(0, prefijo);
}

String _buscarRespuesta(String pregunta) {
  final preguntaNorm = _normalizarTexto(pregunta);
  final tokensPregunta = _tokenizar(preguntaNorm);

  final categoria = _detectarIntencion(preguntaNorm, tokensPregunta);

  Map<String, dynamic>? mejor;
  int mejorPuntaje = -999999;
  int mejorOrden = 999999;

  for (final r in _respuestas) {
    final titulo = _normalizarTexto((r['titulo'] ?? '').toString());
    final respuesta = (r['respuesta'] ?? '').toString();
    final keywords = List<String>.from(r['palabras_clave'] ?? []);
    final orden = (r['orden'] is int) ? r['orden'] as int : 999999;

    // Si tus docs ya tienen categoria, úsala. Si no, igual funciona por keywords.
    final categoriaDoc = _normalizarTexto((r['categoria'] ?? '').toString());

    int puntaje = 0;

    // 1) Prioridad fuerte por intención detectada
    if (categoria != null) {
      if (categoriaDoc == categoria) {
        puntaje += 120;
      } else if (categoriaDoc.isNotEmpty) {
        puntaje -= 35;
      }

      // Bonus extra si el título de la respuesta coincide con la intención
      if (titulo.contains(categoria)) {
        puntaje += 25;
      }
    }

    // 2) Título
    if (titulo.isNotEmpty) {
      if (preguntaNorm == titulo) puntaje += 100;
      if (preguntaNorm.contains(titulo)) puntaje += 55;
      puntaje += _puntajePorTokens(tokensPregunta, _tokenizar(titulo), 14);
    }

    // 3) Palabras clave
    for (final clave in keywords) {
      final claveNorm = _normalizarTexto(clave);
      if (claveNorm.isEmpty) continue;

      if (preguntaNorm == claveNorm) puntaje += 90;
      if (preguntaNorm.contains(claveNorm)) puntaje += 40;

      puntaje += _puntajePorTokens(tokensPregunta, _tokenizar(claveNorm), 18);
    }

    // 4) Bonus por contenido de respuesta según intención
    if (categoria != null) {
      final respuestaNorm = _normalizarTexto(respuesta);
      final palabrasCategoria = _intenciones[categoria] ?? [];
      for (final palabra in palabrasCategoria) {
        if (respuestaNorm.contains(_normalizarTexto(palabra))) {
          puntaje += 3;
        }
      }
    }

    final esMejor = puntaje > mejorPuntaje ||
        (puntaje == mejorPuntaje && orden < mejorOrden);

    if (esMejor) {
      mejorPuntaje = puntaje;
      mejorOrden = orden;
      mejor = r;
    }
  }

  if (mejor != null && mejorPuntaje >= 30) {
    return (mejor['respuesta'] ?? 'No tengo información sobre eso.').toString();
  }

  return 'No encontré una respuesta segura para eso. 😕\n\n'
      'Prueba con otra forma de escribirlo o usa una pregunta más específica.';
}

String? _detectarIntencion(String preguntaNorm, List<String> tokensPregunta) {
  String? mejorCategoria;
  int mejorPuntaje = 0;

  _intenciones.forEach((categoria, palabras) {
    int puntaje = 0;

    for (final palabra in palabras) {
      final palabraNorm = _normalizarTexto(palabra);
      if (preguntaNorm.contains(palabraNorm)) {
        puntaje += 4;
      }

      final tokensPalabra = _tokenizar(palabraNorm);
      for (final tp in tokensPregunta) {
        for (final tk in tokensPalabra) {
          if (tp == tk) {
            puntaje += 6;
          } else if (_sonParecidas(tp, tk)) {
            puntaje += 2;
          }
        }
      }
    }

    if (puntaje > mejorPuntaje) {
      mejorPuntaje = puntaje;
      mejorCategoria = categoria;
    }
  });

  return mejorPuntaje >= 6 ? mejorCategoria : null;
}

int _puntajePorTokens(
  List<String> tokensPregunta,
  List<String> tokensClave,
  int pesoBase,
) {
  if (tokensPregunta.isEmpty || tokensClave.isEmpty) return 0;

  int puntaje = 0;

  for (final tk in tokensClave) {
    final tkSimple = _simplificarPalabra(tk);

    for (final tp in tokensPregunta) {
      final tpSimple = _simplificarPalabra(tp);

      if (tkSimple == tpSimple) {
        puntaje += pesoBase;
      } else if (_sonParecidas(tkSimple, tpSimple)) {
        puntaje += (pesoBase ~/ 2);
      }
    }
  }

  return puntaje;
}


  void _enviar() {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add(_Mensaje(texto: texto, esBot: false));
    });
    _ctrl.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final respuesta = _buscarRespuesta(texto);
      setState(() {
        _mensajes.add(_Mensaje(texto: respuesta, esBot: true));
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollAbajo);
    });

    _scrollAbajo();
  }

  void _scrollAbajo() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.smart_toy,
                      color: Colors.orangeAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Asistente EliteForm',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Siempre disponible',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                      SizedBox(width: 5),
                      Text('En línea',
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Mensajes
          Expanded(
            child: _cargandoRespuestas
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.orangeAccent))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensajes.length,
                    itemBuilder: (_, i) =>
                        _BurbujaMensaje(mensaje: _mensajes[i]),
                  ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _enviar(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _enviar,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.black, size: 20),
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

class _Mensaje {
  final String texto;
  final bool esBot;
  _Mensaje({required this.texto, required this.esBot});
}

class _BurbujaMensaje extends StatelessWidget {
  final _Mensaje mensaje;
  const _BurbujaMensaje({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final esBot = mensaje.esBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            esBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (esBot) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy,
                  color: Colors.orangeAccent, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esBot
                    ? const Color(0xFF1E293B)
                    : Colors.orangeAccent.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esBot ? 4 : 16),
                  bottomRight: Radius.circular(esBot ? 16 : 4),
                ),
                border: esBot
                    ? Border.all(color: Colors.white12)
                    : null,
              ),
              child: Text(
                mensaje.texto,
                style: TextStyle(
                  color: esBot ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!esBot) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: Colors.white54, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
