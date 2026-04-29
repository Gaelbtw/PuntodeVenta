import '../core/database/database_helper.dart';
import '../models/producto_model.dart';

class ProductoService {

  Future<int> insertar(Producto producto) async {
  final db = await DatabaseHelper().database;

  int id = await db.insert('Producto', producto.toMap());

  await db.insert('Inventario', {
    "id_producto": id,
    "cantidad": 0,
  });

  return id;
}

  Future<List<Producto>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Producto');

    return result.map((e) => Producto.fromMap(e)).toList();
  }

  Future<int> actualizar(Producto producto) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Producto',
      producto.toMap(),
      where: 'id_producto = ?',
      whereArgs: [producto.idProducto],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Producto',
      where: 'id_producto = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerConStock() async {
    final db = await DatabaseHelper().database;

    final result = await db.rawQuery('''
      SELECT 
        Producto.id_producto,
        Producto.nombre,
        Producto.precio,
        IFNULL(Inventario.cantidad, 0) as cantidad
      FROM Producto
      LEFT JOIN Inventario 
      ON Producto.id_producto = Inventario.id_producto
    ''');
  return result;
}

Future<List<Producto>> obtenerProductosConPrecioCompra() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'Producto',
      where: 'precio_compra > 1'
      );

    return result.map((e) => Producto.fromMap(e)).toList();
  }

}