class Producto {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final double precio;

  const Producto({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  // Convertir objeto a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      "id_producto": idProducto,
      "nombre": nombre,
      "descripcion": descripcion,
      "precio": precio,
    };
  }

  // Convertir Map a objeto
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      idProducto: map["id_producto"],
      nombre: map["nombre"],
      descripcion: map["descripcion"],
      precio: map["precio"],
    );
  }
}