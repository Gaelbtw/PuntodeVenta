import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../models/producto.dart';
 
class ProductosView extends StatefulWidget  {
  @override
  _ProductosViewState createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final controller = ProductoService();
  final nombreCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
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

  void guardar() async {
    final producto = Producto(
      idProducto: null,
      nombre: nombreCtrl.text,
      descripcion: descCtrl.text,
      precio: double.parse(precioCtrl.text),
    );

    await controller.insertar(producto);

    nombreCtrl.clear();
    descCtrl.clear();
    precioCtrl.clear();

    cargar();
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Productos")),
      body: Column(
        children: [
          TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
          TextField(controller: descCtrl, decoration: InputDecoration(labelText: "Descripción")),
          TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Precio")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Text("\$${p.precio}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => eliminar(p.idProducto!),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}