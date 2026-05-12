import '../core/database/database_helper.dart';
import '../models/pedidos_model.dart';

class PedidosController {

  /*Future<int> crearPedido(Pedidos pedido) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Pedidos', pedido.toMap());
  }*/

  Future<int> crearPedido(Pedidos pedido) async {

  final db = await DatabaseHelper().database;
  return await db.insert('Pedidos',pedido.toMap(),);
}

  Future<int> insertar(Pedidos pedido) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Pedidos', pedido.toMap());
  }

  Future<List<Pedidos>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Pedidos');

    return result.map((e) => Pedidos.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerPedidosConCliente() async {
    final db = await DatabaseHelper().database;

    return await db.rawQuery('''
      SELECT 
        p.*,
        c.nombre as cliente_nombre,
        c.telefono as cliente_telefono
      FROM Pedidos p
      LEFT JOIN Clientes c
        ON p.id_cliente = c.id_cliente
      ORDER BY p.id_pedido DESC
    ''');
  }

  Future<int> cambiarEstado(int id, String estado) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Pedidos',
      {"estado": estado},
      where: "id_pedido = ?",
      whereArgs: [id],
    );
  }

  Future<int> actualizar(Pedidos pedido) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Pedidos',
      pedido.toMap(),
      where: 'id_pedido = ?',
      whereArgs: [pedido.idPedido],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Pedidos',
      where: 'id_pedido = ?',
      whereArgs: [id],
    );
  }
}
