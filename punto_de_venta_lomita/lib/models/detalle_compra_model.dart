class DetalleCompra {
  final int idDetalleCompra;
  final int idCompra;
  final int idProducto;
  final double precio;

  DetalleCompra({
    required this.idDetalleCompra,
    required this.idCompra,
    required this.idProducto,
    required this.precio
  });

  Map<String, dynamic> toMap() {
    return {
      "id_detalle_compra": idDetalleCompra,
      "id_compra": idCompra,
      "id_producto": idProducto,
      "precio": precio
    };
  }

  factory DetalleCompra.fromMap(Map<String, dynamic> map) {
    return DetalleCompra(
      idDetalleCompra: map["id_detalle_compra"],
      idCompra: map["id_compra"],
      idProducto: map["id_producto"],
      precio: map["precio"]
    );
  }
}