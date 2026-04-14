class Proveedores {
  final int idProveedor;
  final String nombre;
  final String direccion;
  final int telefono;

  Proveedores({
    required this.idProveedor,
    required this.nombre,
    required this.direccion,
    required this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_proveedor": idProveedor,
      "nombre": nombre,
      "direccion": direccion,
      "telefono": telefono,
    };
  }

  factory Proveedores.fromMap(Map<String, dynamic> map) {
    return Proveedores(
      idProveedor: map["id_proveedor"],
      nombre: map["nombre"],
      direccion: map["direccion"],
      telefono: map["telefono"],
    );
  }
}