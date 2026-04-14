import '../core/database/database_helper.dart';
import '../models/usuarios.dart';

class UsuariosController {

  Future<int> insertar(Usuarios usuario) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Usuarios', usuario.toMap());
  }

  Future<List<Usuarios>> obtenerTodos() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Usuarios');

    return result.map((e) => Usuarios.fromMap(e)).toList();
  }

  Future<int> actualizar(Usuarios usuario) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      'Usuarios',
      usuario.toMap(),
      where: 'id_usuario = ?',
      whereArgs: [usuario.idUsuario],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'Usuarios',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
  }
}
