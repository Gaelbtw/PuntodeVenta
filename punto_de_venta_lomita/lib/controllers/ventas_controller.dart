import '../core/database/database_helper.dart';
import '../models/ventas_model.dart'; 

class VentasController {

  Future<int> insertar(Ventas venta) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Ventas', venta.toMap());
  }

  Future<void> insertarVentaCompleta(int idProducto, int cantidad, double total) async {
  final db = await DatabaseHelper().database;

  await db.transaction((txn) async {
    // 1. insertar ventas
    int idVenta = await txn.insert('Ventas', {
      "id_cliente": null,
      "id_usuario": 1,
      "fecha": DateTime.now().toString(),
      "total": total,
    });

    // 2. detalle venta
    await txn.insert('Detalle_Venta', {
      "id_venta": idVenta,
      "id_producto": idProducto,
      "cantidad": cantidad,
      "precio": total,
    });

    // 3. actualizar inventario
    await txn.rawUpdate('''
      UPDATE Inventario 
      SET cantidad = cantidad - ? 
      WHERE id_producto = ?
    ''', [cantidad, idProducto]);
  });
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