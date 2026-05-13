import 'package:flutter/material.dart';
import '../controllers/pedidos_controller.dart';
import '../models/pedidos_model.dart';
import '../models/producto_model.dart';
import '../services/producto_services.dart';

class CrearPedidoView extends StatefulWidget {
  final int? idCliente;
  final String? nombreCliente;

  const CrearPedidoView({
    super.key,
    this.idCliente,
    this.nombreCliente,
  });

  @override
  State<CrearPedidoView> createState() => _CrearPedidoViewState();
}

class _CrearPedidoViewState extends State<CrearPedidoView> {

  final controller = PedidosController();
  final productoService = ProductoService();

  final fechaEntregaCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  List<Producto> productos = [];
  List<Map<String, dynamic>> carrito = [];

  String tipoEntrega = "Domicilio";

  double total = 0;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {

    final data = await productoService.obtenerTodos();

    setState(() {
      productos = data;
    });
  }

  void agregarProducto(Producto producto) {

    final index = carrito.indexWhere(
      (e) => e['producto'].idProducto == producto.idProducto,
    );

    if (index >= 0) {

      carrito[index]['cantidad'] += 1;

    } else {

      carrito.add({
        'producto': producto,
        'cantidad': 1,
      });
    }

    calcularTotal();
  }

  void calcularTotal() {

    double nuevo = 0;

    for (var item in carrito) {

      final producto = item['producto'] as Producto;
      final cantidad = item['cantidad'] as int;

      nuevo += producto.precio * cantidad;
    }

    setState(() {
      total = nuevo;
    });
  }

  void aumentar(int index) {

    carrito[index]['cantidad']++;

    calcularTotal();
  }

  void disminuir(int index) {

    if (carrito[index]['cantidad'] > 1) {

      carrito[index]['cantidad']--;

    } else {

      carrito.removeAt(index);
    }

    calcularTotal();
  }

  Future<void> guardarPedido() async {

    if (widget.idCliente == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un cliente'),
        ),
      );

      return;
    }

    if (carrito.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega productos al pedido'),
        ),
      );

      return;
    }

    final pedido = Pedidos(
      idCliente: widget.idCliente!,
      fecha: DateTime.now().toString(),
      fechaEntrega: fechaEntregaCtrl.text,
      tipoEntrega: tipoEntrega,
      estado: 'Pendiente',
      total: total,
    );

    await controller.crearPedido(pedido);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido guardado correctamente'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(

        child: Row(

          children: [

            /// FORMULARIO
            Expanded(
              flex: 6,

              child: SingleChildScrollView(

                padding: const EdgeInsets.all(24),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Container(

                      width: double.infinity,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEA),
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Row(

                        children: [

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5C100),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  'Nuevo Pedido',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  widget.nombreCliente ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [

                        campo(
                          controller: fechaEntregaCtrl,
                          titulo: 'Fecha de entrega',
                          icon: Icons.calendar_month,
                          hint: '10 mayo 4:00 AM',
                        ),

                        campo(
                          controller: direccionCtrl,
                          titulo: 'Direccion',
                          icon: Icons.location_on_outlined,
                          hint: 'Calle, colonia, ciudad',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Tipo de entrega',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [

                        tipoCard('Domicilio'),
                        const SizedBox(width: 16),
                        tipoCard('Sucursal'),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GridView.builder(

                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: productos.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.1,
                      ),

                      itemBuilder: (context, index) {

                        final producto = productos[index];

                        return Container(

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5C100),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  '\$${producto.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              Text(
                                producto.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                producto.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFE5C100),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),

                                  onPressed: () {
                                    agregarProducto(producto);
                                  },

                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar'),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),

            /// PANEL DERECHO
            Container(

              width: 360,

              margin: const EdgeInsets.all(24),

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Detalle del Pedido',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(

                    child: carrito.isEmpty

                        ? const Center(
                            child: Text(
                              'No hay productos agregados',
                            ),
                          )

                        : ListView.builder(

                            itemCount: carrito.length,

                            itemBuilder: (context, index) {

                              final item = carrito[index];

                              final producto =
                                  item['producto'] as Producto;

                              final cantidad =
                                  item['cantidad'] as int;

                              return Container(

                                margin: const EdgeInsets.only(bottom: 16),

                                padding: const EdgeInsets.all(16),

                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Row(

                                      children: [

                                        cantidadBtn(
                                          Icons.remove,
                                          () => disminuir(index),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            cantidad.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        cantidadBtn(
                                          Icons.add,
                                          () => aumentar(index),
                                        ),

                                        const Spacer(),

                                        Text(
                                          '\$${(producto.precio * cantidad).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5C100),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: guardarPedido,

                      child: const Text(
                        'Guardar Pedido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget campo({
    required TextEditingController controller,
    required String titulo,
    required IconData icon,
    required String hint,
  }) {

    return SizedBox(

      width: 320,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget tipoCard(String tipo) {

    final activo = tipoEntrega == tipo;

    return InkWell(

      borderRadius: BorderRadius.circular(16),

      onTap: () {
        setState(() {
          tipoEntrega = tipo;
        });
      },

      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFFE5C100)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Text(
          tipo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: activo ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget cantidadBtn(
    IconData icon,
    VoidCallback onTap,
  ) {

    return InkWell(

      borderRadius: BorderRadius.circular(10),

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.all(6),

        decoration: BoxDecoration(
          color: const Color(0xFFE5C100),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Icon(icon, size: 18),
      ),
    );
  }
}
