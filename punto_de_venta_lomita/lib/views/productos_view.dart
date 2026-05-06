import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../controllers/categoria_controller.dart';
import '../models/producto_model.dart';
import '../models/categoria_model.dart';
import '../widgets/nav_bar.dart';
import 'categoria_view.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final controller = ProductoService();
  final categoriaController = CategoriaController();

  final nombreCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  List<Producto> productos = [];
  List<Producto> filtrados = [];
  List<Categoria> categorias = [];

  int? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    final cat = await categoriaController.obtenerTodos();

    setState(() {
      productos = data;
      filtrados = data;
      categorias = cat;
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
    final stockCtrl = TextEditingController();
    String estado = "Activo";

    if (producto != null) {
      nombreCtrl.text = producto.nombre;
      descCtrl.text = producto.descripcion;
      precioCtrl.text = producto.precio.toString();
      estado = producto.estado;
      categoriaSeleccionada = producto.categoriaId;
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

              // 🔥 DROPDOWN CATEGORÍAS
              DropdownButtonFormField<int>(
                value: categoriaSeleccionada,
                hint: const Text("Seleccionar categoría"),
                items: categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat.idCategoria,
                    child: Text(cat.nombre),
                  );
                }).toList(),
                onChanged: (v) {
                  categoriaSeleccionada = v;
                },
              ),

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
              double precio = double.parse(precioCtrl.text);
              int stock = int.parse(stockCtrl.text);

              final nuevo = Producto(
                idProducto: producto?.idProducto,
                nombre: nombreCtrl.text,
                descripcion: descCtrl.text,
                precio: precio,
                categoriaId: categoriaSeleccionada,
                estado: estado,
                stockMinimo: int.parse(stockCtrl.text),
              );

              if (categoriaSeleccionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selecciona una categoría")),
                );
                return;
              }

              if (producto == null) {
                await controller.insertar(nuevo, stock);
              } else {
                await controller.actualizar(nuevo);
              }

              Navigator.pop(context);
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
      appBar: CustomHeader(titulo: "Productos", mostrarVolver: true),
      body: Column(
        children: [
          TextField(
            onChanged: (v) => buscar(v),
            decoration: const InputDecoration(
              hintText: "Buscar producto...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          ElevatedButton(
            onPressed: () => mostrarFormulario(),
            child: const Text("Agregar Producto"),
          ),
          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriasView()),
              ).then((_) => cargar()); 
            },
            child: const Text("Categorías"),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: filtrados.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (_, i) {
                final p = filtrados[i];
                return Card(
                  child: Column(
                    children: [
                      Text(p.nombre),
                      Text("\$${p.precio}"),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => mostrarFormulario(producto: p)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => eliminar(p.idProducto!)),
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