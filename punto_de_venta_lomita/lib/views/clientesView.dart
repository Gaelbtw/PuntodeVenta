import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente.dart';

class ClientesView extends StatefulWidget {
  @override
  _ClientesViewState createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  final controller = ClienteController();

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();

  List<Cliente> lista = [];

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
      Cliente(
        idCliente: null,
        nombre: nombreCtrl.text,
        telefono: telefonoCtrl.text,
        correo: correoCtrl.text,
      ),
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
      appBar: AppBar(title: Text("Clientes")),
      body: Column(
        children: [
          TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
          TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: "Teléfono")),
          TextField(controller: correoCtrl, decoration: InputDecoration(labelText: "Correo")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final c = lista[i];
                return ListTile(
                  title: Text(c.nombre),
                  subtitle: Text(c.telefono ?? ""),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => eliminar(c.idCliente!),
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