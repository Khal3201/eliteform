// ─── seed_data.dart ───────────────────────────────────────────────────────────
// Carga inicial de datos en Firestore (se ejecuta una sola vez).
// Incluye: 25 ejercicios, 10 rutinas completas, 10 dietas completas.

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final _db = FirebaseFirestore.instance;

  // ── Punto de entrada ────────────────────────────────────────────────────────

  /// Llama este método una sola vez (p. ej. desde un botón admin oculto).
  /// Verifica si ya existe datos antes de insertar.
  static Future<void> cargarTodo() async {
    await _cargarEjercicios();
    await _cargarRutinas();
    await _cargarDietas();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EJERCICIOS (25)
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> _cargarEjercicios() async {
    final snap = await _db
        .collection('ejercicios')
        .where('creado_por', isEqualTo: 'admin')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return; // ya existen

    final ejercicios = [
      // ── PECHO ──
      {
        'nombre': 'Press de Banca',
        'musculo': 'Pecho',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'Ejercicio compuesto fundamental para el desarrollo del pecho. '
                'Activa pectoral mayor, deltoides anterior y tríceps.',
        'instrucciones':
            'Acuéstate en el banco con los pies planos en el suelo. '
                'Agarra la barra con agarre prono ligeramente más ancho que los hombros. '
                'Baja la barra controladamente hasta rozar el pecho y empuja hacia arriba.',
        'equipamiento': ['Barra', 'Banco'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Aperturas con Mancuernas',
        'musculo': 'Pecho',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio de aislamiento para el pecho. Excelente para trabajar el rango completo de movimiento.',
        'instrucciones':
            'Acuéstate en un banco plano con una mancuerna en cada mano. '
                'Extiende los brazos con codos ligeramente flexionados. '
                'Baja los brazos en arco hasta sentir estiramiento y vuelve a la posición inicial.',
        'equipamiento': ['Mancuernas', 'Banco'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Fondos en Paralelas',
        'musculo': 'Pecho',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'Movimiento compuesto que trabaja pecho, tríceps y hombros. '
                'Inclínate hacia adelante para mayor énfasis en pecho.',
        'instrucciones':
            'Apoya las manos en las barras paralelas con brazos extendidos. '
                'Inclina el torso ligeramente hacia adelante. '
                'Baja doblando los codos hasta 90° y empuja hacia arriba.',
        'equipamiento': ['Paralelas'],
        'creado_por': 'admin',
      },
      // ── ESPALDA ──
      {
        'nombre': 'Dominadas',
        'musculo': 'Espalda',
        'categoria': 'Fuerza',
        'nivel': 'Avanzado',
        'descripcion':
            'Ejercicio de peso corporal para dorsal ancho, romboides y bíceps. '
                'Uno de los mejores ejercicios para la espalda.',
        'instrucciones':
            'Cuelga de la barra con agarre prono más ancho que los hombros. '
                'Jala el cuerpo hacia arriba hasta que el mentón supere la barra. '
                'Baja lentamente de forma controlada.',
        'equipamiento': ['Barra de dominadas'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Remo con Barra',
        'musculo': 'Espalda',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'Ejercicio compuesto para dorsal, trapecios y romboides. '
                'Construye masa y grosor en la espalda.',
        'instrucciones':
            'De pie, inclina el torso ~45° con espalda recta. '
                'Agarra la barra con agarre prono. '
                'Jala la barra hacia el abdomen apretando los codos hacia atrás. '
                'Controla el descenso.',
        'equipamiento': ['Barra'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Jalón al Pecho en Polea',
        'musculo': 'Espalda',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Alternativa a las dominadas para trabajar el dorsal ancho. '
                'Ideal para principiantes que aún no pueden hacer dominadas.',
        'instrucciones':
            'Siéntate en la máquina y agarra la barra ancha con agarre prono. '
                'Jala la barra hacia el pecho superior apretando los codos hacia abajo. '
                'Extiende los brazos de forma controlada.',
        'equipamiento': ['Máquina de polea'],
        'creado_por': 'admin',
      },
      // ── PIERNAS ──
      {
        'nombre': 'Sentadilla con Barra',
        'musculo': 'Piernas',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'El rey de los ejercicios. Trabaja cuádriceps, femorales, '
                'glúteos y core simultáneamente.',
        'instrucciones':
            'Coloca la barra sobre los trapecios. Pies a la anchura de los hombros. '
                'Baja hasta que los muslos estén paralelos al suelo manteniendo espalda recta. '
                'Empuja desde los talones para subir.',
        'equipamiento': ['Barra', 'Rack'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Peso Muerto',
        'musculo': 'Piernas',
        'categoria': 'Fuerza',
        'nivel': 'Avanzado',
        'descripcion':
            'Ejercicio compuesto que trabaja toda la cadena posterior: '
                'femorales, glúteos, espalda baja y trapecios.',
        'instrucciones':
            'Pies a la anchura de las caderas, barra sobre los pies. '
                'Agárrate con los brazos justo fuera de las piernas. '
                'Mantén espalda recta y empuja el suelo hacia abajo para levantar la barra.',
        'equipamiento': ['Barra'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Prensa de Pierna',
        'musculo': 'Piernas',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio en máquina para cuádriceps y glúteos. '
                'Menor carga en la espalda comparado con la sentadilla.',
        'instrucciones':
            'Siéntate en la máquina con pies a la anchura de hombros. '
                'Baja el peso hasta 90° de flexión de rodilla. '
                'Empuja hasta casi extender completamente (no bloquear rodillas).',
        'equipamiento': ['Máquina de prensa'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Zancadas con Mancuernas',
        'musculo': 'Piernas',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio unilateral para cuádriceps, femorales y glúteos. '
                'Mejora el equilibrio y la estabilidad.',
        'instrucciones':
            'De pie con una mancuerna en cada mano. Da un paso largo hacia adelante. '
                'Baja la rodilla trasera hacia el suelo sin tocarlo. '
                'Empuja con el pie delantero para volver y repite con la otra pierna.',
        'equipamiento': ['Mancuernas'],
        'creado_por': 'admin',
      },
      // ── HOMBROS ──
      {
        'nombre': 'Press Militar con Barra',
        'musculo': 'Hombros',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'Ejercicio compuesto para el desarrollo completo de los hombros. '
                'Trabaja deltoides anterior, lateral y tríceps.',
        'instrucciones':
            'De pie o sentado, agarra la barra a la altura de los hombros. '
                'Empuja la barra verticalmente por encima de la cabeza. '
                'Baja de forma controlada hasta los hombros.',
        'equipamiento': ['Barra'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Elevaciones Laterales',
        'musculo': 'Hombros',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio de aislamiento para el deltoides lateral. '
                'Clave para dar amplitud a los hombros.',
        'instrucciones':
            'De pie con una mancuerna en cada mano a los costados. '
                'Eleva los brazos lateralmente hasta la altura de los hombros con codos ligeramente flexionados. '
                'Baja de forma controlada.',
        'equipamiento': ['Mancuernas'],
        'creado_por': 'admin',
      },
      // ── BÍCEPS ──
      {
        'nombre': 'Curl de Bíceps con Barra',
        'musculo': 'Bíceps',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio de aislamiento clásico para el bíceps braquial. '
                'Permite manejar mayor carga que con mancuernas.',
        'instrucciones':
            'De pie, agarra la barra con agarre supino a la anchura de los hombros. '
                'Dobla los codos levantando la barra hacia el pecho sin mover los codos. '
                'Baja de forma controlada.',
        'equipamiento': ['Barra'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Curl Martillo',
        'musculo': 'Bíceps',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Variante del curl que trabaja el bíceps braquial y el braquiorradial. '
                'Da grosor al brazo.',
        'instrucciones':
            'De pie con mancuernas en agarre neutro (pulgares hacia arriba). '
                'Dobla los codos levantando las mancuernas sin rotar las muñecas. '
                'Baja de forma controlada.',
        'equipamiento': ['Mancuernas'],
        'creado_por': 'admin',
      },
      // ── TRÍCEPS ──
      {
        'nombre': 'Press Francés',
        'musculo': 'Tríceps',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'Ejercicio de aislamiento para la cabeza larga del tríceps. '
                'Excelente para el desarrollo total del tríceps.',
        'instrucciones':
            'Acuéstate en un banco con barra o mancuerna sobre el pecho. '
                'Dobla los codos llevando el peso hacia la frente sin mover los codos. '
                'Extiende los codos volviendo a la posición inicial.',
        'equipamiento': ['Barra', 'Banco'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Extensión de Tríceps en Polea',
        'musculo': 'Tríceps',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio de aislamiento para tríceps en máquina de polea. '
                'Permite trabajo continuo y controlado.',
        'instrucciones':
            'De pie frente a la polea alta, agarra la cuerda o barra. '
                'Mantén codos pegados al cuerpo. '
                'Extiende los codos hacia abajo y vuelve lentamente.',
        'equipamiento': ['Máquina de polea'],
        'creado_por': 'admin',
      },
      // ── ABDOMEN ──
      {
        'nombre': 'Plancha',
        'musculo': 'Abdomen',
        'categoria': 'Resistencia',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio isométrico para el core completo. '
                'Trabaja abdominales, oblicuos y estabilizadores de la columna.',
        'instrucciones':
            'Apoya los antebrazos y puntas de los pies en el suelo. '
                'Mantén el cuerpo en línea recta desde la cabeza hasta los talones. '
                'Contrae el abdomen y mantén la posición.',
        'equipamiento': [],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Crunch Abdominal',
        'musculo': 'Abdomen',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio clásico para el recto abdominal. '
                'Base del entrenamiento abdominal.',
        'instrucciones':
            'Acuéstate boca arriba con rodillas dobladas. '
                'Coloca las manos detrás de la nuca sin jalar el cuello. '
                'Contrae el abdomen levantando los hombros del suelo. Baja controladamente.',
        'equipamiento': [],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Rueda Abdominal',
        'musculo': 'Abdomen',
        'categoria': 'Fuerza',
        'nivel': 'Avanzado',
        'descripcion':
            'Ejercicio avanzado para core completo. '
                'Trabaja abdominales, oblicuos, dorsales y hombros.',
        'instrucciones':
            'Arrodíllate con la rueda en el suelo frente a ti. '
                'Rueda hacia adelante extendiendo el cuerpo hasta casi tocar el suelo. '
                'Contrae el core para volver a la posición inicial.',
        'equipamiento': ['Rueda abdominal'],
        'creado_por': 'admin',
      },
      // ── GLÚTEOS ──
      {
        'nombre': 'Hip Thrust con Barra',
        'musculo': 'Glúteos',
        'categoria': 'Fuerza',
        'nivel': 'Intermedio',
        'descripcion':
            'El ejercicio más efectivo para el desarrollo del glúteo mayor. '
                'Permite manejar cargas elevadas.',
        'instrucciones':
            'Apoya la espalda alta en un banco, barra sobre las caderas. '
                'Pies planos en el suelo a la anchura de las caderas. '
                'Empuja las caderas hacia arriba apretando los glúteos. Baja controladamente.',
        'equipamiento': ['Barra', 'Banco'],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Patada Trasera en Polea',
        'musculo': 'Glúteos',
        'categoria': 'Fuerza',
        'nivel': 'Principiante',
        'descripcion':
            'Ejercicio de aislamiento para el glúteo mayor. '
                'Ideal para tonificar y dar forma.',
        'instrucciones':
            'De pie frente a la polea baja con tobillera. '
                'Apoya las manos en la máquina. '
                'Extiende la pierna hacia atrás apretando el glúteo. Regresa controladamente.',
        'equipamiento': ['Máquina de polea'],
        'creado_por': 'admin',
      },
      // ── CARDIO ──
      {
        'nombre': 'Burpees',
        'musculo': 'Full Body',
        'categoria': 'Cardio',
        'nivel': 'Intermedio',
        'descripcion':
            'Ejercicio de cuerpo completo que combina fuerza y cardio. '
                'Quema calorías y mejora la resistencia cardiovascular.',
        'instrucciones':
            'De pie, baja a posición de cuclillas y apoya las manos. '
                'Lleva los pies hacia atrás a posición de plancha. '
                'Haz una flexión, vuelve a cuclillas y salta con los brazos arriba.',
        'equipamiento': [],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Jump Squats',
        'musculo': 'Piernas',
        'categoria': 'Cardio',
        'nivel': 'Intermedio',
        'descripcion':
            'Variante pliométrica de la sentadilla. '
                'Desarrolla potencia en piernas y eleva la frecuencia cardíaca.',
        'instrucciones':
            'Posición de sentadilla, baja hasta 90°. '
                'Desde abajo, explota hacia arriba saltando con los pies del suelo. '
                'Aterriza suavemente y baja de inmediato a la siguiente repetición.',
        'equipamiento': [],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Cuerda para Saltar',
        'musculo': 'Full Body',
        'categoria': 'Cardio',
        'nivel': 'Principiante',
        'descripcion':
            'Excelente ejercicio cardiovascular. '
                'Mejora coordinación, resistencia y quema calorías eficientemente.',
        'instrucciones':
            'Sostén los mangos de la cuerda a los costados. '
                'Gira la cuerda con las muñecas y salta con ambos pies. '
                'Mantén un ritmo constante y aterriza suavemente.',
        'equipamiento': ['Cuerda para saltar'],
        'creado_por': 'admin',
      },
      // ── FLEXIBILIDAD ──
      {
        'nombre': 'Estiramiento de Isquiotibiales',
        'musculo': 'Piernas',
        'categoria': 'Flexibilidad',
        'nivel': 'Principiante',
        'descripcion':
            'Estiramiento esencial para la parte posterior del muslo. '
                'Reduce el riesgo de lesiones y mejora la postura.',
        'instrucciones':
            'Siéntate en el suelo con las piernas extendidas. '
                'Inclínate hacia adelante intentando tocar los pies con las manos. '
                'Mantén la espalda recta y sostén 30 segundos.',
        'equipamiento': [],
        'creado_por': 'admin',
      },
      {
        'nombre': 'Yoga: Perro boca abajo',
        'musculo': 'Full Body',
        'categoria': 'Flexibilidad',
        'nivel': 'Principiante',
        'descripcion':
            'Postura de yoga que estira isquiotibiales, pantorrillas, '
                'hombros y columna. Alivia tensión y mejora la flexibilidad general.',
        'instrucciones':
            'Desde plancha, levanta las caderas hacia arriba formando una V invertida. '
                'Presiona las palmas en el suelo y extiende los codos. '
                'Empuja los talones hacia el suelo. Mantén 30-60 segundos.',
        'equipamiento': ['Tapete de yoga'],
        'creado_por': 'admin',
      },
    ];

    final batch = _db.batch();
    for (final e in ejercicios) {
      batch.set(_db.collection('ejercicios').doc(), e);
    }
    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RUTINAS (10 completas)
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> _cargarRutinas() async {
    final snap = await _db
        .collection('rutinas')
        .where('creado_por', isEqualTo: 'admin')
        .limit(3)
        .get();
    if (snap.docs.length >= 3) return; // ya hay suficientes

    final rutinas = [
      // ── 1. FUERZA BÁSICA 5×5 ──
      {
        'nombre_rutina': 'Fuerza Base 5×5',
        'objetivo': 'Fuerza',
        'descripcion':
            'Programa clásico de fuerza basado en 5 series de 5 repeticiones. '
                'Ideal para principiantes e intermedios que buscan ganar fuerza base rápidamente.',
        'nivel': 'Intermedio',
        'dias_por_semana': 3,
        'musculos_principales': ['Pecho', 'Espalda', 'Piernas', 'Hombros'],
        'creado_por': 'admin',
        'dias': [
          {
            'nombre_dia': 'Día A — Sentadilla / Press / Remo',
            'ejercicios': [
              {
                'nombre': 'Sentadilla con Barra',
                'musculo': 'Piernas',
                'series': 5,
                'repeticiones': '5',
                'descanso': '3 min',
                'notas': 'Profundidad completa, espalda recta'
              },
              {
                'nombre': 'Press de Banca',
                'musculo': 'Pecho',
                'series': 5,
                'repeticiones': '5',
                'descanso': '3 min',
                'notas': 'Codos a 45°, baja hasta el pecho'
              },
              {
                'nombre': 'Remo con Barra',
                'musculo': 'Espalda',
                'series': 5,
                'repeticiones': '5',
                'descanso': '2 min',
                'notas': 'Torso a 45°, jala hacia el abdomen'
              },
            ],
          },
          {
            'nombre_dia': 'Día B — Sentadilla / Press Militar / Peso Muerto',
            'ejercicios': [
              {
                'nombre': 'Sentadilla con Barra',
                'musculo': 'Piernas',
                'series': 5,
                'repeticiones': '5',
                'descanso': '3 min',
              },
              {
                'nombre': 'Press Militar con Barra',
                'musculo': 'Hombros',
                'series': 5,
                'repeticiones': '5',
                'descanso': '3 min',
              },
              {
                'nombre': 'Peso Muerto',
                'musculo': 'Piernas',
                'series': 1,
                'repeticiones': '5',
                'descanso': '4 min',
                'notas': '1 serie pesada al máximo'
              },
            ],
          },
        ],
      },
      // ── 2. HIPERTROFIA PUSH/PULL/LEGS ──
      {
        'nombre_rutina': 'Hipertrofia PPL 6 días',
        'objetivo': 'Volumen',
        'descripcion':
            'Rutina Push-Pull-Legs repetida dos veces por semana. '
                'Máximo volumen para ganancia muscular. Requiere buena recuperación.',
        'nivel': 'Avanzado',
        'dias_por_semana': 6,
        'musculos_principales': [
          'Pecho',
          'Espalda',
          'Piernas',
          'Hombros',
          'Bíceps',
          'Tríceps'
        ],
        'creado_por': 'admin',
        'dias': [
          {
            'nombre_dia': 'Push — Pecho / Hombros / Tríceps',
            'ejercicios': [
              {
                'nombre': 'Press de Banca',
                'musculo': 'Pecho',
                'series': 4,
                'repeticiones': '6-8',
                'descanso': '2 min',
              },
              {
                'nombre': 'Fondos en Paralelas',
                'musculo': 'Pecho',
                'series': 3,
                'repeticiones': '10-12',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Press Militar con Barra',
                'musculo': 'Hombros',
                'series': 4,
                'repeticiones': '8-10',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Elevaciones Laterales',
                'musculo': 'Hombros',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Extensión de Tríceps en Polea',
                'musculo': 'Tríceps',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Pull — Espalda / Bíceps',
            'ejercicios': [
              {
                'nombre': 'Dominadas',
                'musculo': 'Espalda',
                'series': 4,
                'repeticiones': 'Al fallo',
                'descanso': '2 min',
              },
              {
                'nombre': 'Remo con Barra',
                'musculo': 'Espalda',
                'series': 4,
                'repeticiones': '8-10',
                'descanso': '2 min',
              },
              {
                'nombre': 'Jalón al Pecho en Polea',
                'musculo': 'Espalda',
                'series': 3,
                'repeticiones': '10-12',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Curl de Bíceps con Barra',
                'musculo': 'Bíceps',
                'series': 3,
                'repeticiones': '10-12',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Curl Martillo',
                'musculo': 'Bíceps',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Legs — Piernas / Glúteos',
            'ejercicios': [
              {
                'nombre': 'Sentadilla con Barra',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '8-10',
                'descanso': '2 min',
              },
              {
                'nombre': 'Peso Muerto',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '8',
                'descanso': '2 min',
              },
              {
                'nombre': 'Prensa de Pierna',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Hip Thrust con Barra',
                'musculo': 'Glúteos',
                'series': 4,
                'repeticiones': '10-12',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Zancadas con Mancuernas',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '12 por pierna',
                'descanso': '60 seg',
              },
            ],
          },
        ],
      },
      // ── 3. RESISTENCIA TOTAL ──
      {
        'nombre_rutina': 'Circuito de Resistencia Total',
        'objetivo': 'Resistencia',
        'descripcion':
            'Rutina de alta intensidad con poco descanso entre series. '
                'Mejora resistencia muscular y cardiovascular. Perfecta para quemar calorías.',
        'nivel': 'Principiante',
        'dias_por_semana': 4,
        'musculos_principales': ['Full body'],
        'creado_por': 'admin',
        'dias': [
          {
            'nombre_dia': 'Circuito A — Tren Superior',
            'ejercicios': [
              {
                'nombre': 'Fondos en Paralelas',
                'musculo': 'Pecho',
                'series': 3,
                'repeticiones': '15',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Dominadas',
                'musculo': 'Espalda',
                'series': 3,
                'repeticiones': 'Al fallo',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Elevaciones Laterales',
                'musculo': 'Hombros',
                'series': 3,
                'repeticiones': '20',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Curl de Bíceps con Barra',
                'musculo': 'Bíceps',
                'series': 3,
                'repeticiones': '15',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Extensión de Tríceps en Polea',
                'musculo': 'Tríceps',
                'series': 3,
                'repeticiones': '15',
                'descanso': '30 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Circuito B — Tren Inferior + Core',
            'ejercicios': [
              {
                'nombre': 'Jump Squats',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '15',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Zancadas con Mancuernas',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '20',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Hip Thrust con Barra',
                'musculo': 'Glúteos',
                'series': 3,
                'repeticiones': '20',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Plancha',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '45 seg',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Crunch Abdominal',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '20',
                'descanso': '30 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Circuito C — Full Body HIIT',
            'ejercicios': [
              {
                'nombre': 'Burpees',
                'musculo': 'Full Body',
                'series': 5,
                'repeticiones': '10',
                'descanso': '20 seg',
              },
              {
                'nombre': 'Jump Squats',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '15',
                'descanso': '20 seg',
              },
              {
                'nombre': 'Fondos en Paralelas',
                'musculo': 'Pecho',
                'series': 4,
                'repeticiones': '12',
                'descanso': '20 seg',
              },
              {
                'nombre': 'Plancha',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '60 seg',
                'descanso': '20 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Circuito D — Cardio + Movilidad',
            'ejercicios': [
              {
                'nombre': 'Cuerda para Saltar',
                'musculo': 'Full Body',
                'series': 5,
                'repeticiones': '2 min',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Yoga: Perro boca abajo',
                'musculo': 'Full Body',
                'series': 3,
                'repeticiones': '60 seg',
                'descanso': '15 seg',
              },
              {
                'nombre': 'Estiramiento de Isquiotibiales',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '45 seg',
                'descanso': '15 seg',
              },
            ],
          },
        ],
      },
      // ── 4. DEFINICIÓN + CARDIO ──
      {
        'nombre_rutina': 'Definición y Quema de Grasa',
        'objetivo': 'Definición',
        'descripcion':
            'Rutina diseñada para preservar músculo mientras se reduce grasa. '
                'Combina trabajo de fuerza con circuitos metabólicos.',
        'nivel': 'Intermedio',
        'dias_por_semana': 5,
        'musculos_principales': ['Full body'],
        'creado_por': 'admin',
        'dias': [
          {
            'nombre_dia': 'Lunes — Pecho + Tríceps',
            'ejercicios': [
              {
                'nombre': 'Press de Banca',
                'musculo': 'Pecho',
                'series': 4,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Aperturas con Mancuernas',
                'musculo': 'Pecho',
                'series': 3,
                'repeticiones': '15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Fondos en Paralelas',
                'musculo': 'Pecho',
                'series': 3,
                'repeticiones': 'Al fallo',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Press Francés',
                'musculo': 'Tríceps',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Extensión de Tríceps en Polea',
                'musculo': 'Tríceps',
                'series': 3,
                'repeticiones': '15',
                'descanso': '45 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Martes — Espalda + Bíceps',
            'ejercicios': [
              {
                'nombre': 'Jalón al Pecho en Polea',
                'musculo': 'Espalda',
                'series': 4,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Remo con Barra',
                'musculo': 'Espalda',
                'series': 4,
                'repeticiones': '12',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Curl de Bíceps con Barra',
                'musculo': 'Bíceps',
                'series': 3,
                'repeticiones': '12-15',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Curl Martillo',
                'musculo': 'Bíceps',
                'series': 3,
                'repeticiones': '15',
                'descanso': '45 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Miércoles — Piernas',
            'ejercicios': [
              {
                'nombre': 'Sentadilla con Barra',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '15',
                'descanso': '90 seg',
              },
              {
                'nombre': 'Prensa de Pierna',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '15-20',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Zancadas con Mancuernas',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '15 por pierna',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Hip Thrust con Barra',
                'musculo': 'Glúteos',
                'series': 4,
                'repeticiones': '15',
                'descanso': '60 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Jueves — Hombros + Core',
            'ejercicios': [
              {
                'nombre': 'Press Militar con Barra',
                'musculo': 'Hombros',
                'series': 4,
                'repeticiones': '12',
                'descanso': '60 seg',
              },
              {
                'nombre': 'Elevaciones Laterales',
                'musculo': 'Hombros',
                'series': 4,
                'repeticiones': '15',
                'descanso': '45 seg',
              },
              {
                'nombre': 'Plancha',
                'musculo': 'Abdomen',
                'series': 4,
                'repeticiones': '45 seg',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Crunch Abdominal',
                'musculo': 'Abdomen',
                'series': 4,
                'repeticiones': '20',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Rueda Abdominal',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '10',
                'descanso': '60 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Viernes — HIIT Metabólico',
            'ejercicios': [
              {
                'nombre': 'Burpees',
                'musculo': 'Full Body',
                'series': 4,
                'repeticiones': '12',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Jump Squats',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '15',
                'descanso': '30 seg',
              },
              {
                'nombre': 'Cuerda para Saltar',
                'musculo': 'Full Body',
                'series': 5,
                'repeticiones': '1 min',
                'descanso': '30 seg',
              },
            ],
          },
        ],
      },
      // ── 5. MOVILIDAD Y BIENESTAR ──
      {
        'nombre_rutina': 'Movilidad y Bienestar',
        'objetivo': 'Movilidad',
        'descripcion':
            'Rutina enfocada en mejorar la flexibilidad, movilidad articular '
                'y recuperación. Perfecta como complemento o para días de descanso activo.',
        'nivel': 'Principiante',
        'dias_por_semana': 3,
        'musculos_principales': ['Full body'],
        'creado_por': 'admin',
        'dias': [
          {
            'nombre_dia': 'Sesión A — Movilidad Superior',
            'ejercicios': [
              {
                'nombre': 'Yoga: Perro boca abajo',
                'musculo': 'Full Body',
                'series': 3,
                'repeticiones': '60 seg',
                'descanso': '15 seg',
              },
              {
                'nombre': 'Estiramiento de Isquiotibiales',
                'musculo': 'Piernas',
                'series': 3,
                'repeticiones': '40 seg',
                'descanso': '15 seg',
              },
              {
                'nombre': 'Plancha',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '30 seg',
                'descanso': '15 seg',
              },
            ],
          },
          {
            'nombre_dia': 'Sesión B — Flexibilidad Total',
            'ejercicios': [
              {
                'nombre': 'Estiramiento de Isquiotibiales',
                'musculo': 'Piernas',
                'series': 4,
                'repeticiones': '60 seg',
                'descanso': '20 seg',
              },
              {
                'nombre': 'Yoga: Perro boca abajo',
                'musculo': 'Full Body',
                'series': 4,
                'repeticiones': '60 seg',
                'descanso': '20 seg',
              },
              {
                'nombre': 'Plancha',
                'musculo': 'Abdomen',
                'series': 3,
                'repeticiones': '45 seg',
                'descanso': '20 seg',
              },
            ],
          },
        ],
      },
    ];

    final batch = _db.batch();
    for (final r in rutinas) {
      batch.set(_db.collection('rutinas').doc(), r);
    }
    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIETAS (10 completas)
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> _cargarDietas() async {
    final snap = await _db
        .collection('dietas')
        .where('creado_por', isEqualTo: 'admin')
        .limit(3)
        .get();
    if (snap.docs.length >= 3) return;

    final dietas = [
      // ── 1. DÉFICIT CALÓRICO ──
      {
        'nombre': 'Déficit Calórico Estructurado',
        'objetivo': 'Pérdida de peso',
        'descripcion':
            'Plan alimenticio con déficit calórico moderado de 500 kcal. '
                'Diseñado para perder 0.5 kg por semana sin sacrificar músculo.',
        'calorias': 1800,
        'nivel': 'Básica',
        'preferencias_compatibles': ['Alta en proteínas'],
        'creado_por': 'admin',
        'comidas': [
          {
            'momento': 'Desayuno',
            'descripcion':
                'Desayuno alto en proteína para comenzar el día saciado y con energía.',
            'calorias_aprox': 400,
            'alimentos': [
              '3 claras de huevo + 1 huevo entero revueltos',
              'Avena (40g) con leche descremada',
              '1 manzana mediana',
              'Café negro sin azúcar',
            ],
          },
          {
            'momento': 'Snack mañana',
            'descripcion': 'Colación ligera para evitar llegar con hambre al almuerzo.',
            'calorias_aprox': 150,
            'alimentos': [
              '1 yogur griego natural sin azúcar (120g)',
              '10 almendras',
            ],
          },
          {
            'momento': 'Almuerzo',
            'descripcion':
                'Comida principal del día con proteína de calidad y carbohidratos complejos.',
            'calorias_aprox': 550,
            'alimentos': [
              'Pechuga de pollo a la plancha (180g)',
              'Arroz integral (80g crudo)',
              'Ensalada mixta con pepino, jitomate y lechuga',
              'Aceite de oliva (1 cdita) + limón como aderezo',
            ],
          },
          {
            'momento': 'Merienda',
            'descripcion': 'Merienda pre-entreno o para la tarde.',
            'calorias_aprox': 200,
            'alimentos': [
              'Batido de proteína (1 scoop con agua)',
              '1 plátano pequeño',
            ],
          },
          {
            'momento': 'Cena',
            'descripcion':
                'Cena ligera y proteica para favorecer la recuperación nocturna.',
            'calorias_aprox': 500,
            'alimentos': [
              'Tilapia al horno (200g)',
              'Camote cocido (100g)',
              'Brócoli al vapor (200g)',
              'Agua natural o infusión',
            ],
          },
        ],
      },
      // ── 2. VOLUMEN LIMPIO ──
      {
        'nombre': 'Volumen Limpio Moderado',
        'objetivo': 'Volumen',
        'descripcion':
            'Plan con superávit calórico moderado (+400 kcal) para ganar músculo '
                'sin exceso de grasa. Enfocado en proteína alta y carbohidratos de calidad.',
        'calorias': 3200,
        'nivel': 'Intermedia',
        'preferencias_compatibles': ['Sin restricciones', 'Alta en proteínas'],
        'creado_por': 'admin',
        'comidas': [
          {
            'momento': 'Desayuno',
            'descripcion': 'Desayuno denso en calorías y nutrientes para comenzar el día.',
            'calorias_aprox': 750,
            'alimentos': [
              'Avena (100g) con leche entera (300ml)',
              '3 huevos revueltos',
              '1 plátano grande',
              'Mantequilla de maní natural (30g)',
              'Jugo de naranja natural (200ml)',
            ],
          },
          {
            'momento': 'Snack mañana',
            'descripcion': 'Colación anabólica entre desayuno y comida.',
            'calorias_aprox': 450,
            'alimentos': [
              'Batido de proteína (1 scoop)',
              'Leche entera (250ml)',
              'Nueces mixtas (30g)',
              '1 manzana',
            ],
          },
          {
            'momento': 'Almuerzo',
            'descripcion': 'Comida principal con proteína de alta calidad y carbohidratos.',
            'calorias_aprox': 950,
            'alimentos': [
              'Pechuga de pollo (220g)',
              'Arroz blanco (150g cocido)',
              'Frijoles negros (100g)',
              'Aguacate (½ pieza)',
              'Tortillas de maíz (2 piezas)',
            ],
          },
          {
            'momento': 'Merienda pre-entreno',
            'descripcion': 'Comida pre-entreno para maximizar el rendimiento.',
            'calorias_aprox': 500,
            'alimentos': [
              'Pan integral (2 rebanadas)',
              'Atún en agua (1 lata)',
              'Yogur griego (150g)',
              '1 naranja',
            ],
          },
          {
            'momento': 'Cena post-entreno',
            'descripcion': 'Cena de recuperación post-entreno con proteína y carbos.',
            'calorias_aprox': 550,
            'alimentos': [
              'Salmón al horno (180g)',
              'Pasta integral (80g cruda)',
              'Espinacas salteadas con ajo (150g)',
              'Aceite de oliva (1 cda)',
            ],
          },
        ],
      },
      // ── 3. MANTENIMIENTO EQUILIBRADO ──
      {
        'nombre': 'Balance Diario Equilibrado',
        'objetivo': 'Mantenimiento',
        'descripcion':
            'Plan para mantener el peso y la composición corporal actual. '
                'Dieta variada y nutritiva sin restricciones extremas.',
        'calorias': 2200,
        'nivel': 'Básica',
        'preferencias_compatibles': ['Sin restricciones'],
        'creado_por': 'admin',
        'comidas': [
          {
            'momento': 'Desayuno',
            'descripcion': 'Desayuno equilibrado para iniciar el día con energía.',
            'calorias_aprox': 500,
            'alimentos': [
              '2 huevos (revueltos o estrellados)',
              'Pan integral tostado (2 rebanadas)',
              '1 fruta de temporada',
              'Leche o café con leche (200ml)',
            ],
          },
          {
            'momento': 'Snack',
            'descripcion': 'Colación ligera a media mañana.',
            'calorias_aprox': 200,
            'alimentos': [
              '1 yogur natural',
              '1 puño de frutos secos',
            ],
          },
          {
            'momento': 'Almuerzo',
            'descripcion': 'Comida del mediodía balanceada con todos los macros.',
            'calorias_aprox': 700,
            'alimentos': [
              'Pollo o res (150g)',
              'Arroz o pasta (120g cocido)',
              'Ensalada variada con aderezo',
              'Agua natural',
            ],
          },
          {
            'momento': 'Merienda',
            'descripcion': 'Merienda de la tarde.',
            'calorias_aprox': 250,
            'alimentos': [
              '2 rebanadas de pan integral con pavo',
              'Infusión o té',
            ],
          },
          {
            'momento': 'Cena',
            'descripcion': 'Cena ligera y nutritiva.',
            'calorias_aprox': 550,
            'alimentos': [
              'Pescado o pollo (160g)',
              'Verduras asadas o al vapor (200g)',
              'Camote o papa (100g)',
            ],
          },
        ],
      },
      // ── 4. DEFINICIÓN ALTA PROTEÍNA ──
      {
        'nombre': 'Definición Alta Proteína',
        'objetivo': 'Definición',
        'descripcion':
            'Plan hipocalórico con énfasis en proteína alta para preservar '
                'la masa muscular mientras se reduce la grasa corporal.',
        'calorias': 2000,
        'nivel': 'Estricta',
        'preferencias_compatibles': [
          'Alta en proteínas',
          'Baja en carbohidratos'
        ],
        'creado_por': 'admin',
        'comidas': [
          {
            'momento': 'Desayuno',
            'descripcion':
                'Desayuno alto en proteína y bajo en carbohidratos para activar el metabolismo.',
            'calorias_aprox': 400,
            'alimentos': [
              '4 claras de huevo + 2 huevos enteros revueltos',
              'Espinacas salteadas (100g)',
              '½ aguacate',
              'Café negro sin azúcar',
            ],
          },
          {
            'momento': 'Snack mañana',
            'descripcion': 'Colación proteica baja en calorías.',
            'calorias_aprox': 180,
            'alimentos': [
              'Requesón bajo en grasa (150g)',
              '10 almendras',
            ],
          },
          {
            'momento': 'Almuerzo',
            'descripcion':
                'Comida principal con proteína elevada y carbohidratos controlados.',
            'calorias_aprox': 550,
            'alimentos': [
              'Pechuga de pollo a la plancha (220g)',
              'Quinoa (60g cruda)',
              'Brócoli y coliflor al vapor (250g)',
              'Aceite de oliva (1 cdita)',
            ],
          },
          {
            'momento': 'Merienda pre-entreno',
            'descripcion': 'Colación pre-entreno para mantener energía.',
            'calorias_aprox': 270,
            'alimentos': [
              'Batido de proteína isolado (1 scoop)',
              '1 manzana pequeña',
            ],
          },
          {
            'momento': 'Cena',
            'descripcion': 'Cena proteica y ligera para la recuperación nocturna.',
            'calorias_aprox': 600,
            'alimentos': [
              'Salmón a la plancha (200g)',
              'Espárragos al horno (200g)',
              'Ensalada de arúgula con jitomate',
              'Aceite de oliva + vinagre balsámico',
            ],
          },
        ],
      },
      // ── 5. VEGETARIANA FITNESS ──
      {
        'nombre': 'Vegetariana Alto Rendimiento',
        'objetivo': 'Mantenimiento',
        'descripcion':
            'Plan vegetariano completo diseñado para atletas. '
                'Cubre todos los macros y micronutrientes sin proteína animal.',
        'calorias': 2400,
        'nivel': 'Intermedia',
        'preferencias_compatibles': [
          'Vegetariana',
          'Alta en proteínas',
          'Sin restricciones'
        ],
        'creado_por': 'admin',
        'comidas': [
          {
            'momento': 'Desayuno',
            'descripcion': 'Desayuno vegetariano completo y energizante.',
            'calorias_aprox': 550,
            'alimentos': [
              'Avena (80g) con leche de almendras',
              '2 huevos revueltos con espinacas',
              '1 plátano',
              '½ cucharada de miel',
            ],
          },
          {
            'momento': 'Snack',
            'descripcion': 'Colación vegetariana alta en proteína.',
            'calorias_aprox': 280,
            'alimentos': [
              'Yogur griego (200g)',
              'Granola sin azúcar (30g)',
              'Frutos rojos mixtos',
            ],
          },
          {
            'momento': 'Almuerzo',
            'descripcion': 'Comida principal vegetariana completa.',
            'calorias_aprox': 750,
            'alimentos': [
              'Lentejas guisadas (200g cocidas)',
              'Arroz integral (100g cocido)',
              'Aguacate (½ pieza)',
              'Tortillas de maíz (2 piezas)',
              'Ensalada verde con limón',
            ],
          },
          {
            'momento': 'Merienda',
            'descripcion': 'Colación tarde alta en proteína vegetal.',
            'calorias_aprox': 300,
            'alimentos': [
              'Edamame cocido (150g)',
              'Nueces de la India (20g)',
              'Fruta de temporada',
            ],
          },
          {
            'momento': 'Cena',
            'descripcion': 'Cena vegetariana nutritiva y equilibrada.',
            'calorias_aprox': 520,
            'alimentos': [
              'Tofu salteado (180g)',
              'Quinoa (80g cruda)',
              'Pimientos y zucchini asados (200g)',
              'Salsa de soya baja en sodio',
            ],
          },
        ],
      },
    ];

    final batch = _db.batch();
    for (final d in dietas) {
      batch.set(_db.collection('dietas').doc(), d);
    }
    await batch.commit();
  }
}