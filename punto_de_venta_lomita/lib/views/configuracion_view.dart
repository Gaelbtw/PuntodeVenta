import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../widgets/nav_bar.dart';

class ConfiguracionView extends StatefulWidget {
  const ConfiguracionView({super.key});

  @override
  State<ConfiguracionView> createState() => _ConfiguracionViewState();
}

class _ConfiguracionViewState extends State<ConfiguracionView> {

  bool cargando = true;

  TimeOfDay matutinoInicio = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay matutinoFin = const TimeOfDay(hour: 14, minute: 0);

  TimeOfDay vespertinoInicio = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay vespertinoFin = const TimeOfDay(hour: 21, minute: 0);

  final stockCtrl = TextEditingController();
  final fondoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarConfig();
  }

  // 🔥 CARGAR CONFIG DESDE BD
  Future<void> cargarConfig() async {
    final db = await DatabaseHelper().database;

    final res = await db.query("configuracion");

    if (res.isEmpty) {
      // 🔥 crear default
      await db.insert("configuracion", {
        "id": 1,
        "hora_inicio_matutino": "07:00",
        "hora_fin_matutino": "14:00",
        "hora_inicio_vespertino": "14:00",
        "hora_fin_vespertino": "21:00",
        "stock_minimo": 5,
        "fondo_caja": 500,
      });

      await cargarConfig(); // 🔁 recargar
      return;
    }

    final row = res.first;

    setState(() {
      stockCtrl.text = row["stock_minimo"].toString();
      fondoCtrl.text = row["fondo_caja"].toString();

      matutinoInicio = _parseHora(row["hora_inicio_matutino"] as String);
      matutinoFin = _parseHora(row["hora_fin_matutino"] as String);
      vespertinoInicio = _parseHora(row["hora_inicio_vespertino"] as String);
      vespertinoFin = _parseHora(row["hora_fin_vespertino"] as String);

      cargando = false;
    });
  }

  // 🔥 GUARDAR
  Future<void> guardar() async {
    final db = await DatabaseHelper().database;

    await db.insert(
      "configuracion",
      {
        "id": 1,
        "hora_inicio_matutino": format(matutinoInicio),
        "hora_fin_matutino": format(matutinoFin),
        "hora_inicio_vespertino": format(vespertinoInicio),
        "hora_fin_vespertino": format(vespertinoFin),
        "stock_minimo": int.parse(stockCtrl.text),
        "fondo_caja": double.parse(fondoCtrl.text),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuración guardada")),
    );
  }

  // ⏰ UTILIDADES
  String format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  TimeOfDay _parseHora(String hora) {
    final parts = hora.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> pickHora(bool inicio, bool matutino) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    setState(() {
      if (matutino) {
        inicio ? matutinoInicio = picked : matutinoFin = picked;
      } else {
        inicio ? vespertinoInicio = picked : vespertinoFin = picked;
      }
    });
  }

  // 🎨 CARD
  Widget card(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: const CustomHeader(
        titulo: "Configuración",
        mostrarVolver: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [

                    // 🌅 MATUTINO
                    card(
                      "Turno Matutino",
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => pickHora(true, true),
                              child: Text("Inicio: ${format(matutinoInicio)}"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => pickHora(false, true),
                              child: Text("Fin: ${format(matutinoFin)}"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🌇 VESPERTINO
                    card(
                      "Turno Vespertino",
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => pickHora(true, false),
                              child: Text("Inicio: ${format(vespertinoInicio)}"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => pickHora(false, false),
                              child: Text("Fin: ${format(vespertinoFin)}"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📦 STOCK
                    card(
                      "Inventario",
                      TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Stock mínimo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    // 💰 FONDO
                    card(
                      "Caja",
                      TextField(
                        controller: fondoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Fondo inicial",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 💾 BOTÓN
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C500),
                        ),
                        child: const Text(
                          "Guardar Configuración",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}