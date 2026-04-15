import 'package:flutter/material.dart';
import '../controllers/usuarios_controller.dart';
import '../models/usuarios_model.dart';

class UsuariosView extends StatefulWidget {

  const UsuariosView ({super.key});

  @override
  _UsuariosViewState createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final controller = UsuariosController();

  final nombreCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  List<Usuarios> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();

    setState(() {
      usuarios = data;
    });
  }

  void guardar() async {

    final usuario = Usuarios(
        idUsuario: null, 
        nombre: nombreCtrl.text, 
        contra: passCtrl.text, 
        rol: "Cajero"
        );

    await controller.insertar(usuario);

    nombreCtrl.clear();
    passCtrl.clear();

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
              itemCount: usuarios.length,
              itemBuilder: (context, i) {
                final u = usuarios[i];
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