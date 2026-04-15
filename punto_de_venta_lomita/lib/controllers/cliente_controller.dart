import '../core/database/database_helper.dart';
import '../models/cliente_model.dart';

class ClienteController {

  Future<int> insertar(Cliente cliente) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Clientes', cliente.toMap());
  }

  Future<List<Cliente>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Clientes');

    return result.map((e) => Cliente.fromMap(e)).toList();
  }

  Future<int> actualizar(Cliente cliente) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Clientes',
      cliente.toMap(),
      where: 'id_cliente = ?',
      whereArgs: [cliente.idCliente],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Clientes',
      where: 'id_cliente = ?',
      whereArgs: [id],
    );
  }
}