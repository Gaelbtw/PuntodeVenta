class Pedidos {
  final int idPedido;
  final int idCliente;
  final String fecha;
  final String estado;
  
  Pedidos({
    required this.idPedido,
    required this.idCliente,
    required this.fecha,
    required this.estado
  });

  Map<String, dynamic> toMap() {
    return {
      "id_pedido": idPedido,
      "id_cliente": idCliente,
      "fecha": fecha,
      "estado": estado
    };
  }

  factory Pedidos.fromMap(Map<String, dynamic> map) {
    return Pedidos(
      idPedido: map["id_pedido"],
      idCliente: map["id_cliente"],
      fecha: map["fecha"],
      estado: map["estado"]
    );
  }
}