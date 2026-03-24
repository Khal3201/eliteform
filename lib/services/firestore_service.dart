import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}
