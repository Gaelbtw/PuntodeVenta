import '../core/database/database_helper.dart';

class Authcontroller {
  final dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>?> login(String nombre, String password) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'Usuarios',
      where: 'nombre = ? AND contra = ?',
      whereArgs: [nombre, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}