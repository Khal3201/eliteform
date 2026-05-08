import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AVISO DE PRIVACIDAD — PANTALLA COMPLETA
// Accesible desde: Registro (antes de crear cuenta) y Perfil (siempre visible)
// ═══════════════════════════════════════════════════════════════════════════════

class AvisoPrivacidadPage extends StatelessWidget {
  const AvisoPrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso de Privacidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Encabezado ────────────────────────────────────────────────────
          _EncabezadoAviso(),
          const SizedBox(height: 24),

          // ── Secciones ─────────────────────────────────────────────────────
          _Seccion(
            numero: '1',
            titulo: 'Identidad del Responsable',
            icono: Icons.business,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaInfo(label: 'Aplicación', valor: 'EliteForm'),
                _FilaInfo(label: 'Contacto', valor: 'khalebreyes06@gmail.com'),
                _FilaInfo(label: 'Plataformas', valor: 'Android'),
                const SizedBox(height: 10),
                const Text(
                  'EliteForm es una aplicación de gestión integral de gimnasio '
                  'que permite a los usuarios acceder a rutinas de entrenamiento '
                  'personalizadas, planes alimenticios, control de membresías y '
                  'registro de asistencia mediante código QR.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),

          _Seccion(
            numero: '2',
            titulo: 'Datos Personales que Recopilamos',
            icono: Icons.person,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubTitulo('Datos de identificación y contacto'),
                _Punto('Nombre completo'),
                _Punto('Correo electrónico (identificador de cuenta)'),
                _Punto('Número de teléfono celular (10 dígitos)'),
                const SizedBox(height: 10),
                _SubTitulo('Datos de autenticación'),
                _Punto(
                    'Contraseña cifrada gestionada por Firebase Authentication (EliteForm nunca la ve en texto plano)'),
                _Punto('Token de sesión generado automáticamente por Firebase'),
                const SizedBox(height: 10),
                _SubTitulo('Datos de actividad y servicio'),
                _Punto(
                    'Plan de membresía y su estado (activo, pendiente, cancelado)'),
                _Punto('Método de pago seleccionado y monto'),
                _Punto('Rutinas de entrenamiento activas o creadas'),
                _Punto('Planes alimenticios activos o seleccionados'),
                _Punto(
                    'Registro de asistencia al gimnasio (entrada/salida mediante QR)'),
                _Punto('Estado de presencia en instalaciones (tiempo real)'),
                const SizedBox(height: 10),
                _AvisoBox(
                  'Datos futuros planificados',
                  'En versiones próximas se planea solicitar peso corporal y estatura '
                      'para calcular métricas personalizadas (IMC, progreso físico). '
                      'Serán opcionales y requerirán consentimiento explícito.',
                ),
              ],
            ),
          ),

          _Seccion(
            numero: '3',
            titulo: 'Finalidad del Uso de tus Datos',
            icono: Icons.track_changes,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubTitulo('Finalidades necesarias'),
                _Punto('Crear, autenticar y gestionar tu cuenta'),
                _Punto('Administrar tu membresía, pedidos y pagos'),
                _Punto(
                    'Asignarte rutinas de entrenamiento y planes alimenticios'),
                _Punto('Registrar tu entrada y salida al gimnasio mediante QR'),
                _Punto(
                    'Mostrar en tiempo real el número de personas en el gimnasio'),
                const SizedBox(height: 10),
                _SubTitulo('Finalidades secundarias (puedes oponerte)'),
                _Punto(
                    'Enviarte notificaciones sobre renovación de membresía y eventos'),
                _Punto('Generar estadísticas anónimas de uso del gimnasio'),
                _Punto('Mejorar la experiencia de usuario'),
              ],
            ),
          ),

          _Seccion(
            numero: '4',
            titulo: 'Permisos que Solicita la App',
            icono: Icons.security,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TarjetaPermiso(
                  icono: Icons.camera_alt,
                  permiso: 'Cámara',
                  plataforma: 'Android',
                  proposito:
                      'Exclusivamente para escanear códigos QR de entrada y salida al gimnasio. '
                      'No se graban ni almacenan imágenes.',
                ),
                const SizedBox(height: 8),
                _TarjetaPermiso(
                  icono: Icons.wifi,
                  permiso: 'Internet',
                  plataforma: 'Todas las plataformas',
                  proposito:
                      'Necesario para conectar con Firebase: autenticación, base de datos y '
                      'sincronización en tiempo real.',
                ),
                const SizedBox(height: 8),
                _TarjetaPermiso(
                  icono: Icons.folder_open,
                  permiso: 'Archivos (opcional)',
                  plataforma: 'Android',
                  proposito:
                      'Solo cuando el usuario elige importar rutinas o dietas desde archivos .json. '
                      'No se accede a otros archivos.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.blueAccent.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline,
                          color: Colors.blueAccent, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin acceso a: micrófono, GPS, galería fotográfica, contactos, '
                          'SMS, historial de llamadas ni Bluetooth.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _Seccion(
            numero: '5',
            titulo: 'Transferencia de Datos a Terceros',
            icono: Icons.share,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubTitulo('Proveedores de infraestructura'),
                _Punto(
                    'Firebase Authentication (Google LLC) — Gestión de identidad'),
                _Punto(
                    'Cloud Firestore (Google LLC) — Base de datos en la nube'),
                const SizedBox(height: 8),
                const Text(
                  'Google actúa como encargado del tratamiento bajo estándares ISO 27001 y SOC 2.',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                _SubTitulo('Lo que NO hacemos'),
                _Punto('No vendemos ni compartimos tus datos con anunciantes'),
                _Punto(
                    'No transferimos información con fines comerciales propios'),
                _Punto('No utilizamos tus datos para perfilado publicitario'),
              ],
            ),
          ),

          _Seccion(
            numero: '6',
            titulo: 'Cómo Protegemos tus Datos',
            icono: Icons.lock,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Punto(
                    'Contraseñas cifradas con bcrypt via Firebase Authentication — EliteForm nunca las ve'),
                _Punto(
                    'Sesiones gestionadas con tokens JWT firmados y caducidad automática'),
                _Punto(
                    'Toggle ocultar/mostrar contraseña en todas las pantallas de ingreso'),
                _Punto(
                    'Validación de credenciales antes de permitir el acceso'),
                _Punto(
                    'Cierre de sesión que invalida el token en Firebase y limpia la navegación'),
                _Punto('Toda la comunicación se realiza sobre HTTPS/TLS'),
                _Punto(
                    'Cada usuario solo puede acceder a sus propios datos en Firestore'),
              ],
            ),
          ),

          _Seccion(
            numero: '7',
            titulo: 'Tus Derechos (ARCO+)',
            icono: Icons.gavel,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DerechoTile(
                  letra: 'A',
                  titulo: 'Acceso',
                  desc:
                      'Saber qué datos tenemos almacenados sobre ti y cómo los usamos.',
                ),
                _DerechoTile(
                  letra: 'R',
                  titulo: 'Rectificación',
                  desc:
                      'Corregir datos incorrectos. Puedes hacerlo directamente desde la sección Perfil de la app.',
                ),
                _DerechoTile(
                  letra: 'C',
                  titulo: 'Cancelación',
                  desc:
                      'Solicitar la eliminación de tus datos cuando ya no sean necesarios o retires tu consentimiento.',
                ),
                _DerechoTile(
                  letra: 'O',
                  titulo: 'Oposición',
                  desc:
                      'Oponerte al tratamiento de tus datos para finalidades secundarias.',
                ),
                const SizedBox(height: 10),
                _AvisoBox(
                  'Cómo ejercer tus derechos',
                  'Dirígete a Perfil > Eliminar cuenta, o envía un correo a '
                      'khalebreyes06@gmail.com con asunto "Ejercicio de Derechos ARCO". '
                      'Responderemos en máximo 15 días hábiles.',
                ),
              ],
            ),
          ),

          _Seccion(
            numero: '8',
            titulo: 'Eliminación de Cuenta',
            icono: Icons.delete_forever,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubTitulo('Desde la app (inmediata)'),
                _Punto('Ve a la pestaña Perfil'),
                _Punto('Toca "Eliminar cuenta"'),
                _Punto('Confirma en el diálogo de verificación'),
                const SizedBox(height: 8),
                const Text(
                  'Al confirmar se eliminan: tu perfil, pedidos asociados y cuenta de Firebase.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                _SubTitulo('Por correo electrónico'),
                const Text(
                  'Envía un correo a khalebreyes06@gmail.com con el asunto "Eliminar mi cuenta". '
                  'Procesaremos tu solicitud en máximo 5 días hábiles.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),

          _Seccion(
            numero: '9',
            titulo: 'Conservación de Datos',
            icono: Icons.schedule,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaInfo(
                    label: 'Cuenta activa',
                    valor: 'Mientras mantengas tu cuenta'),
                _FilaInfo(
                    label: 'Tras eliminar cuenta',
                    valor: 'Eliminación en 48 horas'),
                _FilaInfo(
                    label: 'Historial de asistencias',
                    valor: 'Se elimina con la cuenta'),
                _FilaInfo(
                    label: 'Registros de pagos',
                    valor: 'Hasta 5 años (obligación legal)'),
              ],
            ),
          ),

          _Seccion(
            numero: '10',
            titulo: 'Cambios a este Aviso',
            icono: Icons.update,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Punto(
                    'Te notificaremos por correo o dentro de la app ante cambios relevantes'),
                _Punto(
                    'La fecha de actualización visible en la app será modificada'),
                _Punto(
                    'Para cambios sustanciales se solicitará tu consentimiento nuevamente'),
                _Punto(
                    'El aviso vigente siempre estará accesible desde tu Perfil'),
              ],
            ),
          ),

          _Seccion(
            numero: '11',
            titulo: 'Contacto',
            icono: Icons.email,
            contenido: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaInfo(label: 'Correo', valor: 'khalebreyes06@gmail.com'),
                _FilaInfo(
                    label: 'Asunto para ARCO',
                    valor: '"Ejercicio de Derechos ARCO"'),
                _FilaInfo(
                    label: 'Tiempo de respuesta',
                    valor: 'Máximo 15 días hábiles'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pie de página
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'EliteForm — Aviso de Privacidad v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'khalebreyes06@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Entrena. Mejora. Supera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _EncabezadoAviso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orangeAccent.withOpacity(0.25),
            const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.privacy_tip,
                    color: Colors.orangeAccent, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aviso de Privacidad',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      'EliteForm v1.0 · 2026',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Este aviso describe cómo EliteForm recopila, usa y protege tus datos personales. '
            'Te recomendamos leerlo completo antes de crear tu cuenta.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String numero;
  final String titulo;
  final IconData icono;
  final Widget contenido;

  const _Seccion({
    required this.numero,
    required this.titulo,
    required this.icono,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: const Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    numero,
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icono, color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: contenido,
          ),
        ],
      ),
    );
  }
}

class _SubTitulo extends StatelessWidget {
  final String texto;
  const _SubTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  final String texto;
  const _Punto(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5, right: 8),
            child: Icon(Icons.circle, color: Colors.orangeAccent, size: 6),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _FilaInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoBox extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  const _AvisoBox(this.titulo, this.cuerpo);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Colors.orangeAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cuerpo,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPermiso extends StatelessWidget {
  final IconData icono;
  final String permiso;
  final String plataforma;
  final String proposito;

  const _TarjetaPermiso({
    required this.icono,
    required this.permiso,
    required this.plataforma,
    required this.proposito,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: Colors.orangeAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permiso,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Text(
                  plataforma,
                  style:
                      const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  proposito,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DerechoTile extends StatelessWidget {
  final String letra;
  final String titulo;
  final String desc;
  const _DerechoTile(
      {required this.letra, required this.titulo, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
            ),
            child: Text(
              letra,
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
