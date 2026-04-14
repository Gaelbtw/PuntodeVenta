import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';

class ReporteView extends StatefulWidget {
  @override
  _ReporteViewState createState() => _ReporteViewState();
}

class _ReporteViewState extends State<ReporteView> {
  List<Map<String, dynamic>> data = [];

  void cargar() async {
    final db = await DatabaseHelper().database;

    final result = await db.rawQuery('''
      SELECT Producto.nombre, SUM(Detalle_Venta.cantidad) as total
      FROM Detalle_Venta
      INNER JOIN Producto ON Producto.id_producto = Detalle_Venta.id_producto
      GROUP BY Producto.nombre
    ''');

    setState(() {
      data = result;
    });
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reporte")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (_, i) {
          final item = data[i];
          return ListTile(
            title: Text(item["nombre"]),
            subtitle: Text("Vendidos: ${item["total"]}"),
          );
        },
      ),
    );
  }
}