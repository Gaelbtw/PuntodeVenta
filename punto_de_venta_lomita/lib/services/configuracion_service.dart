import '../models/configuracion_model.dart';
import '../core/database/database_helper.dart';

class ConfiguracionService {

  Future<Configuracion> obtener() async {

    final db = await DatabaseHelper().database;
    final result = await db.query("SELECT * FROM configuracion WHERE id = 1");

    final row = result.first;

    return Configuracion(
      horaInicioMatutino: row['hora_inicio_matutino'] as String,
      horaFinMatutino: row['hora_fin_matutino'] as String,
      horaInicioVespertino: row['hora_inicio_vespertino'] as String,
      horaFinVespertino: row['hora_fin_vespertino'] as String,
      stockMinimo: row['stock_minimo'] as int,
      fondoCaja: (row['fondo_caja'] as num).toDouble(),
    );
  }

  Future<void> guardar(Configuracion config) async {
    final db = await DatabaseHelper().database;
    await db.execute("""
      UPDATE configuracion SET
        hora_inicio_matutino = ?,
        hora_fin_matutino = ?,
        hora_inicio_vespertino = ?,
        hora_fin_vespertino = ?,
        stock_minimo = ?,
        fondo_caja = ?  
      WHERE id = 1
    """, [
      config.horaInicioMatutino,
      config.horaFinMatutino,
      config.horaInicioVespertino,
      config.horaFinVespertino,
      config.stockMinimo,
      config.fondoCaja,
    ]);
  }
}