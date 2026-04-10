import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// ─── EmptyState ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String sub;
  const EmptyState({
    super.key,
    required this.icono,
    required this.mensaje,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ChipFiltro ───────────────────────────────────────────────────────────────

class ChipFiltro extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;
  const ChipFiltro({
    super.key,
    required this.label,
    required this.icono,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              seleccionado ? color.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
              color: seleccionado ? color : Colors.white12,
              width: seleccionado ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: seleccionado ? color : Colors.white38, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? color : Colors.white54,
                fontSize: 12,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── InfoFila ─────────────────────────────────────────────────────────────────

class InfoFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color? valorColor;
  const InfoFila({
    super.key,
    required this.icono,
    required this.label,
    required this.valor,
    this.valorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.white38, size: 15),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
              color: valorColor ?? Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─── SeccionLabel ─────────────────────────────────────────────────────────────

class SeccionLabel extends StatelessWidget {
  final String titulo;
  const SeccionLabel({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
          color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}

// ─── CampoTexto ───────────────────────────────────────────────────────────────

class CampoTexto extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icono;
  final int maxLines;
  final TextInputType? keyboardType;
  const CampoTexto({
    super.key,
    required this.ctrl,
    required this.label,
    required this.icono,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
      ),
    );
  }
}

// ─── SliverTabBarDelegate ─────────────────────────────────────────────────────

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: const Color(0xFF0F172A), child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverTabBarDelegate old) =>
      tabBar != old.tabBar;
}

// ─── JsonImportTab ────────────────────────────────────────────────────────────
// Usa result.files.single.bytes para compatibilidad web + mobile

const String kJsonEjemploRutina = r'''
{
  "nombre_rutina": "Rutina de Fuerza 3 días",
  "objetivo": "Fuerza",
  "descripcion": "Rutina básica de fuerza para principiantes",
  "nivel": "Principiante",
  "dias_por_semana": 3,
  "musculos_principales": ["Pecho", "Espalda", "Piernas"],
  "dias": [
    {
      "nombre_dia": "Lunes - Pecho",
      "ejercicios": [
        {
          "nombre": "Press de banca",
          "musculo": "Pecho",
          "series": 4,
          "repeticiones": "8-10",
          "descanso": "90 seg",
          "notas": "Baja controlado"
        }
      ]
    }
  ]
}''';

const String kJsonEjemploDieta = r'''
{
  "nombre": "Dieta de Volumen",
  "calorias": 3000,
  "descripcion": "Plan calorico para ganar masa muscular",
  "objetivo": "Volumen",
  "nivel": "Intermedia",
  "preferencias_compatibles": ["Sin restricciones"],
  "comidas": [
    {
      "momento": "Desayuno",
      "descripcion": "Desayuno alto en proteinas",
      "calorias_aprox": 700,
      "alimentos": ["Avena", "Huevos", "Leche", "Platano"]
    }
  ]
}''';

/// Lee un archivo JSON seleccionado por el usuario.
/// Funciona en web (usa bytes) y mobile/desktop (usa bytes también).
/// Devuelve el Map parseado, o lanza Exception si hay error.
Future<Map<String, dynamic>> leerArchivoJson() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: true, // <-- CLAVE: carga los bytes en memoria (web + mobile)
  );
  if (result == null || result.files.isEmpty) {
    throw Exception('__cancelado__');
  }
  final bytes = result.files.single.bytes;
  if (bytes == null || bytes.isEmpty) {
    throw Exception('No se pudo leer el archivo. Intenta de nuevo.');
  }
  final content = utf8.decode(bytes);
  return jsonDecode(content) as Map<String, dynamic>;
}

class JsonImportTab extends StatelessWidget {
  final String tipo; // 'rutina' | 'dieta'
  final VoidCallback onImportar;
  final bool cargando;
  final String? error;
  const JsonImportTab({
    super.key,
    required this.tipo,
    required this.onImportar,
    required this.cargando,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final ejemplo = tipo == 'rutina' ? kJsonEjemploRutina : kJsonEjemploDieta;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.blueAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selecciona un archivo .json con la estructura de '
                    '${tipo == 'rutina' ? 'la rutina' : 'la dieta'} '
                    'para importarla directamente.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Estructura requerida del JSON:',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              ejemplo,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cargando ? null : onImportar,
              icon: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.upload_file),
              label:
                  Text(cargando ? 'Importando...' : 'Seleccionar archivo JSON'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ChipMusculo ──────────────────────────────────────────────────────────────

class ChipMusculo extends StatelessWidget {
  final String musculo;
  final Color color;
  const ChipMusculo({super.key, required this.musculo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(musculo,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── StatBox ──────────────────────────────────────────────────────────────────

class StatBox extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const StatBox(
      {super.key,
      required this.label,
      required this.valor,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── MiniStat ─────────────────────────────────────────────────────────────────

class MiniStat extends StatelessWidget {
  final String label;
  final String valor;
  const MiniStat({super.key, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

// ─── ChipPref ─────────────────────────────────────────────────────────────────

class ChipPref extends StatelessWidget {
  final String label;
  final Color color;
  const ChipPref({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── StatDieta ────────────────────────────────────────────────────────────────

class StatDieta extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;
  const StatDieta(
      {super.key,
      required this.valor,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

// ─── MacroBar ─────────────────────────────────────────────────────────────────

class MacroBar extends StatelessWidget {
  final String label;
  final int gramos;
  final Color color;
  final double porcentaje;
  const MacroBar(
      {super.key,
      required this.label,
      required this.gramos,
      required this.color,
      required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('~${gramos}g',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: Colors.white12,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
