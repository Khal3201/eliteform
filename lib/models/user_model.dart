// ─── user_model.dart ──────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? idRutinaActiva;
  final String? idDietaActiva;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.idRutinaActiva,
    this.idDietaActiva,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data["id_usuario"] ?? '',
      nombre: data["nombre"] ?? '',
      correo: data["correo"] ?? '',
      telefono: data["telefono"] ?? '',
      idRutinaActiva: data["id_rutina_activa"],
      idDietaActiva: data["id_dieta_activa"],
    );
  }
}

// ─── Rutina ───────────────────────────────────────────────────────────────────

class RutinaModel {
  final String id;
  final String nombreRutina;
  final String objetivo; // Fuerza, Volumen, Resistencia, Definición, Movilidad
  final String descripcion;
  final List<String> musculosPrincipales;
  final String nivel; // Principiante, Intermedio, Avanzado
  final int diasPorSemana;
  final String creadoPor; // 'admin' | uid del usuario
  final List<DiaRutinaModel> dias;

  RutinaModel({
    required this.id,
    required this.nombreRutina,
    required this.objetivo,
    required this.descripcion,
    required this.musculosPrincipales,
    required this.nivel,
    required this.diasPorSemana,
    required this.creadoPor,
    required this.dias,
  });

  factory RutinaModel.fromMap(String id, Map<String, dynamic> data) {
    final diasRaw = data['dias'] as List<dynamic>? ?? [];
    return RutinaModel(
      id: id,
      nombreRutina: data['nombre_rutina'] ?? '',
      objetivo: data['objetivo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      musculosPrincipales:
          List<String>.from(data['musculos_principales'] ?? []),
      nivel: data['nivel'] ?? 'Principiante',
      diasPorSemana: data['dias_por_semana'] ?? 3,
      creadoPor: data['creado_por'] ?? 'admin',
      dias: diasRaw
          .map((d) => DiaRutinaModel.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre_rutina': nombreRutina,
        'objetivo': objetivo,
        'descripcion': descripcion,
        'musculos_principales': musculosPrincipales,
        'nivel': nivel,
        'dias_por_semana': diasPorSemana,
        'creado_por': creadoPor,
        'dias': dias.map((d) => d.toMap()).toList(),
      };
}

class DiaRutinaModel {
  final String nombreDia; // Ej: "Lunes - Pecho y Tríceps"
  final List<EjercicioRutinaModel> ejercicios;

  DiaRutinaModel({required this.nombreDia, required this.ejercicios});

  factory DiaRutinaModel.fromMap(Map<String, dynamic> data) {
    final ejsRaw = data['ejercicios'] as List<dynamic>? ?? [];
    return DiaRutinaModel(
      nombreDia: data['nombre_dia'] ?? '',
      ejercicios: ejsRaw
          .map((e) => EjercicioRutinaModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre_dia': nombreDia,
        'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
      };
}

class EjercicioRutinaModel {
  final String nombre;
  final String musculo;
  final int series;
  final String repeticiones; // "10-12" o "Al fallo"
  final String descanso; // "60 seg"
  final String? notas;

  EjercicioRutinaModel({
    required this.nombre,
    required this.musculo,
    required this.series,
    required this.repeticiones,
    required this.descanso,
    this.notas,
  });

  factory EjercicioRutinaModel.fromMap(Map<String, dynamic> data) {
    return EjercicioRutinaModel(
      nombre: data['nombre'] ?? '',
      musculo: data['musculo'] ?? '',
      series: data['series'] ?? 3,
      repeticiones: data['repeticiones'] ?? '10',
      descanso: data['descanso'] ?? '60 seg',
      notas: data['notas'],
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'musculo': musculo,
        'series': series,
        'repeticiones': repeticiones,
        'descanso': descanso,
        if (notas != null) 'notas': notas,
      };
}

// ─── Dieta ────────────────────────────────────────────────────────────────────

class DietaModel {
  final String id;
  final String nombre;
  final int calorias;
  final String descripcion;
  final String objetivo; // Pérdida de peso, Volumen, Mantenimiento, Definición
  final List<String> preferenciasCompatibles; // Vegetariana, Sin gluten, etc.
  final String nivel; // Básica, Intermedia, Estricta
  final String creadoPor; // 'admin' | uid del usuario
  final List<ComidaDiaModel> comidas;

  DietaModel({
    required this.id,
    required this.nombre,
    required this.calorias,
    required this.descripcion,
    required this.objetivo,
    required this.preferenciasCompatibles,
    required this.nivel,
    required this.creadoPor,
    required this.comidas,
  });

  factory DietaModel.fromMap(String id, Map<String, dynamic> data) {
    final comidasRaw = data['comidas'] as List<dynamic>? ?? [];
    return DietaModel(
      id: id,
      nombre: data['nombre'] ?? '',
      calorias: data['calorias'] ?? 0,
      descripcion: data['descripcion'] ?? '',
      objetivo: data['objetivo'] ?? '',
      preferenciasCompatibles:
          List<String>.from(data['preferencias_compatibles'] ?? []),
      nivel: data['nivel'] ?? 'Básica',
      creadoPor: data['creado_por'] ?? 'admin',
      comidas: comidasRaw
          .map((c) => ComidaDiaModel.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'calorias': calorias,
        'descripcion': descripcion,
        'objetivo': objetivo,
        'preferencias_compatibles': preferenciasCompatibles,
        'nivel': nivel,
        'creado_por': creadoPor,
        'comidas': comidas.map((c) => c.toMap()).toList(),
      };
}

class ComidaDiaModel {
  final String momento; // Desayuno, Almuerzo, Merienda, Cena
  final String descripcion;
  final int caloriasAprox;
  final List<String> alimentos;

  ComidaDiaModel({
    required this.momento,
    required this.descripcion,
    required this.caloriasAprox,
    required this.alimentos,
  });

  factory ComidaDiaModel.fromMap(Map<String, dynamic> data) {
    return ComidaDiaModel(
      momento: data['momento'] ?? '',
      descripcion: data['descripcion'] ?? '',
      caloriasAprox: data['calorias_aprox'] ?? 0,
      alimentos: List<String>.from(data['alimentos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'momento': momento,
        'descripcion': descripcion,
        'calorias_aprox': caloriasAprox,
        'alimentos': alimentos,
      };
}
