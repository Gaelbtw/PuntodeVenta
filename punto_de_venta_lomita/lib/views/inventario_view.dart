import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
import '../controllers/inventario_controller.dart';
import '../models/inventario_model.dart';

class InventarioView extends StatefulWidget {

  const InventarioView ({super.key});

  @override
  _InventarioViewState createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final controller = InventarioController();

  final productoCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  List<Inventario> lista = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    lista = await controller.obtenerTodos();
    setState(() {});
  }

  void guardar() async {
    await controller.insertar(
      Inventario(
        idInventario: lista.length + 1, 
        idProducto: int.parse(productoCtrl.text), 
        cantidad: int.parse(cantidadCtrl.text)),
    );
    cargar();
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventario")),
      body: Column(
        children: [
          TextField(controller: productoCtrl, decoration: InputDecoration(labelText: "ID Producto")),
          TextField(controller: cantidadCtrl, decoration: InputDecoration(labelText: "Cantidad")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final inv = lista[i];
                return ListTile(
                  title: Text("Producto: ${inv.idProducto}"),
                  subtitle: Text("Cantidad: ${inv.cantidad}"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}