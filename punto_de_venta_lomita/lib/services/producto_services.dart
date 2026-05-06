import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/producto_model.dart';

class ProductoService {
  final dbHelper = DatabaseHelper();

  Future<int> insertar(Producto producto, int stockInicial) async {
    final db = await dbHelper.database;

    if (producto.nombre.isEmpty) {
      throw Exception("El nombre es obligatorio");
    }

    if (producto.precio <= 0) {
      throw Exception("Precio inválido");
    }

    if (producto.categoriaId == null) {
      throw Exception("Selecciona una categoría");
    }

    if (stockInicial < 0) {
      throw Exception("Stock inválido");
    }
    int id = await db.insert('Producto', producto.toMap());

    await db.insert('Inventario', {
      'id_producto': id,
      'cantidad': stockInicial,
    });

    return id;
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await dbHelper.database;

    final res = await db.query('Producto');

    return res.map((e) => Producto.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerConStock() async {
    final db = await dbHelper.database;

    final res = await db.rawQuery('''
      SELECT 
        p.id_producto,
        p.nombre,
        p.precio,
        p.id_categoria,
        c.nombre as categoria_nombre,
        p.estado,
        p.stock_minimo,
        IFNULL(i.cantidad, 0) as cantidad
      FROM Producto p
      LEFT JOIN Inventario i 
        ON p.id_producto = i.id_producto
      LEFT JOIN Categoria c
        ON p.id_categoria = c.id_categoria
    ''');

    return res;
  }

  // 🔥 ACTUALIZAR
  Future<int> actualizar(Producto producto) async {
    final db = await dbHelper.database;

    return await db.update(
      'Producto',
      producto.toMap(),
      where: 'id_producto = ?',
      whereArgs: [producto.idProducto],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;

    await db.delete('Inventario', where: 'id_producto = ?', whereArgs: [id]);

    return await db.delete('Producto', where: 'id_producto = ?', whereArgs: [id]);
  }

  Future<void> agregarStock(int idProducto, int cantidad) async {
    final db = await dbHelper.database;

    await db.rawUpdate('''
      UPDATE Inventario
      SET cantidad = cantidad + ?
      WHERE id_producto = ?
    ''', [cantidad, idProducto]);
  }

  Future<void> restarStock(int idProducto, int cantidad) async {
    final db = await dbHelper.database;

    final res = await db.rawQuery(
        'SELECT cantidad FROM Inventario WHERE id_producto = ?', [idProducto]);

    int actual = res.first['cantidad'] as int;

    if (actual < cantidad) throw Exception("Stock insuficiente");

    await db.rawUpdate('''
      UPDATE Inventario
      SET cantidad = cantidad - ?
      WHERE id_producto = ?
    ''', [cantidad, idProducto]);
  }
}