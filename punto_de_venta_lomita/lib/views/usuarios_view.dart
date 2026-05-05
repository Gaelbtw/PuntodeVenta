import 'package:flutter/material.dart';
import '../controllers/usuarios_controller.dart';
import '../models/usuarios_model.dart';
import '../widgets/nav_bar.dart';

class UsuariosView extends StatefulWidget {
  const UsuariosView({super.key});

  @override
  State<UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final usuariosController = UsuariosController();

  List<Usuarios> usuarios = [];
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  void cargarTodo() async {
    final usr = await usuariosController.obtenerTodos();
    setState(() {
      usuarios = usr;
    });
  }

  //  FILTRO
  List<Usuarios> get filtrados {
    return usuarios.where((u) {
      return u.nombre
          .toLowerCase()
          .contains(busqueda.toLowerCase());
    }).toList();
  }

  //  AGREGAR
  void mostrarAgregarUsuario() {
    final nombreCtrl = TextEditingController();
    final contraCtrl = TextEditingController();
    String rolSeleccionado = "Cajero";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar Usuario"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration:
                    const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contraCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: rolSeleccionado,
                items: ["Admin", "Cajero"]
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (value) {
                  rolSeleccionado = value!;
                },
                decoration:
                    const InputDecoration(labelText: "Rol"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty ||
                  contraCtrl.text.isEmpty) {
                return;
              }

              await usuariosController.insertar(
                Usuarios(
                  idUsuario: null,
                  nombre: nombreCtrl.text,
                  contra: contraCtrl.text,
                  rol: rolSeleccionado,
                ),
              );

              Navigator.pop(context);
              cargarTodo();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Usuario agregado")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  //  EDITAR
  void mostrarEditarUsuario(Usuarios u) {
    final nombreCtrl = TextEditingController(text: u.nombre);
    final contraCtrl = TextEditingController(text: u.contra);
    String rolSeleccionado = u.rol;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuario"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration:
                    const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contraCtrl,
                decoration:
                    const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: rolSeleccionado,
                items: ["Admin", "Cajero"]
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (value) {
                  rolSeleccionado = value!;
                },
                decoration:
                    const InputDecoration(labelText: "Rol"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await usuariosController.actualizar(
                Usuarios(
                  idUsuario: u.idUsuario,
                  nombre: nombreCtrl.text,
                  contra: contraCtrl.text,
                  rol: rolSeleccionado,
                ),
              );

              Navigator.pop(context);
              cargarTodo();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Usuario actualizado")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // 🗑 ELIMINAR
  void confirmarEliminar(Usuarios u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar usuario"),
        content: Text("¿Eliminar ${u.nombre}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await usuariosController.eliminar(u.idUsuario!);

              Navigator.pop(context);
              cargarTodo();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Usuario eliminado")),
              );
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: CustomHeader(
        titulo: "Usuarios",
        mostrarVolver: true,
      ),

      

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔍 BUSCADOR
            TextField(
              onChanged: (v) => setState(() => busqueda = v),
              decoration: InputDecoration(
                hintText: "Buscar usuario...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  TABLA
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  children: [
                    _headerTabla(),
                    ...filtrados.map((u) => _filaUsuario(u)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerTabla() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[200],
      child: const Row(
        children: [
          Expanded(child: Text("Nombre")),
          Expanded(child: Text("Rol")),
          Expanded(child: Text("Acciones")),
        ],
      ),
    );
  }

  Widget _filaUsuario(Usuarios u) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: Text(u.nombre)),
          Expanded(child: Text(u.rol)),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => mostrarEditarUsuario(u),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmarEliminar(u),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}