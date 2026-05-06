import 'package:flutter/material.dart';
import '../controllers/categoria_controller.dart';
import '../models/categoria_model.dart';

class CategoriasView extends StatefulWidget {
  const CategoriasView({super.key});

  @override
  State<CategoriasView> createState() => _CategoriasViewState();
}

class _CategoriasViewState extends State<CategoriasView> {
  final controller = CategoriaController();
  List<Categoria> categorias = [];

  final nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    setState(() => categorias = data);
  }

  void agregar() async {
    if (nombreCtrl.text.isEmpty) return;

    await controller.insertar(
      Categoria(nombre: nombreCtrl.text),
      //idCategoria(nomnre: nombreCtrl.text)
    );

    nombreCtrl.clear();
    cargar();
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categorías")),
      body: Column(
        children: [

          // 🔥 CREAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      hintText: "Nueva categoría",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: agregar,
                  child: const Text("Agregar"),
                )
              ],
            ),
          ),

          // 🔥 LISTA
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (_, i) {
                final c = categorias[i];
                return ListTile(
                  title: Text(c.nombre),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => eliminar(c.idCategoria!),
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