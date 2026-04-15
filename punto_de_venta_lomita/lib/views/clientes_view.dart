import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente_model.dart';

class ClientesView extends StatefulWidget {

  const ClientesView ({super.key}); 

  @override
  
  _ClientesViewState createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  final controller = ClienteController();

  final nombreCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();

  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    setState(() {
      clientes = data;
    });
  }

  void guardar() async {
    await controller.insertar(
      Cliente(
        idCliente: null,
        nombre: nombreCtrl.text,
        direccion : direccionCtrl.text,
        telefono: int.tryParse(telefonoCtrl.text),
        correo: correoCtrl.text,
        fechaRegistro: DateTime.now().toString()
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
          TextField(controller: direccionCtrl, decoration:InputDecoration(labelText: "Direccion")),
          TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: "Teléfono")),
          TextField(controller: correoCtrl, decoration: InputDecoration(labelText: "Correo")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (_, i) {
                final c = clientes[i];
                return ListTile(
                  title: Text(c.nombre),
                  subtitle: Text(c.direccion), // ostia
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