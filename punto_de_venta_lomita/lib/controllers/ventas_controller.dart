import '../core/database/database_helper.dart';
import '../models/ventas.dart'; 

class VentasController {

  Future<int> insertar(Ventas venta) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Ventas', venta.toMap());
  }

  Future<List<Ventas>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Ventas');

    return result.map((e) => Ventas.fromMap(e)).toList();
  }

  Future<int> actualizar(Ventas venta) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Ventas',
      venta.toMap(),
      where: 'id_venta = ?',
      whereArgs: [venta.idVenta],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Ventas',
      where: 'id_venta = ?',
      whereArgs: [id],
    );
  }
}