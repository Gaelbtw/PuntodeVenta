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

  List<Proveedores> proveedores = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data  = await controller.obtenerTodos();

    setState(() {
      proveedores = data;
    });
  }

  void guardar() async {

    final proveedor = Proveedores(
        idProveedor: null, 
        nombre: nombreCtrl.text, 
        direccion: direccionCtrl.text,
        telefono: int.tryParse(telefonoCtrl.text) 
        );

    await controller.insertar(proveedor);
    
    nombreCtrl.clear();
    telefonoCtrl.clear();
    direccionCtrl.clear();

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
              itemCount: proveedores.length,
              itemBuilder: (_, i) {
                final p = proveedores[i];
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
