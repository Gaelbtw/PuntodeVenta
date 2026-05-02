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
  List<Producto> filtrados = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    setState(() {
      productos = data;
      filtrados = data;
    });
  }

  void buscar(String query) {
    if (query.isEmpty) {
      setState(() => filtrados = productos);
      return;
    }

    final resultado = productos.where((p) {
      return p.nombre.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => filtrados = resultado);
  }

  void mostrarFormulario({Producto? producto}) {
  final categoriaCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  String estado = "Activo";

  if (producto != null) {
    nombreCtrl.text = producto.nombre;
    descCtrl.text = producto.descripcion;
    precioCtrl.text = producto.precio.toString();
    categoriaCtrl.text = producto.categoria;
    estado = producto.estado;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(producto == null ? "Nuevo Producto" : "Editar Producto"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descripción")),
            TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio")),
            TextField(controller: categoriaCtrl, decoration: const InputDecoration(labelText: "Categoría")),
            TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock inicial")),

            DropdownButton<String>(
              value: estado,
              items: ["Activo", "Inactivo"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                estado = v!;
              },
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () async {
            try {
              double precio = double.parse(precioCtrl.text);
              int stock = int.parse(stockCtrl.text);

              final nuevo = Producto(
                idProducto: producto?.idProducto,
                nombre: nombreCtrl.text,
                descripcion: descCtrl.text,
                precio: precio,
                categoria: categoriaCtrl.text,
                estado: estado,
              );

              if (producto == null) {
                await controller.insertar(nuevo, stock);
              } else {
                await controller.actualizar(nuevo);
              }

              Navigator.pop(context);
              cargar();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Producto guardado")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
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

          // 🔍 BUSCADOR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Buscar producto...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: buscar,
            ),
          ),

          // ➕ BOTÓN
          ElevatedButton(
            onPressed: () => mostrarFormulario(),
            child: const Text("Agregar Producto"),
          ),

          // 📦 GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filtrados.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (_, i) {
                final p = filtrados[i];

                return Card(
                  child: Column(
                    children: [
                      Text(p.nombre),
                      Text("\$${p.precio}"),
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