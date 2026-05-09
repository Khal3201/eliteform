import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION SERVICE
// Gestiona notificaciones locales para:
//   • Eventos del carrusel del home (sincronizados desde Firestore)
//   • Estado de membresía (pago próximo: 4 días antes, pago pendiente)
//   • Notificación diaria motivacional cuando hay membresía activa
//
// Requiere en pubspec.yaml:
//   flutter_local_notifications: ^17.2.3
//   timezone: ^0.9.4
//
// Requiere en AndroidManifest.xml (dentro de <manifest>):
//   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
//   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
//   <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
//
// Requiere en AndroidManifest.xml (dentro de <application>):
//   <receiver android:exported="false"
//     android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
//   <receiver android:exported="false"
//     android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
//     <intent-filter>
//       <action android:name="android.intent.action.BOOT_COMPLETED"/>
//       <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
//     </intent-filter>
//   </receiver>
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  // IDs de notificaciones
  static const int _idPagoProximo = 1000;
  static const int _idPagoPendiente = 1001;
  static const int _idDiaria = 1002;
  static const int _baseEventos = 2000; // 2000 + índice del evento

  // ── Inicialización ────────────────────────────────────────────────────────
  Future<void> inicializar() async {
    if (_inicializado) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (_) {});

    _inicializado = true;
  }

  // ── Solicitar permiso de notificaciones (Android 13+) ─────────────────────
  Future<bool> solicitarPermiso() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  // ── Canal de notificaciones Android ───────────────────────────────────────
  AndroidNotificationDetails _canal(
      {String channelId = 'eliteform_general',
      String channelName = 'EliteForm',
      String channelDesc = 'Notificaciones de EliteForm',
      Importance importance = Importance.high,
      Priority priority = Priority.high}) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
    );
  }

  // ── Mostrar notificación inmediata ────────────────────────────────────────
  Future<void> mostrarInmediata({
    required int id,
    required String titulo,
    required String cuerpo,
    String channelId = 'eliteform_general',
  }) async {
    await inicializar();
    await _plugin.show(
      id,
      titulo,
      cuerpo,
      NotificationDetails(
          android: _canal(
              channelId: channelId,
              channelName: 'EliteForm',
              channelDesc: 'Notificaciones de EliteForm')),
    );
  }

  // ── Programar notificación a una fecha/hora específica ────────────────────
  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime cuando,
    String channelId = 'eliteform_general',
  }) async {
    await inicializar();
    final tzFecha = tz.TZDateTime.from(cuando, tz.local);
    if (tzFecha.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzFecha,
      NotificationDetails(
          android: _canal(
              channelId: channelId,
              channelName: 'EliteForm',
              channelDesc: 'Notificaciones de EliteForm')),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Cancelar notificación por ID ──────────────────────────────────────────
  Future<void> cancelar(int id) => _plugin.cancel(id);

  Future<void> cancelarTodas() => _plugin.cancelAll();

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE MEMBRESÍA
  // ══════════════════════════════════════════════════════════════════════════

  /// Llama a este método al iniciar la app o cuando cambia el estado de membresía.
  Future<void> sincronizarMembresia() async {
    await inicializar();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final membresiaActiva = data['membresia_activa'] == true;
    final pedidoId = data['pedido_id'] as String?;
    final proximoPagoTs = data['fecha_proximo_pago'] as Timestamp?;

    // Limpiar notificaciones de membresía anteriores
    await cancelar(_idPagoProximo);
    await cancelar(_idPagoPendiente);
    await cancelar(_idDiaria);

    // Estado: pago pendiente (pedido existe pero membresía no activa)
    if (!membresiaActiva && pedidoId != null) {
      await mostrarInmediata(
        id: _idPagoPendiente,
        titulo: '⏳ Pago pendiente — EliteForm',
        cuerpo:
            'Tu pedido está registrado. Acércate a recepción para completar el pago y activar tu membresía.',
        channelId: 'eliteform_membresia',
      );
    }

    // Estado: membresía activa → notificaciones de vencimiento
    if (membresiaActiva && proximoPagoTs != null) {
      final proximoPago = proximoPagoTs.toDate();
      final ahora = DateTime.now();
      final diasRestantes = proximoPago.difference(ahora).inDays;

      // Notificación con 4 días de anticipación
      final fechaAviso4Dias = proximoPago.subtract(const Duration(days: 4));
      if (fechaAviso4Dias.isAfter(ahora)) {
        await programar(
          id: _idPagoProximo,
          titulo: '📅 Tu membresía vence pronto — EliteForm',
          cuerpo:
              'Faltan 4 días para tu próximo pago. Renueva en recepción para no perder el acceso.',
          cuando: fechaAviso4Dias,
          channelId: 'eliteform_membresia',
        );
      } else if (diasRestantes <= 4 && diasRestantes >= 0) {
        // Ya estamos en los 4 días finales → notificación inmediata
        await mostrarInmediata(
          id: _idPagoProximo,
          titulo: '⚠️ Membresía por vencer — EliteForm',
          cuerpo: diasRestantes == 0
              ? '¡Hoy vence tu membresía! Renueva para mantener el acceso.'
              : 'Faltan $diasRestantes ${diasRestantes == 1 ? 'día' : 'días'} para que venza tu membresía.',
          channelId: 'eliteform_membresia',
        );
      }

      // Notificación diaria motivacional (a las 8 AM del día siguiente)
      final manana = DateTime(ahora.year, ahora.month, ahora.day + 1, 8, 0);
      await programar(
        id: _idDiaria,
        titulo: '💪 ¡Hoy es día de entrenamiento! — EliteForm',
        cuerpo:
            'No olvides registrar tu asistencia con el código QR al llegar al gym.',
        cuando: manana,
        channelId: 'eliteform_diaria',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE EVENTOS
  // Sincroniza los eventos activos de Firestore y programa una notificación
  // por cada uno con campo `notificar_en` (Timestamp).
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> sincronizarEventos() async {
    await inicializar();

    // Cancelar notificaciones de eventos previos (IDs 2000–2099)
    for (int i = _baseEventos; i < _baseEventos + 100; i++) {
      await cancelar(i);
    }

    final snap = await FirebaseFirestore.instance
        .collection('eventos')
        .where('activo', isEqualTo: true)
        .get();

    int idx = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final titulo = data['titulo'] as String? ?? 'Evento EliteForm';
      final descripcion = data['descripcion'] as String? ?? '';
      final notificarTs = data['notificar_en'] as Timestamp?;

      if (notificarTs != null) {
        await programar(
          id: _baseEventos + idx,
          titulo: '🗓 $titulo — EliteForm',
          cuerpo: descripcion.isNotEmpty
              ? descripcion
              : 'Próximo evento en el gym.',
          cuando: notificarTs.toDate(),
          channelId: 'eliteform_eventos',
        );
      }
      idx++;
    }
  }
}
