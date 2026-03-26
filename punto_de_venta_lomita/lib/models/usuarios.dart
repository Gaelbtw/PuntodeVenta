class Usuarios {
  int id;
  String nombre;
  String contra;
  String rol;

  Usuarios({
    required this.id,
    required this.nombre,
    required this.contra,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "contra": contra,
      "rol": rol,
    };
  }

   factory Usuarios.fromMap(Map<String, dynamic> map) {
    return Usuarios(
      id: map["id"],
      nombre: map["nombre"],
      contra: map["contra"],
      rol: map["rol"],
    );
  }
}

