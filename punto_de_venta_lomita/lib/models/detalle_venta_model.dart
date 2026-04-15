class DetalleVenta {
  final int idDetalleVenta;
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precio;

  DetalleVenta({
    required this.idDetalleVenta,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precio
  });

  Map<String, dynamic> toMap() {
    return {
      "id_detalle_venta": idDetalleVenta,
      "id_venta": idVenta,
      "id_producto": idProducto,
      "cantidad": cantidad,
      "precio": precio
    };
  }

  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      idDetalleVenta: map["id_detalle_venta"],
      idVenta: map["id_venta"],
      idProducto: map["id_producto"],
      cantidad: map["cantidad"],
      precio: map["precio"]
    );
  }
}