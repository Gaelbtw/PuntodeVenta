import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../models/producto.dart';

class ProductosView extends StatefulWidget  {
  @override
  _ProductosViewState createState() => _ProductosViewState();
}



class _ProductosViewState extends State<ProductosView> {
  final controller = ProductoService();
  List<Producto> productos = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    setState(() {
      productos = data;
    });
  }

  void agregar() async {
    await controller.insertar(
      Producto(idProducto: null, nombre: "Tortilla", descripcion: "Maiz", precio: 22)
    );
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Productos")),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final p = productos[index];
          return ListTile(
            title: Text(p.nombre),
            subtitle: Text("\$${p.precio}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: agregar,
        child: Icon(Icons.add),
      ),
    );
  }
}