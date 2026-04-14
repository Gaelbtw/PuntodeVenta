import '../core/database/database_helper.dart';
import '../models/compras.dart';

class ComprasController {

  Future<int> insertar(Compras compra) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Compras', compra.toMap());
  }

  Future<List<Compras>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Compras');

    return result.map((e) => Compras.fromMap(e)).toList();
  }

  Future<int> actualizar(Compras compra) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Compras',
      compra.toMap(),
      where: 'id = ?',
      whereArgs: [compra.id],
    );
  }

  Future<int> eliminar(String id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Compras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}