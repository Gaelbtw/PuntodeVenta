import 'package:flutter/material.dart';
import '../controllers/ventas_controller.dart';
import '../controllers/producto_controller.dart';
//import '../controllers/categoria_controller.dart';
import '../models/producto_model.dart';
import '../widgets/custom_alert.dart';
import '../models/cliente_model.dart';
import '../widgets/nav_bar.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/ticket_service.dart';
//import '../models/categoria_model.dart';

class VentasView extends StatefulWidget {
  final Cliente? cliente;
  const VentasView({super.key, this.cliente});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  
  final ventasController = VentasController();
  final productoController = ProductoService();
  //final categoriaController = CategoriaController();

  Cliente? clienteSeleccionado;

  List<Producto> productos = [];
  //List<Categoria> categorias = [];
  List<Map<String, dynamic>> carrito = [];

  int? categoriaSeleccionada;

  String metodoPago = "efectivo";
  final pagoCtrl = TextEditingController();
  double cambio = 0;

  String busqueda = "";

  @override
  void initState() {
    super.initState();
    //cargarCategorias();
    cargarProductos();

    clienteSeleccionado = widget.cliente;
  }

  // 🔹 CARGA DATOS
  void cargarProductos() async {
    final data = await productoController.obtenerTodos();
    setState(() => productos = data);
  }

  /*void cargarCategorias() async {
    final data = await categoriaController.obtenerTodos();
    setState(() => categorias = data);
  }*/

  /*void filtrarProductos(int? idCategoria) async {
    if (idCategoria == null) {
      cargarProductos();
    } else {
      final data =
          await productoController.obtenerPorCategoria(idCategoria);
      setState(() => productos = data);
    }
  }*/

  //  BUSCADOR
  List<Producto> get productosFiltrados {
    return productos.where((p) {
      return p.nombre.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();
  }

  // 🛒 CARRITO
  void agregarProducto(Producto p) {
    setState(() {
      final index =
          carrito.indexWhere((i) => i['id_producto'] == p.idProducto);

      if (index >= 0) {
        carrito[index]['cantidad']++;
      } else {
        carrito.add({
          "id_producto": p.idProducto,
          "nombre": p.nombre,
          "precio": p.precio,
          "cantidad": 1,
        });
      }
    });
  }

  void cambiarCantidad(int index, int delta) {
    setState(() {
      carrito[index]['cantidad'] += delta;
      if (carrito[index]['cantidad'] <= 0) {
        carrito.removeAt(index);
      }
    });
  }

  double get total =>
      carrito.fold(0, (sum, item) => sum + item['precio'] * item['cantidad']);

  //  CAMBIO
  void calcularCambio() {
    final recibido = double.tryParse(pagoCtrl.text) ?? 0;
    setState(() => cambio = recibido - total);
  }

  //  VENDER
  void vender() async {
    if (carrito.isEmpty) return;

    if (metodoPago == "efectivo") {
      final recibido = double.tryParse(pagoCtrl.text) ?? 0;
      if (recibido < total) {
        showDialog(
          context: context, 
          builder: (_) => CustomAlert(
            titulo: 'VENTA', 
            mensaje: 'Dinero insuficiente', 
            icono: Icons.error
            ),
        );
        return;
      }
    }

    try {
      await ventasController.insertarVentaCompleta(
        carrito,
        total,
        metodoPago,
        idCliente: clienteSeleccionado?.idCliente,
      );

      await imprimirTicket(); 

      setState(() {
        carrito.clear();
        pagoCtrl.clear();
        cambio = 0;
      });

      showDialog(
        context: context, 
        builder: (_) => CustomAlert(
          titulo: 'VENTA', 
          mensaje: 'Venta realizada con exito', 
          icono: Icons.check
          ),
        );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

// Funcion para imprimr tickets
  Future<void> imprimirTicket() async {
  final pdf = await TicketService.generarTicket(
    carrito: carrito,
    total: total,
    metodoPago: metodoPago,
    recibido : double.tryParse(pagoCtrl.text) ?? 0,
    cambio : cambio 
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: CustomHeader(
        titulo: clienteSeleccionado != null
            ? "Venta - ${clienteSeleccionado!.nombre}"
            : "Punto de Venta",
        mostrarVolver: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            //  IZQUIERDA (PRODUCTOS)
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  //  BUSCADOR
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

                  //  CATEGORÍAS
                  /*SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text("Todos"),
                          selected: categoriaSeleccionada == null,
                          onSelected: (_) {
                            setState(() => categoriaSeleccionada = null);
                            cargarProductos();
                          },
                        ),

                        ...categorias.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(cat.nombre), //  FIX
                              selected:
                                  categoriaSeleccionada == cat.idCategoria,
                              onSelected: (_) {
                                setState(() {
                                  categoriaSeleccionada = cat.idCategoria;
                                });

                                //filtrarProductos(cat.idCategoria!);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),*/

                  const SizedBox(height: 10),

                  //  PRODUCTOS
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
                                Text("\$${p.precio}"),
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

            //  DERECHA (CARRITO)
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text("Detalle de Venta",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                    Expanded(
                      child: ListView.builder(
                        itemCount: carrito.length,
                        itemBuilder: (_, i) {
                          final item = carrito[i];

                          return ListTile(
                            title: Text(item['nombre']),
                            subtitle: Text("\$${item['precio']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      cambiarCantidad(i, -1),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(item['cantidad'].toString()),
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

                    //  TOTAL
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total"),
                        Text("\$${total.toStringAsFixed(2)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    //  MÉTODO
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => metodoPago = "efectivo"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: metodoPago == "efectivo"
                                  ? Colors.green
                                  : null,
                            ),
                            child: const Text("Efectivo"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => metodoPago = "tarjeta"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: metodoPago == "tarjeta"
                                  ? Colors.blue
                                  : null,
                            ),
                            child: const Text("Tarjeta"),
                          ),
                        ),
                      ],
                    ),

                    if (metodoPago == "efectivo") ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: pagoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Monto recibido",
                        ),
                        onChanged: (_) => calcularCambio(),
                      ),
                      const SizedBox(height: 5),
                      Text("Cambio: \$${cambio.toStringAsFixed(2)}"),
                    ],

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if(carrito.isEmpty) return;

                          showDialog(
                            context: context, 
                            builder: (_) => CustomAlert(
                              titulo: "VENTA", 
                              mensaje: "¿Deseas realizar la venta?", 
                              icono: Icons.shield_outlined,
                              textoCancelar: "Cancelar",
                              textoConfirmar: "Confirmar",
                              onConfirm: (){
                                vender();
                              },
                              ),
                            );
                        },
                        child: const Text("Confirmar Venta"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}