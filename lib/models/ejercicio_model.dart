// ─── ejercicio_model.dart ─────────────────────────────────────────────────────

class EjercicioModel {
  final String id;
  final String nombre;
  final String musculo; // grupo muscular principal
  final String categoria; // Fuerza, Cardio, Flexibilidad, etc.
  final String nivel; // Principiante, Intermedio, Avanzado
  final String descripcion;
  final String? instrucciones;
  final List<String> equipamiento; // Barra, Mancuernas, Máquina, etc.
  final String creadoPor; // 'admin' | uid

  EjercicioModel({
    required this.id,
    required this.nombre,
    required this.musculo,
    required this.categoria,
    required this.nivel,
    required this.descripcion,
    this.instrucciones,
    required this.equipamiento,
    required this.creadoPor,
  });

  factory EjercicioModel.fromMap(String id, Map<String, dynamic> data) {
    return EjercicioModel(
      id: id,
      nombre: data['nombre'] ?? '',
      musculo: data['musculo'] ?? '',
      categoria: data['categoria'] ?? 'Fuerza',
      nivel: data['nivel'] ?? 'Principiante',
      descripcion: data['descripcion'] ?? '',
      instrucciones: data['instrucciones'],
      equipamiento: List<String>.from(data['equipamiento'] ?? []),
      creadoPor: data['creado_por'] ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'musculo': musculo,
        'categoria': categoria,
        'nivel': nivel,
        'descripcion': descripcion,
        if (instrucciones != null) 'instrucciones': instrucciones,
        'equipamiento': equipamiento,
        'creado_por': creadoPor,
      };
}