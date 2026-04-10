import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════
  // USUARIOS  (funciones originales intactas)
  // ═══════════════════════════════════════════════════════════════

  Future createUser({
    required String uid,
    required String nombre,
    required String correo,
    required String telefono,
  }) async {
    await _db.collection("usuarios").doc(uid).set({
      "id_usuario": uid,
      "nombre": nombre,
      "correo": correo,
      "telefono": telefono,
      "fecha_registro": FieldValue.serverTimestamp(),
    });
  }

  Future updateUser(uid, nombre, telefono) async {
    await _db.collection("usuarios").doc(uid).update({
      "nombre": nombre,
      "telefono": telefono,
    });
  }

  Future deleteUser(uid) async {
    await _db.collection("usuarios").doc(uid).delete();
  }

  Stream<QuerySnapshot> getUsers() {
    return _db.collection("usuarios").snapshots();
  }

  // ═══════════════════════════════════════════════════════════════
  // RUTINAS — catálogo global (colección raíz "rutinas")
  // ═══════════════════════════════════════════════════════════════

  /// Todas las rutinas del admin (creado_por == 'admin')
  Stream<QuerySnapshot> getRutinasAdmin() {
    return _db
        .collection('rutinas')
        .where('creado_por', isEqualTo: 'admin')
        .snapshots();
  }

  /// Rutinas creadas por un usuario concreto
  Stream<QuerySnapshot> getRutinasDeUsuario(String uid) {
    return _db
        .collection('rutinas')
        .where('creado_por', isEqualTo: uid)
        .snapshots();
  }

  /// Todas las rutinas admin filtradas por objetivo
  Stream<QuerySnapshot> getRutinasAdminPorObjetivo(String objetivo) {
    return _db
        .collection('rutinas')
        .where('creado_por', isEqualTo: 'admin')
        .where('objetivo', isEqualTo: objetivo)
        .snapshots();
  }

  /// Crea una rutina (admin o usuario)
  Future<String> crearRutina(RutinaModel rutina) async {
    final ref = await _db.collection('rutinas').add(rutina.toMap());
    return ref.id;
  }

  /// Elimina una rutina
  Future<void> eliminarRutina(String idRutina) async {
    await _db.collection('rutinas').doc(idRutina).delete();
  }

  /// Obtiene una rutina por id
  Future<RutinaModel?> getRutinaPorId(String idRutina) async {
    final doc = await _db.collection('rutinas').doc(idRutina).get();
    if (!doc.exists) return null;
    return RutinaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════════
  // RUTINA ACTIVA del usuario (campo en doc de usuario)
  // ═══════════════════════════════════════════════════════════════

  /// Stream reactivo de la rutina activa del usuario
  Stream<RutinaModel?> streamRutinaActiva(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots().asyncMap(
      (snap) async {
        final idRutina = snap.data()?['id_rutina_activa'] as String?;
        if (idRutina == null || idRutina.isEmpty) return null;
        return getRutinaPorId(idRutina);
      },
    );
  }

  /// Activa una rutina para el usuario
  Future<void> activarRutina(String uid, String idRutina) async {
    await _db.collection('usuarios').doc(uid).update({
      'id_rutina_activa': idRutina,
    });
  }

  /// Abandona la rutina activa
  Future<void> abandonarRutina(String uid) async {
    await _db.collection('usuarios').doc(uid).update({
      'id_rutina_activa': FieldValue.delete(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // DIETAS — catálogo global (colección raíz "dietas")
  // ═══════════════════════════════════════════════════════════════

  /// Todas las dietas del admin
  Stream<QuerySnapshot> getDietasAdmin() {
    return _db
        .collection('dietas')
        .where('creado_por', isEqualTo: 'admin')
        .snapshots();
  }

  /// Dietas admin filtradas por objetivo
  Stream<QuerySnapshot> getDietasAdminPorObjetivo(String objetivo) {
    return _db
        .collection('dietas')
        .where('creado_por', isEqualTo: 'admin')
        .where('objetivo', isEqualTo: objetivo)
        .snapshots();
  }

  /// Dietas admin filtradas por preferencia
  Stream<QuerySnapshot> getDietasAdminPorPreferencia(String preferencia) {
    return _db
        .collection('dietas')
        .where('creado_por', isEqualTo: 'admin')
        .where('preferencias_compatibles', arrayContains: preferencia)
        .snapshots();
  }

  /// Crea una dieta
  Future<String> crearDieta(DietaModel dieta) async {
    final ref = await _db.collection('dietas').add(dieta.toMap());
    return ref.id;
  }

  /// Elimina una dieta
  Future<void> eliminarDieta(String idDieta) async {
    await _db.collection('dietas').doc(idDieta).delete();
  }

  /// Obtiene una dieta por id
  Future<DietaModel?> getDietaPorId(String idDieta) async {
    final doc = await _db.collection('dietas').doc(idDieta).get();
    if (!doc.exists) return null;
    return DietaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════════
  // DIETA ACTIVA del usuario
  // ═══════════════════════════════════════════════════════════════

  Stream<DietaModel?> streamDietaActiva(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots().asyncMap(
      (snap) async {
        final idDieta = snap.data()?['id_dieta_activa'] as String?;
        if (idDieta == null || idDieta.isEmpty) return null;
        return getDietaPorId(idDieta);
      },
    );
  }

  Future<void> activarDieta(String uid, String idDieta) async {
    await _db.collection('usuarios').doc(uid).update({
      'id_dieta_activa': idDieta,
    });
  }

  Future<void> abandonarDieta(String uid) async {
    await _db.collection('usuarios').doc(uid).update({
      'id_dieta_activa': FieldValue.delete(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // Admin: asignación directa (panel admin — users_list)
  // ═══════════════════════════════════════════════════════════════

  Future<void> adminAsignarRutina(String uid, String idRutina) =>
      activarRutina(uid, idRutina);

  Future<void> adminRemoverRutina(String uid) => abandonarRutina(uid);

  Future<void> adminAsignarDieta(String uid, String idDieta) =>
      activarDieta(uid, idDieta);

  Future<void> adminRemoverDieta(String uid) => abandonarDieta(uid);
}
