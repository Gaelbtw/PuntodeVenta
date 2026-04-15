import '../core/database/database_helper.dart';
import '../models/cliente_model.dart';

class ClienteController {

  Future<int> insertar(Cliente cliente) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Cliente', cliente.toMap());
  }

  Future<List<Cliente>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Cliente');

    return result.map((e) => Cliente.fromMap(e)).toList();
  }

  Future<int> actualizar(Cliente cliente) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Cliente',
      cliente.toMap(),
      where: 'id_cliente = ?',
      whereArgs: [cliente.idCliente],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Cliente',
      where: 'id_cliente = ?',
      whereArgs: [id],
    );
  }
}