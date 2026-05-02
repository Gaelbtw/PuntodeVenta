class Producto {
  final int? idProducto;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final int stockMinimo;
  final String estado;
  final double? precioCompra;

  const Producto({
    this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.stockMinimo = 5,
    this.estado = "Activo",
    this.precioCompra,
  });

  Map<String, dynamic> toMap() {
    return {
      "id_producto": idProducto,
      "nombre": nombre,
      "descripcion": descripcion,
      "precio": precio,
      "categoria": categoria,
      "stock_minimo": stockMinimo,
      "estado": estado,
      "precio_compra": precioCompra,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      idProducto: map["id_producto"],
      nombre: map["nombre"],
      descripcion: map["descripcion"] ?? "",
      precio: map["precio"],
      categoria: map["categoria"] ?? "",
      stockMinimo: map["stock_minimo"] ?? 5,
      estado: map["estado"] ?? "Activo",
      precioCompra: map["precio_compra"],
    );
  }
}