import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../controllers/producto_controller.dart';
import '../controllers/categoria_controller.dart';
import '../models/producto_model.dart';
import '../models/categoria_model.dart';
import '../widgets/nav_bar.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final productoController = ProductoService();
  final categoriaController = CategoriaController();

  List<Map<String, dynamic>> productos = [];
  List<Categoria> categorias = [];

  int? categoriaSeleccionada;
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  void cargarTodo() async {
    final prod = await productoController.obtenerConStock();
    final cat = await categoriaController.obtenerTodos();

    setState(() {
      productos = prod;
      categorias = cat;
    });
  }

  // 🔍 FILTRO
  List<Map<String, dynamic>> get filtrados {
    return productos.where((p) {
      final matchBusqueda =
          p['nombre'].toLowerCase().contains(busqueda.toLowerCase());

      final matchCategoria = categoriaSeleccionada == null ||
          p['id_categoria'] == categoriaSeleccionada;

      return matchBusqueda && matchCategoria;
    }).toList();
  }

  // 🗑 ELIMINAR
  void confirmarEliminar(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text("¿Eliminar ${p['nombre']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await productoController
                  .eliminar(p['id_producto']);

              Navigator.pop(context);
              cargarTodo();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Producto eliminado")),
              );
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  //  EDITAR
  void mostrarEditarProducto(Map<String, dynamic> p) {
    final nombreCtrl = TextEditingController(text: p['nombre']);
    final precioCtrl =
        TextEditingController(text: p['precio'].toString());
    final stockCtrl =
        TextEditingController(text: p['cantidad'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Producto"),
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
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Precio"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Stock"),
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
              // actualizar producto
              await productoController.actualizar(
                Producto(
                  idProducto: p['id_producto'],
                  nombre: nombreCtrl.text,
                  descripcion: "",
                  precio: double.parse(precioCtrl.text),
                  categoria: p['categoria'] ?? "",
                  estado: p['estado'] ?? "Activo",
                  stockMinimo: p['stock_minimo'] ?? 5,
                ),
            );

              int cantidadNueva = int.parse(stockCtrl.text);

              await productoController.agregarStock(
                p['id_producto'],
                cantidadNueva,
              );

              Navigator.pop(context);
              cargarTodo();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Producto actualizado")),
              );
            },
            child: const Text("Guardar"),
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
        titulo: "Inventario",
        mostrarVolver: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔍 BUSCADOR + CATEGORÍAS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => busqueda = v),
                    decoration: InputDecoration(
                      hintText: "Buscar producto...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text("Todos"),
                          selected: categoriaSeleccionada == null,
                          onSelected: (_) {
                            setState(() => categoriaSeleccionada = null);
                          },
                        ),
                        ...categorias.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(cat.nombre),
                              selected:
                                  categoriaSeleccionada == cat.idCategoria,
                              onSelected: (_) {
                                setState(() {
                                  categoriaSeleccionada =
                                      cat.idCategoria;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🧾 TABLA
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  children: [
                    _headerTabla(),
                    ...filtrados.map((p) => _filaProducto(p)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📊 RESUMEN
            _resumen()
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
          Expanded(child: Text("Producto")),
          Expanded(child: Text("Categoría")),
          Expanded(child: Text("Precio")),
          Expanded(child: Text("Stock")),
          Expanded(child: Text("Estado")),
          Expanded(child: Text("Acciones")),
        ],
      ),
    );
  }

  Widget _filaProducto(Map<String, dynamic> p) {
    final stock = p['cantidad'];
    

    String estado = "OK";
    Color color = Colors.green;

    int minimo = p['stock_minimo'] ?? 5;
    if (stock <= minimo && stock > 0) {
      estado = "Stock Bajo";
      color = Colors.orange; 
    } 
    {
      estado = "Stock Bajo";
      color = Colors.orange;
    }

    if (stock == 0) {
      estado = "Agotado";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: Text(p['nombre'])),
          Expanded(child: Text("${p['id_categoria'] ?? 'Sin categoría'}")),
          Expanded(child: Text("\$${p['precio']}")),
          Expanded(child: Text("$stock")),
          Expanded(child: Text(estado, style: TextStyle(color: color)),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Cant",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) async {
                      final cantidad = int.tryParse(value) ?? 0;

                      if (cantidad <= 0) return;

                      await productoController.agregarStock(
                        p['id_producto'],
                        cantidad,
                      );

                      cargarTodo();
                    },
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () async {
                    try {
                      await productoController.restarStock(
                        p['id_producto'],
                        1,
                      );
                      cargarTodo();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Stock insuficiente")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen() {
    int agotados = 0, bajos = 0, ok = 0;

    for (var p in productos) {
      int stock = p['cantidad'];

      if (stock == 0) {
        agotados++;
      } else if (stock <= 5) {
        bajos++;
      } else {
        ok++;
      }
    }

    return Row(
      children: [
        _card("Agotados", agotados, Colors.red),
        _card("Stock Bajo", bajos, Colors.orange),
        _card("Stock OK", ok, Colors.green),
      ],
    );
  }

  Widget _card(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text("$value",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(title),
          ],
        ),
      ),
    );
  }
}