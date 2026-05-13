import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/cliente_services.dart';
import 'crearPedido_view.dart';
import '../widgets/nav_bar.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  final clienteService = ClienteService();

  List<Cliente> clientes = [];
  List<Cliente> filtrados = [];

  final searchCtrl = TextEditingController();

  Cliente? seleccionado;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    final data = await clienteService.obtenerTodos();

    setState(() {
      clientes = data;
      filtrados = data;
    });
  }

  void buscar(String value) {
    setState(() {
      filtrados = clientes.where((c) {
        return c.nombre.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(titulo: "Pedidos", mostrarVolver: true),

      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: Row(
          children: [
            /// IZQUIERDA
            Expanded(
              flex: 7,

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// SEARCH
                    Container(
                      height: 55,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: TextField(
                        controller: searchCtrl,
                        onChanged: buscar,

                        decoration: const InputDecoration(
                          hintText: "Buscar cliente",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BOTON NUEVO PEDIDO
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5C100),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CrearPedidoView(),
                              ),
                            );
                          },

                          icon: const Icon(Icons.add),

                          label: const Text(
                            "Nuevo Pedido",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// GRID CLIENTES
                    Expanded(
                      child: GridView.builder(
                        itemCount: filtrados.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 18,
                              childAspectRatio: 1.2,
                            ),

                        itemBuilder: (context, index) {
                          final cliente = filtrados[index];

                          final isSelected =
                              seleccionado?.idCliente == cliente.idCliente;

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),

                            onTap: () {
                              setState(() {
                                seleccionado = cliente;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),

                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(20),

                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE5C100)
                                      : Colors.transparent,
                                  width: 2,
                                ),

                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFFFFF3B0),

                                    child: Text(
                                      cliente.nombre[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    cliente.nombre,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    cliente.telefono.toString(),

                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  SizedBox(
                                    width: double.infinity,

                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CrearPedidoView(
                                              idCliente: cliente.idCliente,
                                              nombreCliente: cliente.nombre,
                                            ),
                                          ),
                                        );
                                      },

                                      icon: const Icon(Icons.add),

                                      label: const Text("Pedido"),
                                    ),
                                  ),
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
            ),

            /// DERECHA
            Container(
              width: 340,

              margin: const EdgeInsets.all(24),

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),

              child: seleccionado == null
                  ? const Center(
                      child: Text(
                        "Selecciona un cliente",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Detalles del Cliente",

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        info("Nombre", seleccionado!.nombre),

                        info("Telefono", seleccionado!.telefono.toString()),

                        info("Correo", seleccionado!.correo ?? "-"),

                        info("Direccion", seleccionado!.direccion ?? "-"),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE5C100),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CrearPedidoView(
                                    idCliente: seleccionado!.idCliente,
                                    nombreCliente: seleccionado!.nombre,
                                  ),
                                ),
                              );
                            },

                            child: const Text(
                              "Continuar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 6),

          Text(
            value,

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
