import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────
  // USUARIOS (funciones existentes sin cambios)
  // ─────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────
  // RUTINAS
  // ─────────────────────────────────────────────────────────────

  /// Obtiene todas las rutinas disponibles en el sistema.
  Stream<QuerySnapshot> getRutinas() {
    return _db.collection("rutinas").snapshots();
  }

  /// Obtiene la rutina asignada a un usuario específico.
  /// Primero lee el id_rutina del usuario, luego busca esa rutina.
  Future<RutinaModel?> getRutinaDeUsuario(String uid) async {
    final userDoc = await _db.collection("usuarios").doc(uid).get();
    if (!userDoc.exists) return null;

    final idRutina = userDoc.data()?["id_rutina"] as String?;
    if (idRutina == null || idRutina.isEmpty) return null;

    final rutinaDoc = await _db.collection("rutinas").doc(idRutina).get();
    if (!rutinaDoc.exists) return null;

    return RutinaModel.fromMap(
        rutinaDoc.id, rutinaDoc.data() as Map<String, dynamic>);
  }

  /// Stream reactivo de la rutina del usuario (se actualiza en tiempo real).
  Stream<RutinaModel?> streamRutinaDeUsuario(String uid) {
    return _db.collection("usuarios").doc(uid).snapshots().asyncMap(
      (userDoc) async {
        if (!userDoc.exists) return null;
        final idRutina = userDoc.data()?["id_rutina"] as String?;
        if (idRutina == null || idRutina.isEmpty) return null;

        final rutinaDoc = await _db.collection("rutinas").doc(idRutina).get();
        if (!rutinaDoc.exists) return null;

        return RutinaModel.fromMap(
            rutinaDoc.id, rutinaDoc.data() as Map<String, dynamic>);
      },
    );
  }

  /// Asigna una rutina existente a un usuario.
  Future<void> asignarRutinaAUsuario(String uid, String idRutina) async {
    await _db.collection("usuarios").doc(uid).update({
      "id_rutina": idRutina,
    });
  }

  /// Quita la rutina asignada a un usuario.
  Future<void> removerRutinaDeUsuario(String uid) async {
    await _db.collection("usuarios").doc(uid).update({
      "id_rutina": FieldValue.delete(),
    });
  }

  /// Crea una nueva rutina y la asigna al usuario indicado.
  Future<void> crearYAsignarRutina({
    required String uid,
    required String nombreRutina,
    required String objetivo,
    required String descripcion,
  }) async {
    final rutinaRef = await _db.collection("rutinas").add({
      "nombre_rutina": nombreRutina,
      "objetivo": objetivo,
      "descripcion": descripcion,
    });
    await _db.collection("usuarios").doc(uid).update({
      "id_rutina": rutinaRef.id,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // DIETAS
  // ─────────────────────────────────────────────────────────────

  /// Obtiene todas las dietas disponibles en el sistema.
  Stream<QuerySnapshot> getDietas() {
    return _db.collection("dietas").snapshots();
  }

  /// Obtiene la dieta asignada a un usuario específico.
  Future<DietaModel?> getDietaDeUsuario(String uid) async {
    final userDoc = await _db.collection("usuarios").doc(uid).get();
    if (!userDoc.exists) return null;

    final idDieta = userDoc.data()?["id_dieta"] as String?;
    if (idDieta == null || idDieta.isEmpty) return null;

    final dietaDoc = await _db.collection("dietas").doc(idDieta).get();
    if (!dietaDoc.exists) return null;

    return DietaModel.fromMap(
        dietaDoc.id, dietaDoc.data() as Map<String, dynamic>);
  }

  /// Stream reactivo de la dieta del usuario (se actualiza en tiempo real).
  Stream<DietaModel?> streamDietaDeUsuario(String uid) {
    return _db.collection("usuarios").doc(uid).snapshots().asyncMap(
      (userDoc) async {
        if (!userDoc.exists) return null;
        final idDieta = userDoc.data()?["id_dieta"] as String?;
        if (idDieta == null || idDieta.isEmpty) return null;

        final dietaDoc = await _db.collection("dietas").doc(idDieta).get();
        if (!dietaDoc.exists) return null;

        return DietaModel.fromMap(
            dietaDoc.id, dietaDoc.data() as Map<String, dynamic>);
      },
    );
  }

  /// Asigna una dieta existente a un usuario.
  Future<void> asignarDietaAUsuario(String uid, String idDieta) async {
    await _db.collection("usuarios").doc(uid).update({
      "id_dieta": idDieta,
    });
  }

  /// Quita la dieta asignada a un usuario.
  Future<void> removerDietaDeUsuario(String uid) async {
    await _db.collection("usuarios").doc(uid).update({
      "id_dieta": FieldValue.delete(),
    });
  }

  /// Crea una nueva dieta y la asigna al usuario indicado.
  Future<void> crearYAsignarDieta({
    required String uid,
    required String nombre,
    required int calorias,
    required String descripcion,
  }) async {
    final dietaRef = await _db.collection("dietas").add({
      "nombre": nombre,
      "calorias": calorias,
      "descripcion": descripcion,
    });
    await _db.collection("usuarios").doc(uid).update({
      "id_dieta": dietaRef.id,
    });
  }
}
