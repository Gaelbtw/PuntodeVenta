import '../core/database/database_helper.dart';
import '../models/producto_model.dart';

class ProductoService {

  Future<int> insertar(Producto producto, int stockInicial) async {
  final db = await DatabaseHelper().database;

  if (producto.precio <= 0) {
    throw Exception("Precio inválido");
  }

  if (stockInicial < 0) {
    throw Exception("Stock inválido");
  }

  int id = await db.insert('Producto', producto.toMap());

  await db.insert('Inventario', {
    "id_producto": id,
    "cantidad": stockInicial,
  });

  return id;
}

Future<List<Producto>> obtenerProductosConPrecioCompra() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Producto');

    return result.map((e) => Producto.fromMap(e)).toList();
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

    return await db.rawQuery('''
      SELECT 
        p.id_producto,
        p.nombre,
        p.precio,
        p.categoria,
        p.estado,
        p.stock_minimo,
        IFNULL(i.cantidad, 0) as cantidad
      FROM Producto p
      LEFT JOIN Inventario i 
      ON p.id_producto = i.id_producto
    ''');
  }

  Future<void> agregarStock(int idProducto, int cantidadNueva) async {
    final db = await DatabaseHelper().database;

    if (cantidadNueva <= 0) {
      throw Exception("Cantidad inválida");
    }

    final result = await db.query(
      "Inventario",
      where: "id_producto = ?",
      whereArgs: [idProducto],
    );

    int actual = result.first["cantidad"] as int;
    int nuevo = actual + cantidadNueva;

    await db.update(
      "Inventario",
      {"cantidad": nuevo},
      where: "id_producto = ?",
      whereArgs: [idProducto],
    );
  }

  Future<void> restarStock(int idProducto, int cantidad) async {
    final db = await DatabaseHelper().database;

    final result = await db.query(
      "Inventario",
      where: "id_producto = ?",
      whereArgs: [idProducto],
    );

    int actual = result.first["cantidad"] as int;

    if (cantidad > actual) {
      throw Exception("Stock insuficiente");
    }

    await db.update(
      "Inventario",
      {"cantidad": actual - cantidad},
      where: "id_producto = ?",
      whereArgs: [idProducto],
    );
  }
}

