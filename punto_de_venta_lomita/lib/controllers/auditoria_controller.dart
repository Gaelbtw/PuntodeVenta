import '../core/database/database_helper.dart';
import '../core/session/session_manager.dart';
import '../models/auditoria_model.dart';

class AuditoriaController {
  final dbHelper = DatabaseHelper();

  Future<int> registrar({
    required String tabla,
    required String accion,
    required String descripcion,
    int? idRegistro,
    String? usuario,
  }) async {
    final db = await dbHelper.database;

    return await db.insert('Auditorias', {
      "fecha_hora": DateTime.now().toIso8601String(),
      "usuario": usuario ?? SessionManager.currentUserName,
      "tabla": tabla,
      "accion": accion,
      "id_registro": idRegistro,
      "descripcion": descripcion,
    });
  }

  Future<List<Auditoria>> obtenerTodas() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Auditorias',
      orderBy: 'fecha_hora DESC',
    );

    return result.map((e) => Auditoria.fromMap(e)).toList();
  }
}
