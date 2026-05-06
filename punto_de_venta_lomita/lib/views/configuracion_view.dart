import 'package:flutter/material.dart';
import '../models/configuracion_model.dart';
import '../services/configuracion_service.dart';
import '../widgets/nav_bar.dart'; // tu CustomHeader

class ConfiguracionView extends StatefulWidget {
  const ConfiguracionView({super.key});

  @override
  State<ConfiguracionView> createState() => _ConfiguracionViewState();
}

class _ConfiguracionViewState extends State<ConfiguracionView> {

  final service = ConfiguracionService();

  TimeOfDay matutinoInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay matutinoFin = const TimeOfDay(hour: 14, minute: 0);

  TimeOfDay vespertinoInicio = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay vespertinoFin = const TimeOfDay(hour: 22, minute: 0);

  final stockCtrl = TextEditingController();
  final fondoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarConfig();
  }

  // 🔄 Cargar datos desde BD
  void cargarConfig() async {
    final config = await service.obtener();

    setState(() {
      stockCtrl.text = config.stockMinimo.toString();
      fondoCtrl.text = config.fondoCaja.toString();

      matutinoInicio = _parseHora(config.horaInicioMatutino);
      matutinoFin = _parseHora(config.horaFinMatutino);
      vespertinoInicio = _parseHora(config.horaInicioVespertino);
      vespertinoFin = _parseHora(config.horaFinVespertino);
    });
  }

  // ⏰ Seleccionar hora
  Future<void> seleccionarHora(bool inicio, bool matutino) async {
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

  // 🔤 Formato HH:mm
  String format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  // 🔁 String → TimeOfDay
  TimeOfDay _parseHora(String hora) {
    final parts = hora.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // 💾 Guardar
  void guardar() async {
    if (int.tryParse(stockCtrl.text) == null ||
        double.tryParse(fondoCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos inválidos")),
      );
      return;
    }

    final config = Configuracion(
      horaInicioMatutino: format(matutinoInicio),
      horaFinMatutino: format(matutinoFin),
      horaInicioVespertino: format(vespertinoInicio),
      horaFinVespertino: format(vespertinoFin),
      stockMinimo: int.parse(stockCtrl.text),
      fondoCaja: double.parse(fondoCtrl.text),
    );

    await service.guardar(config);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuración guardada")),
    );
  }

  // 🎨 Card reutilizable
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
      appBar: const CustomHeader(titulo: "Configuración"),
      body: Padding(
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
                      onPressed: () => seleccionarHora(true, true),
                      child: Text("Inicio: ${format(matutinoInicio)}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => seleccionarHora(false, true),
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
                      onPressed: () => seleccionarHora(true, false),
                      child: Text("Inicio: ${format(vespertinoInicio)}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => seleccionarHora(false, false),
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

            // 💰 FONDO DE CAJA
            card(
              "Caja",
              TextField(
                controller: fondoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Fondo inicial de caja",
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Guardar Configuración",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}