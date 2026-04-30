import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../controllers/proveedor_controller.dart';
import '../controllers/compras_controller.dart';
import '../models/producto_model.dart';
import '../models/proveedores_model.dart';
import '../widgets/custom_alert.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/ticket_compras_service.dart';
class ComprasView extends StatefulWidget {
  const ComprasView({super.key});

  @override
  State<ComprasView> createState() => _ComprasViewState();
}

class _ComprasViewState extends State<ComprasView> {

  final productoController = ProductoService();
  final proveedorController = ProveedorController();
  final comprasController = ComprasController();

  List<Producto> productos = [];
  List<Proveedores> proveedores = [];
  List<Map<String, dynamic>> carrito = [];
  Map<int, TextEditingController> controllers = {};

  Proveedores? proveedorSeleccionado;

  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    productos = await productoController.obtenerProductosConPrecioCompra();
    proveedores = await proveedorController.obtenerTodos();
    setState(() {});
  }

  // 🟢 AGREGAR AL CARRITO
  void agregarProducto(Producto p) {
    setState(() {
      final index = carrito.indexWhere(
        (item) => item['id_producto'] == p.idProducto,
      );

      if (index >= 0) {
        carrito[index]['cantidad']++;
      } else {
        carrito.add({
          "id_producto": p.idProducto,
          "nombre": p.nombre,
          "precio_compra": p.precioCompra,
          "cantidad": 1,
        });
      }
    });
  }

  // 🟢 TOTAL
  double get total => carrito.fold(
    0,
    (sum, item) => sum + (item['precio_compra'] * item['cantidad']),
  );

  // 🟢 GUARDAR COMPRA
  void guardarCompra() async {
    if (carrito.isEmpty || proveedorSeleccionado == null) return;

    try {
      await comprasController.insertarCompraCompleta(
        carrito,
        total,
        proveedorSeleccionado!.idProveedor!,
      );

    await imprimirTicket();
      
      setState(() {
        carrito.clear();
      });


      showDialog(
        context: context,
        builder: (_) => CustomAlert(
          titulo: 'COMPRA',
          mensaje: 'Compra realizada con exito',
          icono: Icons.check,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 🟢 FILTRAR
  List<Producto> get productosFiltrados {
    return productos.where((p) {
      return p.nombre.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();
  }

  void cambiarCantidad(int index, int delta) {
    setState(() {
      carrito[index]['cantidad'] += delta;
      if (carrito[index]['cantidad'] <= 0) {
        carrito.removeAt(index);
      }
    });
  }

  Future<void> imprimirTicket() async {
    final pdf = await TicketService.generarTicket(
      carrito: carrito, 
      total: total, 
      proveedor: proveedorSeleccionado!.nombre
    );

    await Printing.layoutPdf (
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text("Compras"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // 📦 PRODUCTOS
            Expanded(
              flex: 7,
              child: Column(
                children: [

                  // 🔎 BUSCADOR
                  TextField(
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

                  const SizedBox(height: 10),

                  // 📦 GRID PRODUCTOS
                  Expanded(
                    child: GridView.builder(
                      itemCount: productosFiltrados.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (_, i) {
                        final p = productosFiltrados[i];

                        return GestureDetector(
                          onTap: () => agregarProducto(p),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text("\$${p.precioCompra}"),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => agregarProducto(p),
                                  child: const Text("Agregar"),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 🧾 CARRITO
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  children: [

                    // 🏢 PROVEEDOR
                    DropdownButton<Proveedores>(
                      hint: const Text("Proveedor"),
                      value: proveedorSeleccionado,
                      isExpanded: true,
                      items: proveedores.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          proveedorSeleccionado = value;
                        });
                      },
                    ),

                    const Divider(),

                    // 📋 CARRITO
                    Expanded(
                      child: ListView.builder(
                        itemCount: carrito.length,
                        itemBuilder: (_, i) {
                          final item = carrito[i];
                          
                          final id = item['id_producto'];

                              if (!controllers.containsKey(id)) {
                                controllers[id] = TextEditingController(
                                  text: item['cantidad'].toString(),
                                );
                              } else {
                                controllers[id]!.text = item['cantidad'].toString();
                              }

                          return ListTile(
                            title: Text(item['nombre']),
                            subtitle: Text("\$${item['precio_compra']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      cambiarCantidad(i, -1),
                                  icon: const Icon(Icons.remove),
                                ),

                              
SizedBox(
          width: 50,
          child: TextField(
            controller: controllers[id],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final nuevaCantidad = int.tryParse(value);

              if (nuevaCantidad != null && nuevaCantidad > 0) {
                setState(() {
      item['cantidad'] = nuevaCantidad;
    });
              }
            },
          ),
        ),
                                IconButton(
                                  onPressed: () =>
                                      cambiarCantidad(i, 1),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    // 💰 TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total"),
                        Text("\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🟢 BOTÓN COMPRA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (carrito.isEmpty) return;

                          showDialog(
                            context: context,
                            builder: (_) => CustomAlert(
                              titulo: "Compra",
                              mensaje: "¿Deseas realizar la compra?",
                              icono: Icons.shield_outlined,
                              textoCancelar: "Cancelar",
                              textoConfirmar: "Confirmar",
                              onConfirm: () {
                                guardarCompra();
                              },
                            ),
                          );
                        },
                        child: const Text("Confirmar Compra"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
void dispose() {
  for (var c in controllers.values) {
    c.dispose();
  }
  super.dispose();
}
}