//import 'dart:ffi';

import 'package:flutter/material.dart';
import '../controllers/proveedor_controller.dart';
import '../models/proveedores_model.dart';

class ProveedorView extends StatefulWidget {
  
  const ProveedorView({super.key});
  
  @override
  _ProveedorViewState createState() => _ProveedorViewState();
}

class _ProveedorViewState extends State<ProveedorView> {
  final controller = ProveedorController();

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  List<Proveedores> lista = [];

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
      Proveedores(
        idProveedor: null, 
        nombre: nombreCtrl.text, 
        direccion: direccionCtrl.text,
        telefono: int.parse(telefonoCtrl.text)
        )
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
      appBar: AppBar(title: Text("Proveedores")),
      body: Column(
        children: [
          TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
          TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: "Teléfono")),
          TextField(controller: direccionCtrl, decoration: InputDecoration(labelText: "Direccion")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final p = lista[i];
                return ListTile(
                  title: Text(p.nombre),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => eliminar(p.idProveedor!),
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