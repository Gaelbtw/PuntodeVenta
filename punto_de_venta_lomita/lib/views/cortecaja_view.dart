import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';

class CorteCajaView extends StatefulWidget {
  const CorteCajaView({super.key});

  @override
  State<CorteCajaView> createState() => _CorteCajaViewState();
}

class _CorteCajaViewState extends State<CorteCajaView> {
  double total = 0;
  double efectivo = 0;
  double tarjeta = 0;
  int ventas = 0;

  @override
  void initState() {
    super.initState();
    calcular();
  }

 void calcular() async {
  final db = await DatabaseHelper().database;

  final totalRes =
      await db.rawQuery("SELECT SUM(total) as total FROM Ventas");

  final efectivoRes = await db.rawQuery(
      "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'efectivo'");

  final tarjetaRes = await db.rawQuery(
      "SELECT SUM(total) as total FROM Ventas WHERE metodo_pago = 'tarjeta'");

  final ventasRes =
      await db.rawQuery("SELECT COUNT(*) as count FROM Ventas");

  setState(() {
    total = (totalRes.first["total"] as num?)?.toDouble() ?? 0;
    efectivo = (efectivoRes.first["total"] as num?)?.toDouble() ?? 0;
    tarjeta = (tarjetaRes.first["total"] as num?)?.toDouble() ?? 0;
    ventas = (ventasRes.first["count"] as int?) ?? 0;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        title: const Text("Corte de Caja"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: calcular,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //  TOTAL GRANDE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "TOTAL DEL DÍA",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //  TARJETAS
            Row(
              children: [
                _card("Efectivo", efectivo, Colors.blue),
                _card("Tarjeta", tarjeta, Colors.purple),
                _cardCount("Ventas", ventas, Colors.orange),
              ],
            ),

            const SizedBox(height: 20),

            //  BOTÓN
            ElevatedButton.icon(
              onPressed: calcular,
              icon: const Icon(Icons.refresh),
              label: const Text("Actualizar Corte"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💳 CARD DINERO
  Widget _card(String title, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 5),
            Text(
              "\$${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  // 🔢 CARD CONTADOR
  Widget _cardCount(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 5),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}