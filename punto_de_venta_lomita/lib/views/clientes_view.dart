import 'package:flutter/material.dart';
import 'package:punto_de_venta_lomita/views/ventas_view.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente_model.dart';
import '../widgets/nav_bar.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  final controller = ClienteController();

  List<Cliente> clientes = [];
  int? selectedIndex;

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargar();
  }

void cargar() async {
  final data = await controller.obtenerTodos();

  setState(() {
    clientes = data;

    if (selectedIndex != null &&
        selectedIndex! >= clientes.length) {
      selectedIndex = null;
    }
  });
}

void buscar(String query) async {
  if (query.isEmpty) {
    cargar();
  } else {
    final data = await controller.buscar(query);

    setState(() {
      clientes = data;

      if (selectedIndex != null &&
          selectedIndex! >= clientes.length) {
        selectedIndex = null;
      }
    });
  }
}

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  // 🟢 FORMULARIO MODAL
  void _mostrarFormulario() {
    final nombreCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo Cliente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: "Dirección")),
            TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: "Teléfono")),
            TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: "Correo")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.insertar(
                Cliente(
                  idCliente: null,
                  nombre: nombreCtrl.text,
                  direccion: direccionCtrl.text,
                  telefono: int.tryParse(telefonoCtrl.text),
                  correo: correoCtrl.text,
                  fechaRegistro: DateTime.now().toIso8601String(),
                ),
              );

              Navigator.pop(context);
              cargar();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }


    void _mostrarFormularioEditar(Cliente cliente) {
    final nombreCtrl = TextEditingController(text: cliente.nombre);
    final direccionCtrl = TextEditingController(text: cliente.direccion);
    final telefonoCtrl = TextEditingController(text: cliente.telefono?.toString());
    final correoCtrl = TextEditingController(text: cliente.correo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Cliente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: "Dirección")),
            TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: "Teléfono")),
            TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: "Correo")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.actualizar(
                Cliente(
                  idCliente: cliente.idCliente,
                  nombre: nombreCtrl.text,
                  direccion: direccionCtrl.text,
                  telefono: int.tryParse(telefonoCtrl.text),
                  correo: correoCtrl.text,
                  fechaRegistro: DateTime.now().toIso8601String(),
                ),
              );

              Navigator.pop(context);
              cargar();
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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: CustomHeader(
        titulo: "Clientes",
        mostrarVolver: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            //color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
        child: Row(
          children: [
            //  IZQUIERDA
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  //  MÉTRICAS
                  Row(
                    children: [
                      _stat("Clientes", clientes.length.toString()),
                      const SizedBox(width: 10),
                      _stat("Con teléfono",
                          clientes.where((c) => c.telefono != null).length.toString()),
                      const SizedBox(width: 10),
                      _stat("Con correo",
                          clientes.where((c) => c.correo != null).length.toString()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //  BUSCADOR
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: buscar,
                          decoration: InputDecoration(
                            hintText: "Buscar cliente...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFFF8F6F2),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _mostrarFormulario,
                        icon: const Icon(Icons.add),
                        label: const Text("Nuevo"),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  //  LISTA
                  Expanded(
                    child: ListView.builder(
                      itemCount: clientes.length,
                      itemBuilder: (_, i) {
                        final c = clientes[i];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(c.nombre),
                            subtitle: Text(c.direccion ?? "Sin dirección"),

                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.telefono?.toString() ?? "-"),
                                const SizedBox(height: 4),
                                Text(
                                  _formatearFecha(c.fechaRegistro),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),

                            selected: selectedIndex == i,

                            onTap: () {
                              setState(() {
                                selectedIndex = i;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            //  DERECHA (DETALLE)
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: selectedIndex == null ||
        selectedIndex! >= clientes.length
    ? const Center(child: Text("Selecciona un cliente"))
    : _detalleCliente(clientes[selectedIndex!]),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  //  DETALLE
  Widget _detalleCliente(Cliente c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.nombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _info("Dirección", c.direccion),
        _info("Teléfono", c.telefono?.toString()),
        _info("Correo", c.correo),
        _info("Registro", _formatearFecha(c.fechaRegistro)),

        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: () {
            final cliente = clientes[selectedIndex!];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VentasView(cliente: cliente),
                ),
            );
          },
          icon: const Icon(Icons.point_of_sale),
          label: const Text("Nueva Venta"),
        ),

        ElevatedButton.icon(
                        onPressed: () => _mostrarFormularioEditar(clientes[selectedIndex!]),
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                      ),

        ElevatedButton.icon(
          onPressed: () => eliminar(c.idCliente!),
          icon: const Icon(Icons.delete),
          label: const Text("Eliminar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        )
      ],
    );
  }

  //  INFO ITEM
  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$label: ${value ?? '-'}"),
    );
  }

  //  MÉTRICAS
  Widget _stat(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  //  FECHA
  String _formatearFecha(String? fecha) {
    if (fecha == null) return "-";

    final date = DateTime.tryParse(fecha);
    if (date == null) return fecha;

    return "${date.day}/${date.month}/${date.year}";
  }
}