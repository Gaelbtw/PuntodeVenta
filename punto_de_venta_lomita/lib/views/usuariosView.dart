import 'package:flutter/material.dart';
import '../controllers/usuarios_controller.dart';
import '../models/usuarios.dart';

class UsuariosView extends StatefulWidget {
  @override
  _UsuariosViewState createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final controller = UsuariosController();

  final nombreCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  List<Usuario> lista = [];

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
      Usuario(idUsuario: null, nombre: nombreCtrl.text, contraseña: passCtrl.text, rol: "Cajero"),
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
      appBar: AppBar(title: Text("Usuarios")),
      body: Column(
        children: [
          TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
          TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Contraseña")),

          ElevatedButton(onPressed: guardar, child: Text("Guardar")),

          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final u = lista[i];
                return ListTile(
                  title: Text(u.nombre),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => eliminar(u.idUsuario!),
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