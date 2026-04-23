import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../models/producto_model.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
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
    setState(() => productos = data);
  }

  // 🔥 FORMULARIO
  void mostrarFormulario({Producto? producto}) {
    if (producto != null) {
      nombreCtrl.text = producto.nombre;
      descCtrl.text = producto.descripcion;
      precioCtrl.text = producto.precio.toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(producto == null ? "Nuevo Producto" : "Editar Producto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Precio"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty || precioCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completa los campos")),
                );
                return;
              }

              final nuevo = Producto(
                idProducto: producto?.idProducto,
                nombre: nombreCtrl.text,
                descripcion: descCtrl.text,
                precio: double.tryParse(precioCtrl.text) ?? 0,
              );

              if (producto == null) {
                await controller.insertar(nuevo);
              } else {
                await controller.actualizar(nuevo);
              }

              Navigator.pop(context);

              nombreCtrl.clear();
              descCtrl.clear();
              precioCtrl.clear();

              cargar();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productos")),

      body: Column(
        children: [

          // 🔹 BOTÓN
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => mostrarFormulario(),
                child: const Text("Agregar Producto"),
              ),
            ),
          ),

          // 🔹 LISTA REAL
          Expanded(
  child: GridView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: productos.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
    ),
    itemBuilder: (_, i) {
      final p = productos[i];

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text("\$${p.precio}",
                style: const TextStyle(fontSize: 16)),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => mostrarFormulario(producto: p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => eliminar(p.idProducto!),
                ),
              ],
            )
          ],
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