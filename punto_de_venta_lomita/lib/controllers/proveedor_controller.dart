import '../core/database/database_helper.dart';
import '../models/proveedores_model.dart';

class ProveedorController {

  Future<int> insertar(Proveedores proveedor) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Proveedores', proveedor.toMap());
  }

  Future<List<Proveedores>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Proveedores');

    return result.map((e) => Proveedores.fromMap(e)).toList();
  }

  Future<int> actualizar(Proveedores proveedor) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Proveedores',
      proveedor.toMap(),
      where: 'id_proveedor = ?',
      whereArgs: [proveedor.idProveedor],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Proveedores',
      where: 'id_proveedor = ?',
      whereArgs: [id],
    );
  }
}
