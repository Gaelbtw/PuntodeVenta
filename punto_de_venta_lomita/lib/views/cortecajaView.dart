import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';

class CorteCajaView extends StatefulWidget {
  @override
  _CorteCajaViewState createState() => _CorteCajaViewState();
}

class _CorteCajaViewState extends State<CorteCajaView> {
  double total = 0;

  void calcular() async {
    final db = await DatabaseHelper().database;

    final result = await db.rawQuery(
      "SELECT SUM(total) as total FROM Ventas"
    );

    setState(() {
      total = result.first["total"] == null ? 0 : result.first["total"] as double;
    });
  }

  @override
  void initState() {
    super.initState();
    calcular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Corte de Caja")),
      body: Center(
        child: Text(
          "Total vendido: \$${total.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}