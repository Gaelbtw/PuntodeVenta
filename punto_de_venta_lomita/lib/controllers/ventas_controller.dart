import '../core/database/database_helper.dart';
import '../models/ventas_model.dart';

class VentasController {
  final dbHelper = DatabaseHelper();

  Future<int> insertar(Ventas venta) async {
    final db = await dbHelper.database;
    return await db.insert('Ventas', venta.toMap());
  }

  Future<void> insertarVentaCompleta(
    List<Map<String, dynamic>> carrito,
    double total,
    String metodoPago,
    {int? idCliente}
  ) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
    
      int idVenta = await txn.insert('Ventas', {
        "id_cliente": idCliente,
        "id_usuario": 1, // luego puedes hacerlo dinámico
        "fecha": DateTime.now().toIso8601String(),
        "total": total,
        "metodo_pago": metodoPago,
      });

      for (var item in carrito) {
        final stock = await txn.rawQuery(
          'SELECT cantidad FROM Inventario WHERE id_producto = ?',
          [item['id_producto']],
        );

        if (stock.isEmpty) {
          throw Exception("Producto sin inventario");
        }

        final disponible = stock.first['cantidad'] as int;

        if (disponible < item['cantidad']) {
          throw Exception(
              "Stock insuficiente para producto ID ${item['id_producto']}");
        }

        await txn.insert('Detalle_Venta', {
          "id_venta": idVenta,
          "id_producto": item['id_producto'],
          "cantidad": item['cantidad'],
          "precio": item['precio'], // precio unitario
        });

        await txn.rawUpdate('''
          UPDATE Inventario 
          SET cantidad = cantidad - ? 
          WHERE id_producto = ?
        ''', [
          item['cantidad'],
          item['id_producto']
        ]);
      }
    });
  }

  Future<List<Ventas>> obtenerTodos() async {
    final db = await dbHelper.database;

    final result = await db.query(
      'Ventas',
      orderBy: 'fecha DESC',
    );

    return result.map((e) => Ventas.fromMap(e)).toList();
  }

  Future<int> actualizar(Ventas venta) async {
    if (venta.idVenta == null) {
      throw Exception("La venta no tiene ID");
    }

    final db = await dbHelper.database;

    return await db.update(
      'Ventas',
      venta.toMap(),
      where: 'id_venta = ?',
      whereArgs: [venta.idVenta],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      'Ventas',
      where: 'id_venta = ?',
      whereArgs: [id],
    );
  }
}