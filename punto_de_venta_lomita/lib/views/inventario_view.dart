import 'package:flutter/material.dart';
import '../controllers/producto_controller.dart';
import '../controllers/categoria_controller.dart';
import '../models/producto_model.dart';
import '../models/categoria_model.dart';
import '../widgets/nav_bar.dart';
import '../services/configuracion_service.dart';
import '../models/configuracion_model.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final productoController = ProductoService();
  final categoriaController = CategoriaController();

  late Configuracion config;

  bool cargando = true;

  List<Map<String, dynamic>> productos = [];
  List<Categoria> categorias = [];

  int? categoriaSeleccionada;
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    config = await ConfiguracionService().obtener();

    await cargarTodo();

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  Future<void> cargarTodo() async {
    final prod = await productoController.obtenerConStock();
    final cat = await categoriaController.obtenerTodos();

    productos = prod;
    categorias = cat;
  }

  List<Map<String, dynamic>> get filtrados {
    return productos.where((p) {
      final matchBusqueda = p['nombre']
          .toLowerCase()
          .contains(busqueda.toLowerCase());

      final matchCategoria =
          categoriaSeleccionada == null ||
              p['id_categoria'] == categoriaSeleccionada;

      return matchBusqueda && matchCategoria;
    }).toList();
  }

  void confirmarEliminar(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,

        title: const Text(
          "Eliminar producto",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        content: Text(
          "¿Deseas eliminar ${p['nombre']}?",
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () async {
              await productoController.eliminar(
                p['id_producto'],
              );

              Navigator.pop(context);

              await inicializar();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Producto eliminado"),
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),

            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void mostrarEditarProducto(Map<String, dynamic> p) {
    final nombreCtrl =
        TextEditingController(text: p['nombre']);

    final precioCtrl = TextEditingController(
      text: p['precio'].toString(),
    );

    final stockCtrl = TextEditingController(
      text: p['cantidad'].toString(),
    );

    showDialog(
      context: context,

      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,

        child: Container(
          width: 500,
          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,

                      decoration: const BoxDecoration(
                        color: Color(0xFFF2C500),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "Editar Producto",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "Actualiza la información del producto.",
                  style: TextStyle(
                    color: Color(0xFF6E6A64),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 28),

                _input(
                  controller: nombreCtrl,
                  hint: "Nombre del producto",
                  icon: Icons.inventory_2_outlined,
                ),

                const SizedBox(height: 18),

                _input(
                  controller: precioCtrl,
                  hint: "Precio",
                  icon: Icons.attach_money,
                  number: true,
                ),

                const SizedBox(height: 18),

                _input(
                  controller: stockCtrl,
                  hint: "Stock",
                  icon: Icons.layers_outlined,
                  number: true,
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context),

                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(54),

                          side: const BorderSide(
                            color: Color(0xFFE5DED3),
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await productoController
                              .actualizar(
                            Producto(
                              idProducto:
                                  p['id_producto'],
                              nombre:
                                  nombreCtrl.text,
                              descripcion: "",
                              precio: double.parse(
                                precioCtrl.text,
                              ),
                              categoriaId:
                                  p['id_categoria'],
                              estado:
                                  p['estado'] ??
                                      "Activo",
                              stockMinimo:
                                  config.stockMinimo,
                            ),
                          );

                          await productoController
                              .actualizarStock(
                            p['id_producto'],
                            int.tryParse(stockCtrl.text) ?? p['cantidad'],
                          );

                          Navigator.pop(context);

                          await inicializar();

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Producto actualizado",
                              ),
                            ),
                          );
                        },

                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFF2C500,
                          ),

                          foregroundColor:
                              Colors.black87,

                          elevation: 0,

                          minimumSize:
                              const Size.fromHeight(54),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: const Text(
                          "Guardar",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int agotados = 0;
    int bajos = 0;
    int ok = 0;

    for (var p in productos) {
      int stock = p['cantidad'];

      if (stock == 0) {
        agotados++;
      } else if (stock <= config.stockMinimo) {
        bajos++;
      } else {
        ok++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),

      appBar: const CustomHeader(
        titulo: "Inventario",
        mostrarVolver: true,
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                24,
              ),

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(28),

                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // 🔥 HEADER
              
      

                    const Text(
                      "Administra productos, existencias y niveles de stock.",
                      style: TextStyle(
                        color: Color(0xFF6E6A64),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 📊 MÉTRICAS
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            "Productos",
                            productos.length
                                .toString(),
                            Icons.inventory_2,
                            const Color(
                              0xFFF2C500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _metricCard(
                            "Agotados",
                            agotados.toString(),
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _metricCard(
                            "Stock Bajo",
                            bajos.toString(),
                            Icons.warning_amber,
                            Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _metricCard(
                            "Stock OK",
                            ok.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 🔍 FILTROS
                    Row(
                      children: [
                        Expanded(
                          flex: 4,

                          child: TextField(
                            onChanged: (v) {
                              setState(() {
                                busqueda = v;
                              });
                            },

                            decoration:
                                InputDecoration(
                              hintText:
                                  "Buscar producto...",

                              prefixIcon:
                                  const Icon(
                                Icons.search,
                              ),

                              filled: true,

                              fillColor:
                                  const Color(
                                0xFFF8F6F2,
                              ),

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 16,
                              ),

                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          flex: 5,

                          child: SizedBox(
                            height: 50,

                            child: ListView(
                              scrollDirection:
                                  Axis.horizontal,

                              children: [
                                ChoiceChip(
                                  label: const Text(
                                      "Todos"),

                                  selected:
                                      categoriaSeleccionada ==
                                          null,

                                  selectedColor:
                                      const Color(
                                    0xFFF2C500,
                                  ),

                                  labelStyle:
                                      TextStyle(
                                    color:
                                        categoriaSeleccionada ==
                                                null
                                            ? Colors
                                                .black
                                            : Colors
                                                .black87,
                                  ),

                                  onSelected: (_) {
                                    setState(() {
                                      categoriaSeleccionada =
                                          null;
                                    });
                                  },
                                ),

                                ...categorias.map(
                                  (cat) {
                                    final selected =
                                        categoriaSeleccionada ==
                                            cat.idCategoria;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        left: 10,
                                      ),

                                      child:
                                          ChoiceChip(
                                        label: Text(
                                          cat.nombre,
                                        ),

                                        selected:
                                            selected,

                                        selectedColor:
                                            const Color(
                                          0xFFF2C500,
                                        ),

                                        labelStyle:
                                            TextStyle(
                                          color: selected
                                              ? Colors
                                                  .black
                                              : Colors
                                                  .black87,
                                        ),

                                        onSelected:
                                            (_) {
                                          setState(
                                            () {
                                              categoriaSeleccionada =
                                                  cat.idCategoria;
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 📋 TABLA
                    Expanded(
                      child: Container(
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),

                          border: Border.all(
                            color: const Color(
                              0xFFE8E2D9,
                            ),
                          ),
                        ),

                        child: Column(
                          children: [
                            _headerTabla(),

                            Expanded(
                              child:
                                  filtrados.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No hay productos",
                                          ),
                                        )
                                      : ListView
                                          .separated(
                                          itemCount:
                                              filtrados
                                                  .length,

                                          separatorBuilder:
                                              (_, __) =>
                                                  const Divider(
                                            height: 1,
                                          ),

                                          itemBuilder:
                                              (_, i) {
                                            return _filaProducto(
                                              filtrados[
                                                  i],
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _headerTabla() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F2),

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),

      child: const Row(
        children: [
          Expanded(
            flex: 22,
            child: Text(
              "PRODUCTO",
              style: _headerStyle,
            ),
          ),

          Expanded(
            flex: 18,
            child: Text(
              "CATEGORÍA",
              style: _headerStyle,
            ),
          ),

          Expanded(
            flex: 12,
            child: Text(
              "PRECIO",
              style: _headerStyle,
            ),
          ),

          Expanded(
            flex: 12,
            child: Text(
              "STOCK",
              style: _headerStyle,
            ),
          ),

          Expanded(
            flex: 16,
            child: Text(
              "ESTADO",
              style: _headerStyle,
            ),
          ),

          Expanded(
            flex: 20,
            child: Text(
              "ACCIONES",
              style: _headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaProducto(Map<String, dynamic> p) {
    final stock = p['cantidad'];
    final minimo = config.stockMinimo;

    String estado;
    Color color;
    IconData icon;

    if (stock == 0) {
      estado = "Agotado";
      color = Colors.red;
      icon = Icons.cancel;
    } else if (stock <= minimo) {
      estado = "Stock Bajo";
      color = Colors.orange;
      icon = Icons.warning_amber;
    } else {
      estado = "Disponible";
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      child: Row(
        children: [
          Expanded(
            flex: 22,

            child: Text(
              p['nombre'],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ),

          Expanded(
            flex: 18,

            child: Text(
              p['categoria_nombre'] ??
                  'Sin categoría',
            ),
          ),

          Expanded(
            flex: 12,

            child: Text(
              "\$${p['precio']}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            flex: 12,

            child: Text("$stock"),
          ),

          Expanded(
            flex: 16,

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),

                  const SizedBox(width: 6),

                  Flexible(
                    child: Text(
                      estado,
                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        color: color,
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 20,

            child: Row(
              children: [
                SizedBox(
                  width: 75,

                  child: TextField(
                    keyboardType:
                        TextInputType.number,

                    decoration: InputDecoration(
                      hintText: "Cant",

                      filled: true,
                      fillColor:
                          const Color(
                        0xFFF8F6F2,
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    onSubmitted: (value) async {
                      final cantidad =
                          int.tryParse(value) ??
                              0;

                      if (cantidad <= 0) return;

                      await productoController
                          .agregarStock(
                        p['id_producto'],
                        cantidad,
                      );

                      await inicializar();
                    },
                  ),
                ),

                IconButton(
                  tooltip: "Editar",

                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                  ),

                  onPressed: () =>
                      mostrarEditarProducto(
                    p,
                  ),
                ),

                IconButton(
                  tooltip: "Eliminar",

                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),

                  onPressed: () =>
                      confirmarEliminar(p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6E6A64),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool number = false,
  }) {
    return TextField(
      controller: controller,

      keyboardType:
          number ? TextInputType.number : null,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: const Color(0xFFDA9B00),
        ),

        filled: true,
        fillColor: const Color(0xFFF8F6F2),

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF3C3935),
);