class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data["id_usuario"],
      nombre: data["nombre"],
      correo: data["correo"],
      telefono: data["telefono"],
    );
  }
}
