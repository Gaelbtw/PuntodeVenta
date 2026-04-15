import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
import '../controllers/ventas_controller.dart';
import '../controllers/producto_controller.dart';
import '../models/producto_model.dart';
import '../models/ventas_model.dart';

class VentasView extends StatefulWidget {

  const VentasView ({super.key});

  @override
  _VentasViewState createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  final ventasController = VentasController();
  final productoController = ProductoService();

  List<Producto> productos = [];
  Producto? seleccionado;

  final cantidadCtrl = TextEditingController();
  double total = 0;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  void cargarProductos() async {
    final data = await productoController.obtenerTodos();
    setState(() {
      productos = data;
    });
  }

  void calcularTotal() {
    if (seleccionado != null && cantidadCtrl.text.isNotEmpty) {
      final cantidad = int.parse(cantidadCtrl.text);
      setState(() {
        total = seleccionado!.precio * cantidad;
      });
    }
  }

  void vender() async {
    if (seleccionado == null || cantidadCtrl.text.isEmpty) return;

    ventasController.insertar ( Ventas(
      idVenta: null,
      idCliente: null,
      idUsuario: 1, // fijo por ahora
      fecha: DateTime.now().toString(),
      total: total,
    ));

    await ventasController.insertarVentaCompleta(
    seleccionado!.idProducto!,
    int.parse(cantidadCtrl.text),
    total,
  );

    cantidadCtrl.clear();

    setState(() {
      seleccionado = null;
      total = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Venta registrada")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ventas")),
      body: Column(
        children: [
          DropdownButton<Producto>(
            hint: Text("Selecciona producto"),
            value: seleccionado,
            onChanged: (value) {
              setState(() {
                seleccionado = value;
              });
              calcularTotal();
            },
            items: productos.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.nombre),
              );
            }).toList(),
          ),

          TextField(
            controller: cantidadCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Cantidad"),
            onChanged: (_) => calcularTotal(),
          ),

          SizedBox(height: 10),

          Text("Total: \$${total.toStringAsFixed(2)}"),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: vender,
            child: Text("Registrar venta"),
          ),
        ],
      ),
    );
  }
}