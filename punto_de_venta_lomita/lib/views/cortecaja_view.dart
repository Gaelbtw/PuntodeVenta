import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../core/session/session_manager.dart';
import '../widgets/nav_bar.dart';
import '../services/ticket_corte_caja_service.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
class CorteCajaView extends StatefulWidget {
  const CorteCajaView({super.key});

  @override
  State<CorteCajaView> createState() => _CorteCajaViewState();
}

class _CorteCajaViewState extends State<CorteCajaView> {

  // 📊 Datos del sistema
  double total = 0;
  double efectivo = 0;
  double tarjeta = 0;
  double salidasDB = 0;

  // 🧾 Inputs
  final contadoCtrl = TextEditingController();

  // ⚙️ Configuración
  final double fondoInicial = 500; // 💰 FIJO

  // 🕐 Datos automáticos
  late DateTime ahora;
  late String turno;
  late String fecha;
  late String horaApertura;
  late String horaCierre;

  // 👤 Simulación usuario (cámbialo por tu login real)
  String cajero = SessionManager.currentUserName;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  void inicializar() {
    ahora = DateTime.now();

    fecha = "${ahora.year}-${_2(ahora.month)}-${_2(ahora.day)}";

    turno = _getTurno(ahora.hour);

    horaApertura = _getHoraApertura(turno);
    horaCierre = _formatHora(ahora);

    calcular();
  }

  String _2(int n) => n.toString().padLeft(2, '0');

  String _formatHora(DateTime dt) {
    int h = dt.hour;
    int m = dt.minute;
    String periodo = h >= 12 ? "pm" : "am";
    h = h % 12 == 0 ? 12 : h % 12;
    return "${_2(h)}:${_2(m)} $periodo";
  }

  String _getTurno(int hour) {
    if (hour >= 7 && hour < 14) return "Matutino";
    if (hour >= 14 && hour < 21) return "Vespertino";
    return "Fuera de turno";
  }

  String _getHoraApertura(String turno) {
    if (turno == "Matutino") return "07:00 am";
    if (turno == "Vespertino") return "02:00 pm";
    return "--";
  }

  // 📊 CONSULTAS
  void calcular() async {
    final db = await DatabaseHelper().database;

    final totalRes =
        await db.rawQuery("SELECT SUM(total) as total FROM Ventas");

    final efectivoRes = await db.rawQuery(
        "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'efectivo'");

    final tarjetaRes = await db.rawQuery(
        "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'tarjeta'");

    // 💸 SALIDAS DESDE COMPRAS / GASTOS
    final salidasRes =
        await db.rawQuery("SELECT SUM(total) as total FROM Compras");

    setState(() {
      total = (totalRes.first["total"] as num?)?.toDouble() ?? 0;
      efectivo = (efectivoRes.first["total"] as num?)?.toDouble() ?? 0;
      tarjeta = (tarjetaRes.first["total"] as num?)?.toDouble() ?? 0;
      salidasDB = (salidasRes.first["total"] as num?)?.toDouble() ?? 0;
    });
  }

  // 🧠 Cálculos
  double get contado => double.tryParse(contadoCtrl.text) ?? 0;

  double get esperadoEnCaja => efectivo + fondoInicial - salidasDB;
  double get diferencia => contado - esperadoEnCaja;

  // 🧾 CORTE
  void generarCorte() async {
  horaCierre = _formatHora(DateTime.now());

  // 🧾 generar PDF
  final pdf = await TicketService.generarCorte(
    fecha: fecha,
    turno: turno,
    cajero: SessionManager.currentUserName,
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
      appBar: CustomHeader(
        titulo: "Corte de Caja",
        mostrarVolver: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

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