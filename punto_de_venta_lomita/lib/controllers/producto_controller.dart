import '../core/database/database_helper.dart';
import '../models/producto_model.dart';
import 'auditoria_controller.dart';

class ProductoService {
  final _auditoriaController = AuditoriaController();

  Future<int> insertar(Producto producto) async {
    final db = await DatabaseHelper().database;

    final id = await db.insert('Producto', producto.toMap());

    await db.insert('Inventario', {
      "id_producto": id,
      "cantidad": 0,
    });

    await _auditoriaController.registrar(
      tabla: 'Productos',
      accion: 'CREATE',
      idRegistro: id,
      descripcion: 'Producto ${producto.nombre} creado',
    );

    return id;
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Producto');

    return result.map((e) => Producto.fromMap(e)).toList();
  }

  Future<int> actualizar(Producto producto) async {
    final db = await DatabaseHelper().database;

    final rows = await db.update(
      'Producto',
      producto.toMap(),
      where: 'id_producto = ?',
      whereArgs: [producto.idProducto],
    );

    if (rows > 0) {
      await _auditoriaController.registrar(
        tabla: 'Productos',
        accion: 'EDIT',
        idRegistro: producto.idProducto,
        descripcion: 'Producto ${producto.nombre} actualizado',
      );
    }

    return rows;
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;
    final producto = await db.query(
      'Producto',
      columns: ['nombre'],
      where: 'id_producto = ?',
      whereArgs: [id],
      limit: 1,
    );

    final rows = await db.delete(
      'Producto',
      where: 'id_producto = ?',
      whereArgs: [id],
    );

    if (rows > 0) {
      await _auditoriaController.registrar(
        tabla: 'Productos',
        accion: 'DELETE',
        idRegistro: id,
        descripcion: producto.isNotEmpty
            ? 'Producto ${producto.first["nombre"]} eliminado'
            : 'Producto eliminado',
      );
    }

    return rows;
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
}
