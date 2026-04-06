class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? idRutina;
  final String? idDieta;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.idRutina,
    this.idDieta,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data["id_usuario"],
      nombre: data["nombre"],
      correo: data["correo"],
      telefono: data["telefono"],
      idRutina: data["id_rutina"],
      idDieta: data["id_dieta"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id_usuario": id,
      "nombre": nombre,
      "correo": correo,
      "telefono": telefono,
      if (idRutina != null) "id_rutina": idRutina,
      if (idDieta != null) "id_dieta": idDieta,
    };
  }
}

class RutinaModel {
  final String id;
  final String nombreRutina;
  final String objetivo;
  final String descripcion;

  RutinaModel({
    required this.id,
    required this.nombreRutina,
    required this.objetivo,
    required this.descripcion,
  });

  factory RutinaModel.fromMap(String id, Map<String, dynamic> data) {
    return RutinaModel(
      id: id,
      nombreRutina: data["nombre_rutina"] ?? "",
      objetivo: data["objetivo"] ?? "",
      descripcion: data["descripcion"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nombre_rutina": nombreRutina,
      "objetivo": objetivo,
      "descripcion": descripcion,
    };
  }
}

class DietaModel {
  final String id;
  final String nombre;
  final int calorias;
  final String descripcion;

  DietaModel({
    required this.id,
    required this.nombre,
    required this.calorias,
    required this.descripcion,
  });

  factory DietaModel.fromMap(String id, Map<String, dynamic> data) {
    return DietaModel(
      id: id,
      nombre: data["nombre"] ?? "",
      calorias: data["calorias"] ?? 0,
      descripcion: data["descripcion"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "calorias": calorias,
      "descripcion": descripcion,
    };
  }
}
