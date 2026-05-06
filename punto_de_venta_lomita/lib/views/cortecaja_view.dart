import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../core/session/session_manager.dart';
import '../widgets/nav_bar.dart';
import '../services/ticket_corte_caja_service.dart';
import '../services/configuracion_service.dart';
import '../models/configuracion_model.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class CorteCajaView extends StatefulWidget {
  const CorteCajaView({super.key});

  @override
  State<CorteCajaView> createState() => _CorteCajaViewState();
}

class _CorteCajaViewState extends State<CorteCajaView> {

  // 📊 Datos
  double total = 0;
  double efectivo = 0;
  double tarjeta = 0;
  double salidasDB = 0;

  // 🧾 Input
  final contadoCtrl = TextEditingController();

  // ⚙️ Config
  late Configuracion config;
  bool cargando = true;

  // 🕐 Datos
  late DateTime ahora;
  late String turno;
  late String fecha;
  late String horaApertura;
  late String horaCierre;

  String cajero = SessionManager.currentUserName;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  // 🔥 INICIALIZAR
  Future<void> inicializar() async {
    ahora = DateTime.now();

    config = await ConfiguracionService().obtener();

    fecha = "${ahora.year}-${_2(ahora.month)}-${_2(ahora.day)}";

    turno = _getTurno(ahora);
    horaApertura = _getHoraApertura(turno);
    horaCierre = _formatHora(ahora);

    await calcular();

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  // 🔧 HELPERS
  String _2(int n) => n.toString().padLeft(2, '0');

  String _formatHora(DateTime dt) {
    int h = dt.hour;
    int m = dt.minute;
    String periodo = h >= 12 ? "pm" : "am";
    h = h % 12 == 0 ? 12 : h % 12;
    return "${_2(h)}:${_2(m)} $periodo";
  }

  TimeOfDay _parseHora(String hora) {
  try {
    final limpio = hora.trim().replaceAll("am", "").replaceAll("pm", "");
    final parts = limpio.split(":");

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  } catch (e) {
    print("ERROR parseando hora: $hora");
    return const TimeOfDay(hour: 0, minute: 0);
  }
}
/*
  bool _estaEntre(TimeOfDay ahora, TimeOfDay inicio, TimeOfDay fin) {
    final a = ahora.hour * 60 + ahora.minute;
    final i = inicio.hour * 60 + inicio.minute;
    final f = fin.hour * 60 + fin.minute;

    return a >= i && a < f;
  }
*/

  // 🔥 TURNOS DINÁMICOS
String _getTurno(DateTime ahora) {
  final actual = TimeOfDay.fromDateTime(ahora);

  final matInicio = _parseHora(config.horaInicioMatutino);
  final matFin = _parseHora(config.horaFinMatutino);

  final vesInicio = _parseHora(config.horaInicioVespertino);
  final vesFin = _parseHora(config.horaFinVespertino);

  final actualMin = actual.hour * 60 + actual.minute;
  final matIniMin = matInicio.hour * 60 + matInicio.minute;
  final matFinMin = matFin.hour * 60 + matFin.minute;
  final vesIniMin = vesInicio.hour * 60 + vesInicio.minute;
  final vesFinMin = vesFin.hour * 60 + vesFin.minute;

  // ✅ Dentro de rango normal
  if (actualMin >= matIniMin && actualMin <= matFinMin) {
    return "Matutino";
  }

  if (actualMin >= vesIniMin && actualMin <= vesFinMin) {
    return "Vespertino";
  }

  // 🔥 SI NO CAE EN NINGUNO → ASIGNAR EL MÁS CERCANO

  final distMat = (actualMin - matIniMin).abs();
  final distVes = (actualMin - vesIniMin).abs();

  return distMat < distVes ? "Matutino" : "Vespertino";
}

  String _formatearHora(String hora) {
    final parts = hora.split(":");
    int h = int.parse(parts[0]);
    final m = parts[1];

    final periodo = h >= 12 ? "pm" : "am";
    h = h % 12 == 0 ? 12 : h % 12;

    return "${h.toString().padLeft(2, '0')}:$m $periodo";
  }

  String _getHoraApertura(String turno) {
    if (turno == "Matutino") {
      return _formatearHora(config.horaInicioMatutino);
    }
    if (turno == "Vespertino") {
      return _formatearHora(config.horaInicioVespertino);
    }
    return "--";
  }

  // 📊 BD
  Future<void> calcular() async {
    final db = await DatabaseHelper().database;

    final totalRes =
        await db.rawQuery("SELECT SUM(total) as total FROM Ventas");

    final efectivoRes = await db.rawQuery(
        "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'efectivo'");

    final tarjetaRes = await db.rawQuery(
        "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'tarjeta'");

    final salidasRes =
        await db.rawQuery("SELECT SUM(total) as total FROM Compras");

    total = (totalRes.first["total"] as num?)?.toDouble() ?? 0;
    efectivo = (efectivoRes.first["total"] as num?)?.toDouble() ?? 0;
    tarjeta = (tarjetaRes.first["total"] as num?)?.toDouble() ?? 0;
    salidasDB = (salidasRes.first["total"] as num?)?.toDouble() ?? 0;
  }

  // 🧠 Cálculos
  double get contado => double.tryParse(contadoCtrl.text) ?? 0;
  double get fondoInicial => config.fondoCaja;
  double get esperadoEnCaja => efectivo + fondoInicial - salidasDB;
  double get diferencia => contado - esperadoEnCaja;

  // 🧾 GENERAR CORTE
  void generarCorte() async {

    if (contadoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa el efectivo contado")),
      );
      return;
    }

    if (turno == "Fuera de turno") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fuera de horario permitido")),
      );
      return;
    }

    horaCierre = _formatHora(DateTime.now());

    final pdf = await TicketService.generarCorte(
      fecha: fecha,
      turno: turno,
      cajero: cajero,
      horaApertura: horaApertura,
      horaCierre: horaCierre,
      total: total,
      efectivo: efectivo,
      tarjeta: tarjeta,
      fondo: fondoInicial,
      salidas: salidasDB,
      contado: contado,
      esperado: esperadoEnCaja,
      diferencia: diferencia,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: const CustomHeader(
        titulo: "Corte de Caja",
        mostrarVolver: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  if (turno == "Fuera de turno")
                    const Text(
                      "⚠️ Fuera de horario",
                      style: TextStyle(color: Colors.red),
                    ),

                  _box("Fecha", fecha),
                  _box("Turno", turno),
                  _box("Cajero", cajero),
                  _box("Hora apertura", horaApertura),
                  _box("Hora cierre", horaCierre),

                  const SizedBox(height: 10),

                  _box("Fondo inicial", fondoInicial.toStringAsFixed(2)),
                  _box("Salidas", salidasDB.toStringAsFixed(2)),

                  _box("Total efectivo", efectivo.toStringAsFixed(2)),
                  _box("Tarjeta", tarjeta.toStringAsFixed(2)),
                  _box("Total ventas", total.toStringAsFixed(2)),

                  const SizedBox(height: 10),

                  _input("Efectivo contado", contadoCtrl),

                  const SizedBox(height: 10),

                  _box("Diferencia", diferencia.toStringAsFixed(2)),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: generarCorte,
                    child: const Text("Ejecutar corte"),
                  )
                ],
              ),
            ),
    );
  }

  Widget _box(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$label: $value"),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}