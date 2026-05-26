// ─── seed_chatbot_respuestas.dart ─────────────────────────────────────────────
// Seed para chatbot_respuestas (50 respuestas preconfiguradas)

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedChatbotRespuestas {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _coleccion = 'chatbot_respuestas';

  static Future<void> cargar() async {
    final snap = await _db.collection(_coleccion).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final respuestas = <Map<String, dynamic>>[
      {
        'titulo': 'Horarios',
        'respuesta':
            'Abrimos de lunes a viernes de 6:00 a.m. a 10:00 p.m. y sábados de 7:00 a.m. a 6:00 p.m. Los domingos manejamos horario reducido o descanso, según temporada.',
        'palabras_clave': ['horario', 'horarios', 'hora', 'abierto', 'cierra', 'cerramos', 'apertura'],
        'orden': 0,
      },
      {
        'titulo': 'Ubicación',
        'respuesta':
            'Estamos ubicados en la zona principal de la ciudad, cerca de avenidas de fácil acceso. Si necesitas la dirección exacta, te la puedo dejar en una respuesta fija aparte.',
        'palabras_clave': ['ubicacion', 'ubicación', 'direccion', 'dirección', 'donde estan', 'dónde están', 'lugar'],
        'orden': 1,
      },
      {
        'titulo': 'Contacto',
        'respuesta':
            'Puedes contactarnos en recepción, por llamada o por WhatsApp durante horario de atención. También respondemos mensajes en redes sociales.',
        'palabras_clave': ['contacto', 'telefono', 'teléfono', 'whatsapp', 'llamada', 'mensaje', 'redes'],
        'orden': 2,
      },
      {
        'titulo': 'Inscripción',
        'respuesta':
            'Para inscribirte solo necesitas tus datos básicos y elegir el plan que más te convenga. El proceso es rápido y se hace en recepción.',
        'palabras_clave': ['inscripcion', 'inscripción', 'registrarme', 'registro', 'inscribir', 'alta', 'unirme'],
        'orden': 3,
      },
      {
        'titulo': 'Membresía mensual',
        'respuesta':
            'La membresía mensual incluye acceso al gimnasio en horario normal y uso de las áreas comunes. Algunas promociones pueden cambiar según la temporada.',
        'palabras_clave': ['membresia', 'membresía', 'mensualidad', 'mes', 'plan mensual', 'pago mensual'],
        'orden': 4,
      },
      {
        'titulo': 'Membresía anual',
        'respuesta':
            'La membresía anual suele ser la opción con mejor costo por mes. Normalmente incluye beneficios extra o descuento por pago completo.',
        'palabras_clave': ['anual', 'anualidad', 'plan anual', 'ano', 'año', 'descuento anual'],
        'orden': 5,
      },
      {
        'titulo': 'Formas de pago',
        'respuesta':
            'Aceptamos pago en efectivo y, según disponibilidad, pago con tarjeta o transferencia. En recepción te confirman qué métodos están activos.',
        'palabras_clave': ['pago', 'pagar', 'tarjeta', 'transferencia', 'efectivo', 'cobro', 'forma de pago'],
        'orden': 6,
      },
      {
        'titulo': 'Renovación',
        'respuesta':
            'Tu membresía se puede renovar directamente antes de la fecha de vencimiento para evitar interrupciones en tu acceso.',
        'palabras_clave': ['renovar', 'renovacion', 'renovación', 'vencimiento', 'continuar', 'extender'],
        'orden': 7,
      },
      {
        'titulo': 'Promociones',
        'respuesta':
            'Sí, a veces manejamos promociones de inscripción, mensualidad o paquetes familiares. Cambian por temporada, así que conviene preguntar en recepción.',
        'palabras_clave': ['promocion', 'promoción', 'oferta', 'descuento', 'promo', 'rebaja'],
        'orden': 8,
      },
      {
        'titulo': 'Edad mínima',
        'respuesta':
            'La edad mínima puede depender del reglamento interno y de la autorización de un tutor. Lo ideal es consultar en recepción antes de inscribirse.',
        'palabras_clave': ['edad', 'menor', 'menores', 'adolescente', 'tutor', 'permiso'],
        'orden': 9,
      },
      {
        'titulo': 'Rutinas personalizadas',
        'respuesta':
            'Sí, podemos ayudarte a elegir una rutina según tu objetivo, nivel y tiempo disponible. Lo ideal es entrenar con una estructura adecuada para ti.',
        'palabras_clave': ['rutina', 'rutinas', 'entrenamiento', 'plan', 'personalizada', 'programa'],
        'orden': 10,
      },
      {
        'titulo': 'Ganancia muscular',
        'respuesta':
            'Para ganar músculo conviene priorizar progresión de cargas, buena técnica, suficiente proteína y descanso adecuado.',
        'palabras_clave': ['musculo', 'músculo', 'masa', 'volumen', 'hipertrofia', 'ganar musculo'],
        'orden': 11,
      },
      {
        'titulo': 'Pérdida de grasa',
        'respuesta':
            'Para perder grasa hace falta constancia en el entrenamiento, control de comida y un déficit calórico moderado.',
        'palabras_clave': ['grasa', 'bajar peso', 'perder peso', 'definicion', 'definición', 'adelgazar', 'quemar grasa'],
        'orden': 12,
      },
      {
        'titulo': 'Fuerza',
        'respuesta':
            'Si buscas fuerza, lo mejor es trabajar ejercicios compuestos, cargas progresivas y descansos más largos entre series.',
        'palabras_clave': ['fuerza', 'ser fuerte', 'power', 'potencia', 'pesado'],
        'orden': 13,
      },
      {
        'titulo': 'Resistencia',
        'respuesta':
            'Para resistencia conviene usar más repeticiones, descansos cortos y circuitos dinámicos.',
        'palabras_clave': ['resistencia', 'aguante', 'cardio', 'circuito', 'condicion', 'condición'],
        'orden': 14,
      },
      {
        'titulo': 'Principiante',
        'respuesta':
            'Si estás empezando, lo mejor es una rutina simple, técnica limpia y poco volumen al inicio. Menos caos, más constancia.',
        'palabras_clave': ['principiante', 'empezar', 'novato', 'inicio', 'nuevo', 'principiantes'],
        'orden': 15,
      },
      {
        'titulo': 'Intermedio',
        'respuesta':
            'En nivel intermedio ya puedes manejar más volumen, más control técnico y una progresión mejor planeada.',
        'palabras_clave': ['intermedio', 'nivel medio', 'avanzar', 'progreso'],
        'orden': 16,
      },
      {
        'titulo': 'Avanzado',
        'respuesta':
            'En nivel avanzado se cuida mucho la recuperación, la técnica y la planificación del volumen. Ya no se trata de entrenar por entrenar.',
        'palabras_clave': ['avanzado', 'nivel alto', 'experto', 'pro'],
        'orden': 17,
      },
      {
        'titulo': 'Pecho',
        'respuesta':
            'Para pecho funcionan muy bien press de banca, fondos, aperturas y variaciones con mancuernas o polea.',
        'palabras_clave': ['pecho', 'pectorales', 'press banca', 'fondos', 'aperturas'],
        'orden': 18,
      },
      {
        'titulo': 'Espalda',
        'respuesta':
            'Para espalda destacan dominadas, remo con barra, jalones y remos en máquina.',
        'palabras_clave': ['espalda', 'dorsal', 'remo', 'dominadas', 'jalon', 'jalón'],
        'orden': 19,
      },
      {
        'titulo': 'Piernas',
        'respuesta':
            'Para piernas sirven mucho sentadillas, peso muerto, prensa, zancadas y variantes de glúteo.',
        'palabras_clave': ['piernas', 'sentadilla', 'peso muerto', 'prensa', 'zancadas', 'cuadriceps'],
        'orden': 20,
      },
      {
        'titulo': 'Hombros',
        'respuesta':
            'Para hombros puedes usar press militar, elevaciones laterales y trabajo de deltoides posterior.',
        'palabras_clave': ['hombros', 'deltoides', 'press militar', 'elevaciones laterales'],
        'orden': 21,
      },
      {
        'titulo': 'Bíceps',
        'respuesta':
            'Para bíceps los clásicos nunca fallan: curl con barra, curl con mancuernas y curl martillo.',
        'palabras_clave': ['biceps', 'bíceps', 'curl', 'martillo', 'brazo'],
        'orden': 22,
      },
      {
        'titulo': 'Tríceps',
        'respuesta':
            'Para tríceps funcionan muy bien extensiones en polea, press francés y fondos cerrados.',
        'palabras_clave': ['triceps', 'tríceps', 'extensión', 'press frances', 'press francés', 'polea'],
        'orden': 23,
      },
      {
        'titulo': 'Abdomen',
        'respuesta':
            'Para abdomen ayudan planchas, crunches y ejercicios de core que no solo quemen, sino que estabilicen bien.',
        'palabras_clave': ['abdomen', 'abs', 'core', 'crunch', 'plancha', 'abdominal'],
        'orden': 24,
      },
      {
        'titulo': 'Glúteos',
        'respuesta':
            'Para glúteos, hip thrust, sentadillas, zancadas y patadas en polea suelen ser de lo más efectivo.',
        'palabras_clave': ['gluteos', 'glúteos', 'hip thrust', 'gluteo', 'glúteo'],
        'orden': 25,
      },
      {
        'titulo': 'Cardio',
        'respuesta':
            'El cardio mejora la resistencia y ayuda a gastar calorías. Puedes usar caminadora, bici, cuerda o circuitos.',
        'palabras_clave': ['cardio', 'correr', 'bici', 'caminadora', 'quema calorias', 'quemar calorias'],
        'orden': 26,
      },
      {
        'titulo': 'Calentamiento',
        'respuesta':
            'Antes de entrenar conviene calentar entre 5 y 10 minutos con movilidad, activación y una serie ligera del ejercicio principal.',
        'palabras_clave': ['calentamiento', 'calentar', 'entrada en calor', 'warm up', 'activacion'],
        'orden': 27,
      },
      {
        'titulo': 'Estiramiento',
        'respuesta':
            'Después de entrenar puedes estirar suave los grupos trabajados para bajar tensión y mejorar movilidad.',
        'palabras_clave': ['estiramiento', 'estirar', 'movilidad', 'flexibilidad', 'stretch'],
        'orden': 28,
      },
      {
        'titulo': 'Descanso',
        'respuesta':
            'Descansar también cuenta como parte del progreso. Dormir bien y dejar recuperar al músculo marca mucha diferencia.',
        'palabras_clave': ['descanso', 'recuperacion', 'recuperación', 'dormir', 'sueño', 'sueno'],
        'orden': 29,
      },
      {
        'titulo': 'Proteína',
        'respuesta':
            'La proteína ayuda a recuperar y construir músculo. Buenas fuentes son pollo, huevo, atún, carne magra, yogur griego y legumbres.',
        'palabras_clave': ['proteina', 'proteína', 'pollo', 'huevo', 'atun', 'atún', 'yogur griego'],
        'orden': 30,
      },
      {
        'titulo': 'Carbohidratos',
        'respuesta':
            'Los carbohidratos dan energía para entrenar mejor. Avena, arroz, papa, camote y fruta son opciones útiles.',
        'palabras_clave': ['carbohidratos', 'carbos', 'arroz', 'avena', 'papa', 'camote', 'fruta'],
        'orden': 31,
      },
      {
        'titulo': 'Grasas saludables',
        'respuesta':
            'Las grasas saludables también son necesarias. Aguacate, nueces, aceite de oliva y semillas son buenos ejemplos.',
        'palabras_clave': ['grasas', 'saludable', 'aguacate', 'nueces', 'aceite de oliva', 'semillas'],
        'orden': 32,
      },
      {
        'titulo': 'Dieta para bajar peso',
        'respuesta':
            'Para bajar peso sirve comer con orden, priorizar proteína, controlar porciones y evitar exceso de azúcar o frituras.',
        'palabras_clave': ['dieta', 'bajar peso', 'perder peso', 'adelgazar', 'deficit', 'déficit'],
        'orden': 33,
      },
      {
        'titulo': 'Dieta para volumen',
        'respuesta':
            'Para volumen conviene comer un poco más de lo normal, repartir proteína en el día y meter suficientes carbohidratos.',
        'palabras_clave': ['volumen', 'comer mas', 'comer más', 'subir masa', 'ganar masa'],
        'orden': 34,
      },
      {
        'titulo': 'Agua',
        'respuesta':
            'Tomar agua es básico. Si entrenas fuerte o hace calor, necesitas hidratarte todavía más.',
        'palabras_clave': ['agua', 'hidratar', 'hidratacion', 'hidratación', 'sed'],
        'orden': 35,
      },
      {
        'titulo': 'Suplementos',
        'respuesta':
            'Los suplementos no hacen magia. Sirven solo si tu comida, sueño y entrenamiento ya van bien.',
        'palabras_clave': ['suplementos', 'proteina en polvo', 'creatina', 'preentreno', 'pre entreno'],
        'orden': 36,
      },
      {
        'titulo': 'Creatina',
        'respuesta':
            'La creatina es de los suplementos más usados para fuerza y rendimiento. Igual, primero va la base: comida y entrenamiento.',
        'palabras_clave': ['creatina', 'monohidrato', 'fuerza', 'rendimiento'],
        'orden': 37,
      },
      {
        'titulo': 'Protección de datos',
        'respuesta':
            'La aplicación solo guarda la información necesaria para funcionar. No pedimos datos raros ni innecesarios.',
        'palabras_clave': ['privacidad', 'datos', 'seguridad', 'proteger', 'confidencialidad'],
        'orden': 38,
      },
      {
        'titulo': 'Registro de progreso',
        'respuesta':
            'Sí, se puede llevar control de rutinas, avances y hábitos para ver mejor tu progreso con el tiempo.',
        'palabras_clave': ['progreso', 'avance', 'registro', 'seguimiento', 'historial'],
        'orden': 39,
      },
      {
        'titulo': 'Horarios de atención',
        'respuesta':
            'El horario de atención normal coincide con el horario de apertura del gimnasio. En recepción te confirman cualquier cambio.',
        'palabras_clave': ['atencion', 'atención', 'recepcion', 'recepción', 'soporte'],
        'orden': 40,
      },
      {
        'titulo': 'Plan familiar',
        'respuesta':
            'Si existe plan familiar, normalmente ofrece descuento por registrar a más de una persona. La disponibilidad depende de la promoción vigente.',
        'palabras_clave': ['familiar', 'familia', 'dos personas', 'grupo', 'pareja'],
        'orden': 41,
      },
      {
        'titulo': 'Facturación',
        'respuesta':
            'La facturación depende de la administración del gimnasio. Lo normal es solicitarla con tus datos de pago en recepción.',
        'palabras_clave': ['factura', 'facturacion', 'facturación', 'comprobante', 'recibo'],
        'orden': 42,
      },
      {
        'titulo': 'Cancelación',
        'respuesta':
            'Si quieres cancelar tu membresía, lo correcto es avisar en recepción para revisar el proceso y evitar cobros extra.',
        'palabras_clave': ['cancelar', 'cancelacion', 'cancelación', 'baja', 'salir'],
        'orden': 43,
      },
      {
        'titulo': 'Recomendación general',
        'respuesta':
            'La mejor rutina es la que sí puedes sostener. La más perfecta del mundo no sirve si la abandonas a la semana.',
        'palabras_clave': ['recomendacion', 'recomendación', 'que hago', 'que me recomiendas', 'rutina buena'],
        'orden': 44,
      },
      {
        'titulo': 'Entrenar en ayunas',
        'respuesta':
            'Entrenar en ayunas no es obligatorio ni mágico. A algunas personas les sirve, a otras les quita energía.',
        'palabras_clave': ['ayunas', 'en ayunas', 'sin desayunar', 'fasted'],
        'orden': 45,
      },
      {
        'titulo': 'Dolor muscular',
        'respuesta':
            'Un poco de molestia muscular puede ser normal, pero dolor fuerte o raro no se debe ignorar. Ahí conviene bajar carga y revisar técnica.',
        'palabras_clave': ['dolor', 'agujetas', 'molestia', 'lesion', 'lesión'],
        'orden': 46,
      },
      {
        'titulo': 'Técnica',
        'respuesta':
            'La técnica siempre va antes que levantar pesado. Mejor menos peso y bien hecho que más peso y hacer desastre.',
        'palabras_clave': ['tecnica', 'técnica', 'forma', 'postura', 'ejecucion', 'ejecución'],
        'orden': 47,
      },
      {
        'titulo': 'Recuperación',
        'respuesta':
            'La recuperación incluye sueño, comida, agua y descanso real. Sin eso, el cuerpo nomás acumula cansancio.',
        'palabras_clave': ['recuperacion', 'recuperación', 'fatiga', 'cansancio', 'descansar'],
        'orden': 48,
      },
      {
        'titulo': 'Ayuda humana',
        'respuesta':
            'Si la respuesta automática no te ayuda, puedes preguntar en recepción y te orientan directo.',
        'palabras_clave': ['ayuda', 'humano', 'persona', 'recepcion', 'recepción', 'asesor'],
        'orden': 49,
      },
    ];

    final batch = _db.batch();
    for (int i = 0; i < respuestas.length; i++) {
      final docId = 'resp_${(i + 1).toString().padLeft(3, '0')}';
      batch.set(_db.collection(_coleccion).doc(docId), respuestas[i]);
    }

    await batch.commit();
  }

static Future<void> cargarMas() async {
  final snap = await _db.collection(_coleccion).doc('resp_051').get();
  if (snap.exists) return;

  final respuestas = <Map<String, dynamic>>[
    {
      'titulo': 'Cómo empezar',
      'categoria': 'rutina',
      'respuesta': 'Si vas empezando, haz rutinas simples, aprende técnica y no te mates con demasiado volumen.',
      'palabras_clave': ['empezar', 'principiante', 'inicio', 'nuevo', 'rutina para empezar'],
      'orden': 50,
    },
    {
      'titulo': 'Días de entrenamiento',
      'categoria': 'rutina',
      'respuesta': 'Para la mayoría, 3 a 5 días por semana funciona muy bien. Lo importante es sostenerlo.',
      'palabras_clave': ['cuantos dias', 'días', 'semanas', 'frecuencia', 'entrenar por semana'],
      'orden': 51,
    },
    {
      'titulo': 'Calentamiento',
      'categoria': 'rutina',
      'respuesta': 'Antes de levantar peso, calienta 5 a 10 minutos y haz una serie ligera del ejercicio principal.',
      'palabras_clave': ['calentamiento', 'calentar', 'activar', 'entrada en calor'],
      'orden': 52,
    },
    {
      'titulo': 'Sentadilla',
      'categoria': 'rutina',
      'respuesta': 'En sentadilla, mantén espalda firme, baja controlado y empuja desde los talones al subir.',
      'palabras_clave': ['sentadilla', 'squat', 'piernas', 'cuádriceps'],
      'orden': 53,
    },
    {
      'titulo': 'Press de banca',
      'categoria': 'rutina',
      'respuesta': 'En press de banca, junta bien los omóplatos, controla la bajada y no rebotes la barra.',
      'palabras_clave': ['press banca', 'pecho', 'barra', 'banca'],
      'orden': 54,
    },
    {
      'titulo': 'Peso muerto',
      'categoria': 'rutina',
      'respuesta': 'En peso muerto, la espalda va neutra, la barra cerca del cuerpo y el levantamiento sale de piernas y cadera.',
      'palabras_clave': ['peso muerto', 'deadlift', 'espalda baja', 'cadena posterior'],
      'orden': 55,
    },
    {
      'titulo': 'Dolor muscular',
      'categoria': 'rutina',
      'respuesta': 'El dolor muscular leve puede ser normal, pero dolor punzante o raro no. Ahí toca bajar carga y revisar técnica.',
      'palabras_clave': ['dolor', 'agujetas', 'molestia', 'lesion', 'lesión'],
      'orden': 56,
    },
    {
      'titulo': 'Series y repeticiones',
      'categoria': 'rutina',
      'respuesta': 'Para ganar músculo suelen servir 3 a 4 series por ejercicio y repeticiones moderadas con buena técnica.',
      'palabras_clave': ['series', 'repeticiones', 'reps', 'cuantas series', 'cuántas series'],
      'orden': 57,
    },
    {
      'titulo': 'Descanso entre series',
      'categoria': 'rutina',
      'respuesta': 'En fuerza descansa más; en hipertrofia descansa menos. Entre 60 y 120 segundos suele ser común.',
      'palabras_clave': ['descanso', 'entre series', 'tiempo de descanso', 'pause'],
      'orden': 58,
    },
    {
      'titulo': 'Entrenar al fallo',
      'categoria': 'rutina',
      'respuesta': 'No todo se debe llevar al fallo. Úsalo con cuidado, sobre todo en ejercicios pesados.',
      'palabras_clave': ['fallo', 'al fallo', 'llegar al fallo'],
      'orden': 59,
    },
    {
      'titulo': 'Progresión',
      'categoria': 'rutina',
      'respuesta': 'Para progresar, intenta subir peso, repeticiones o control técnico poco a poco.',
      'palabras_clave': ['progreso', 'progresion', 'progresión', 'avanzar', 'mejorar'],
      'orden': 60,
    },
    {
      'titulo': 'Rutina para volumen',
      'categoria': 'rutina',
      'respuesta': 'Para volumen conviene meter básicos, suficiente comida y progresión constante.',
      'palabras_clave': ['volumen', 'masa muscular', 'ganar musculo', 'ganar músculo'],
      'orden': 61,
    },
    {
      'titulo': 'Rutina para definición',
      'categoria': 'rutina',
      'respuesta': 'Para definición sirve mantener fuerza, cuidar la comida y usar más control en el entrenamiento.',
      'palabras_clave': ['definicion', 'definición', 'quemar grasa', 'bajar grasa'],
      'orden': 62,
    },
    {
      'titulo': 'Full body',
      'categoria': 'rutina',
      'respuesta': 'Una rutina full body trabaja todo el cuerpo en la misma sesión. Va bien si no tienes muchos días libres.',
      'palabras_clave': ['full body', 'cuerpo completo', 'rutina completa'],
      'orden': 63,
    },
    {
      'titulo': 'Push Pull Legs',
      'categoria': 'rutina',
      'respuesta': 'Push Pull Legs separa empuje, jalón y piernas. Es una estructura muy ordenada para entrenar.',
      'palabras_clave': ['ppl', 'push pull legs', 'push', 'pull', 'legs'],
      'orden': 64,
    },
    {
      'titulo': 'Qué comer antes de entrenar',
      'categoria': 'nutricion',
      'respuesta': 'Antes de entrenar sirve algo ligero con carbohidrato y un poco de proteína. Nada demasiado pesado.',
      'palabras_clave': ['antes de entrenar', 'pre entreno', 'comer antes', 'energia'],
      'orden': 65,
    },
    {
      'titulo': 'Qué comer después de entrenar',
      'categoria': 'nutricion',
      'respuesta': 'Después de entrenar conviene meter proteína y una comida normal para recuperar mejor.',
      'palabras_clave': ['despues de entrenar', 'post entreno', 'recuperacion', 'recuperación'],
      'orden': 66,
    },
    {
      'titulo': 'Proteína diaria',
      'categoria': 'nutricion',
      'respuesta': 'La proteína ayuda a reparar músculo. Huevo, pollo, atún, yogur griego y legumbres son buenas opciones.',
      'palabras_clave': ['proteina', 'proteína', 'pollo', 'huevo', 'atun', 'atún'],
      'orden': 67,
    },
    {
      'titulo': 'Hidratación',
      'categoria': 'nutricion',
      'respuesta': 'Tomar agua durante el día y en el entrenamiento es básico. Si sudas mucho, más todavía.',
      'palabras_clave': ['agua', 'hidratacion', 'hidratación', 'hidratar'],
      'orden': 68,
    },
    {
      'titulo': 'Snacks saludables',
      'categoria': 'nutricion',
      'respuesta': 'Un snack útil puede ser yogur, fruta, nueces o un sándwich simple con buena proteína.',
      'palabras_clave': ['snack', 'colacion', 'colación', 'merienda', 'botana'],
      'orden': 69,
    },
    {
      'titulo': 'Desayuno rápido',
      'categoria': 'nutricion',
      'respuesta': 'Un desayuno rápido puede ser avena, fruta, huevo o yogur griego. Fácil y sin drama.',
      'palabras_clave': ['desayuno', 'rapido', 'rápido', 'mañana'],
      'orden': 70,
    },
    {
      'titulo': 'Cena ligera',
      'categoria': 'nutricion',
      'respuesta': 'Para cenar ligero puedes usar proteína, verduras y algo pequeño de carbohidrato si lo necesitas.',
      'palabras_clave': ['cena', 'ligera', 'noche', 'comida nocturna'],
      'orden': 71,
    },
    {
      'titulo': 'Comida para volumen',
      'categoria': 'nutricion',
      'respuesta': 'En volumen ayuda comer un poco más, sin olvidar proteína, carbohidratos y grasas sanas.',
      'palabras_clave': ['volumen', 'comer mas', 'comer más', 'superavit'],
      'orden': 72,
    },
    {
      'titulo': 'Comida para definición',
      'categoria': 'nutricion',
      'respuesta': 'En definición conviene controlar porciones y priorizar alimentos que llenen más con menos calorías.',
      'palabras_clave': ['definicion', 'definición', 'bajar peso', 'déficit'],
      'orden': 73,
    },
    {
      'titulo': 'Carbohidratos',
      'categoria': 'nutricion',
      'respuesta': 'Los carbohidratos dan energía. Arroz, avena, papa, camote y fruta son de los más útiles.',
      'palabras_clave': ['carbohidratos', 'carbos', 'arroz', 'avena', 'papa', 'camote'],
      'orden': 74,
    },
    {
      'titulo': 'Grasas saludables',
      'categoria': 'nutricion',
      'respuesta': 'Aguacate, nueces, semillas y aceite de oliva son grasas saludables que sí aportan bien.',
      'palabras_clave': ['grasas', 'aguacate', 'nueces', 'aceite de oliva'],
      'orden': 75,
    },
    {
      'titulo': 'Horario en festivos',
      'categoria': 'horario',
      'respuesta': 'En días festivos el horario puede cambiar. Lo mejor es confirmarlo antes de ir.',
      'palabras_clave': ['festivo', 'feriado', 'dia festivo', 'día festivo'],
      'orden': 76,
    },
    {
      'titulo': 'Horario de sábado',
      'categoria': 'horario',
      'respuesta': 'Los sábados normalmente manejamos horario reducido comparado con entre semana.',
      'palabras_clave': ['sabado', 'sábado', 'fin de semana'],
      'orden': 77,
    },
    {
      'titulo': 'Horario de mañana',
      'categoria': 'horario',
      'respuesta': 'Sí, puedes venir en la mañana. Abrimos temprano para que entrenes antes de tus clases o trabajo.',
      'palabras_clave': ['mañana', 'temprano', 'am', 'abren'],
      'orden': 78,
    },
    {
      'titulo': 'Horario de noche',
      'categoria': 'horario',
      'respuesta': 'También puedes entrenar por la noche mientras estemos dentro del horario de cierre.',
      'palabras_clave': ['noche', 'tarde', 'pm', 'cierran'],
      'orden': 79,
    },
    {
      'titulo': 'Atención al cliente',
      'categoria': 'horario',
      'respuesta': 'La atención en recepción coincide con el horario principal del gimnasio.',
      'palabras_clave': ['atencion', 'atención', 'recepcion', 'recepción', 'soporte'],
      'orden': 80,
    },
    {
      'titulo': 'Dirección',
      'categoria': 'ubicacion',
      'respuesta': 'Estamos en una zona de fácil acceso. Si quieres, luego te paso la dirección exacta en una respuesta fija.',
      'palabras_clave': ['direccion', 'dirección', 'ubicacion', 'ubicación'],
      'orden': 81,
    },
    {
      'titulo': 'Cómo llegar',
      'categoria': 'ubicacion',
      'respuesta': 'La forma más fácil de llegar es por la avenida principal o usando el mapa desde tu celular.',
      'palabras_clave': ['como llegar', 'cómo llegar', 'ruta', 'mapa'],
      'orden': 82,
    },
    {
      'titulo': 'Estacionamiento',
      'categoria': 'ubicacion',
      'respuesta': 'Si hay estacionamiento disponible, normalmente te lo confirman en recepción según el horario.',
      'palabras_clave': ['estacionamiento', 'parking', 'carro', 'auto'],
      'orden': 83,
    },
    {
      'titulo': 'Cerca de qué está',
      'categoria': 'ubicacion',
      'respuesta': 'La sucursal está cerca de calles principales y puntos fáciles de ubicar.',
      'palabras_clave': ['cerca', 'referencia', 'alrededor', 'zona'],
      'orden': 84,
    },
    {
      'titulo': 'Sucursal',
      'categoria': 'ubicacion',
      'respuesta': 'Si manejan más de una sucursal, la información exacta depende de la sede que estés consultando.',
      'palabras_clave': ['sucursal', 'sedes', 'sede', 'donde esta'],
      'orden': 85,
    },
    {
      'titulo': 'Precio de inscripción',
      'categoria': 'precio',
      'respuesta': 'La inscripción puede variar por promoción. Lo más seguro es revisar el costo vigente en recepción.',
      'palabras_clave': ['inscripcion', 'inscripción', 'registro', 'alta', 'precio'],
      'orden': 86,
    },
    {
      'titulo': 'Membresía más barata',
      'categoria': 'precio',
      'respuesta': 'La opción más barata suele ser la membresía básica o mensual. Depende de si hay promoción activa.',
      'palabras_clave': ['barata', 'barato', 'mas barata', 'más barata', 'economica', 'económica'],
      'orden': 87,
    },
    {
      'titulo': 'Plan anual',
      'categoria': 'precio',
      'respuesta': 'El plan anual suele salir mejor por mes, aunque requiere pagar más al inicio.',
      'palabras_clave': ['anual', 'año', 'ano', 'plan anual'],
      'orden': 88,
    },
    {
      'titulo': 'Formas de pago',
      'categoria': 'precio',
      'respuesta': 'Normalmente aceptamos efectivo y otros métodos según disponibilidad del momento.',
      'palabras_clave': ['pago', 'tarjeta', 'transferencia', 'efectivo', 'pagar'],
      'orden': 89,
    },
    {
      'titulo': 'Renovación',
      'categoria': 'precio',
      'respuesta': 'Puedes renovar tu membresía antes de que venza para no perder acceso.',
      'palabras_clave': ['renovar', 'renovacion', 'renovación', 'vencimiento'],
      'orden': 90,
    },
    {
      'titulo': 'Cancelación',
      'categoria': 'precio',
      'respuesta': 'Si quieres cancelar, lo correcto es avisar en recepción para que te expliquen el proceso.',
      'palabras_clave': ['cancelar', 'cancelacion', 'cancelación', 'baja'],
      'orden': 91,
    },
    {
      'titulo': 'Factura o recibo',
      'categoria': 'precio',
      'respuesta': 'La factura o el recibo se piden en administración con tus datos de pago.',
      'palabras_clave': ['factura', 'recibo', 'comprobante', 'facturacion', 'facturación'],
      'orden': 92,
    },
    {
      'titulo': 'Descuento',
      'categoria': 'precio',
      'respuesta': 'Los descuentos dependen de promociones activas, temporadas o paquetes especiales.',
      'palabras_clave': ['descuento', 'promo', 'promocion', 'promoción', 'oferta'],
      'orden': 93,
    },
    {
      'titulo': 'Plan familiar',
      'categoria': 'precio',
      'respuesta': 'Si existe plan familiar, normalmente baja el costo por persona.',
      'palabras_clave': ['familiar', 'familia', 'pareja', 'grupo'],
      'orden': 94,
    },
    {
      'titulo': 'Qué máquinas hay',
      'categoria': 'rutina',
      'respuesta': 'Normalmente hay máquinas, barras, mancuernas y equipo para cardio o trabajo funcional.',
      'palabras_clave': ['maquinas', 'máquinas', 'equipamiento', 'aparatos'],
      'orden': 95,
    },
    {
      'titulo': 'Rutina para perder grasa',
      'categoria': 'rutina',
      'respuesta': 'Una rutina para perder grasa combina fuerza, algo de cardio y constancia con la comida.',
      'palabras_clave': ['perder grasa', 'bajar grasa', 'quemar grasa', 'definicion'],
      'orden': 96,
    },
    {
      'titulo': 'Rutina para ganar fuerza',
      'categoria': 'rutina',
      'respuesta': 'Para ganar fuerza, usa ejercicios compuestos, repeticiones bajas y más descanso.',
      'palabras_clave': ['fuerza', 'fuerte', 'potencia', 'compuestos'],
      'orden': 97,
    },
    {
      'titulo': 'Dormir',
      'categoria': 'nutricion',
      'respuesta': 'Dormir bien es parte del progreso. Sin sueño, recuperas peor y rindes menos.',
      'palabras_clave': ['dormir', 'sueño', 'sueno', 'descanso'],
      'orden': 98,
    },
    {
      'titulo': 'Consejo general',
      'categoria': 'rutina',
      'respuesta': 'La mejor opción siempre es la que sí puedes sostener. Constancia > perfección.',
      'palabras_clave': ['consejo', 'general', 'recomendacion', 'recomendación'],
      'orden': 99,
    },
  ];

  final batch = _db.batch();
  for (int i = 0; i < respuestas.length; i++) {
    final docId = 'resp_${(i + 51).toString().padLeft(3, '0')}';
    batch.set(_db.collection(_coleccion).doc(docId), respuestas[i]);
  }

  await batch.commit();
}
}